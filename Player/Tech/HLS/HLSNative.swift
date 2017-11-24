//
//  HLSNative.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import AVFoundation

public protocol HLSNativeConfigurable {
    var hlsNativeConfiguration: HLSNativeConfiguration { get }
}

public struct HLSNativeConfiguration {
    public let url: URL
    public let playSessionId: String
    
    /// DRM agent used to validate the context source
    public let drm: FairplayRequester?
    
    public init(url: URL, playSessionId: String, drm: FairplayRequester?) {
        self.url = url
        self.playSessionId = playSessionId
        self.drm = drm
    }
}

public final class HLSNative<Context: MediaContext>: PlaybackTech {
    public typealias Configuration = HLSNativeConfiguration
    public typealias TechError = HLSNativeError
    public var eventDispatcher: EventDispatcher<Context, HLSNative<Context>> = EventDispatcher()
    
    
    /// *Native* `AVPlayer` used for playback purposes.
    internal var avPlayer: AVPlayer
    
    /// The currently active `MediaAsset` is stored here.
    ///
    /// This may be `nil` due to several reasons, for example before any media is loaded.
    internal var currentAsset: MediaAsset<Context.Source>?
    
    
    /// `BufferState` is a private state tracking buffering events. It should not be exposed externally.
    internal var bufferState: BufferState = .notInitialized
    
    /// Private buffer state
    internal enum BufferState {
        /// Buffering has not been started yet.
        case notInitialized
        
        /// Currently buffering
        case buffering
        
        /// Buffer has enough data to keep up with playback.
        case onPace
    }
    
    /// `PlaybackState` is a private state tracker and should not be exposed externally.
    internal var playbackState: PlaybackState = .notStarted
    
    /// Internal state for tracking playback.
    internal enum PlaybackState {
        case notStarted
        case playing
        case paused
        case stopped
    }
    
    /// Storage for autoplay toggle
    public var autoplay: Bool = false
    
    // MARK: SessionShift
    /// `Bookmark` is a private state tracking `SessionShift` status. It should not be exposed externally.
    internal var bookmark: Bookmark = .notEnabled

    
    /// `MediaAsset` contains and handles all information used for loading and preparing an asset.
    ///
    /// *Fairplay* protected media is processed by the supplied FairplayRequester
    internal class MediaAsset<Source: MediaSource> {
        /// Specifies the asset which is about to be loaded.
        fileprivate var urlAsset: AVURLAsset
        
        /// AVPlayerItem models the timing and presentation state of an asset played by an AVPlayer object. It provides the interface to seek to various times in the media, determine its presentation size, identify its current time, and much more.
        lazy internal var playerItem: AVPlayerItem = { [unowned self] in
            return AVPlayerItem(asset: self.urlAsset)
            }()
        
        /// Loads, configures and validates *Fairplay* `DRM` protected assets.
        internal let fairplayRequester: FairplayRequester?
        
        /// Source used to create this media asset
        internal let source: Source
        
        /// Creates the media asset
        ///
        /// - parameter source: `MediaSource` defining the playback
        /// - parameter configuration: HLS specific configuration
        internal init(source: Source, configuration: HLSNativeConfiguration) {
            self.source = source
            self.fairplayRequester = configuration.drm
            
            urlAsset = AVURLAsset(url: configuration.url)
            if fairplayRequester != nil {
                urlAsset.resourceLoader.setDelegate(fairplayRequester,
                                                    queue: DispatchQueue(label: configuration.playSessionId + "-fairplayLoader"))
            }
        }
        
        // MARK: Change Observation
        /// Wrapper observing changes to the underlying `AVPlayerItem`
        lazy internal var itemObserver: PlayerItemObserver = { [unowned self] in
            return PlayerItemObserver()
            }()
        
        deinit {
            itemObserver.stopObservingAll()
            itemObserver.unsubscribeAll()
        }
        
        /// Prepares and loads media `properties` relevant to playback. This is an asynchronous process.
        ///
        /// There are several reasons why the loading process may fail. Failure to prepare `properties` of `AVURLAsset` is discussed in Apple's documentation detailing `AVAsynchronousKeyValueLoading`.
        ///
        /// - parameter keys: *Property keys* to preload
        /// - parameter callback: Fires once the async loading is complete, or finishes with an error.
        internal func prepare(loading keys: [AVAsset.LoadableKeys], callback: @escaping (HLSNativeError?) -> Void) {
            urlAsset.loadValuesAsynchronously(forKeys: keys.rawValues) {
                DispatchQueue.main.async { [weak self] in
                    
                    // Check for any issues preparing the loaded values
                    let errors = keys.flatMap{ key -> Error? in
                        var error: NSError?
                        guard self?.urlAsset.statusOfValue(forKey: key.rawValue, error: &error) != .failed else {
                            return error!
                        }
                        return nil
                    }
                    
                    guard errors.isEmpty else {
                        callback(.failedToPrepare(errors: errors))
                        return
                    }
                    
                    guard let isPlayable = self?.urlAsset.isPlayable, isPlayable else {
                        callback(.loadedButNotPlayable)
                        return
                    }
                    
                    // Success
                    callback(nil)
                }
            }
        }
    }
    
    public required init() {
        avPlayer = AVPlayer()
        
        handleCurrentItemChanges()
        handlePlaybackStateChanges()
//        handleAudioSessionInteruptionEvents()
//        handleBackgroundingEvents()
    }
    
    deinit {
        print("HLSNative.deinit")
        playerObserver.stopObservingAll()
        playerObserver.unsubscribeAll()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    /// Wrapper observing changes to the underlying `AVPlayer`
    lazy fileprivate var playerObserver: PlayerObserver = {
        return PlayerObserver()
    }()
}


extension HLSNative where Context.Source: HLSNativeConfigurable {
    
    public func load(source: Context.Source) {
        let configuration = source.hlsNativeConfiguration
        
        let mediaAsset = MediaAsset<Context.Source>(source: source, configuration: configuration)
        
        // Unsubscribe any current item
        currentAsset?.itemObserver.stopObservingAll()
        currentAsset?.itemObserver.unsubscribeAll()
        
        // TODO: Stop playback?
        playbackState = .stopped
        avPlayer.pause()
        
        if let oldSource = currentAsset?.source {
            eventDispatcher.onPlaybackAborted(self, oldSource)
            oldSource.analyticsConnector.onAborted(tech: self, source: oldSource)
        }
        
        // Start notifications on new session
        // At this point the `AVURLAsset` has yet to perform async loading of values (such as `duration`, `tracks` or `playable`) through `loadValuesAsynchronously`.
        eventDispatcher.onPlaybackCreated(self, mediaAsset.source)
        mediaAsset.source.analyticsConnector.onCreated(tech: self, source: mediaAsset.source)
        
        // Reset playbackState
        playbackState = .notStarted
        
        mediaAsset.prepare(loading: [.duration, .tracks, .playable]) { [weak self] error in
            guard let `self` = self else { return }
            guard error == nil else {
                let techError = PlayerError<HLSNative<Context>,Context>.tech(error: error!)
                `self`.eventDispatcher.onError(`self`, mediaAsset.source, techError)
                mediaAsset.source.analyticsConnector.onError(tech: `self`, source: mediaAsset.source, error: techError)
                return
            }
            // At this point event listeners (*KVO* and *Notifications*) for the media in preparation have not registered. `AVPlayer` has not yet replaced the current (if any) `AVPlayerItem`.
            `self`.eventDispatcher.onPlaybackPrepared(`self`, mediaAsset.source)
            mediaAsset.source.analyticsConnector.onPrepared(tech: `self`, source: mediaAsset.source)
            
            `self`.readyPlayback(with: mediaAsset)
        }
    }
    
    /// Once the `MediaAsset` has been *prepared* through `mediaAsset.prepare(loading: callback:)` the relevant `KVO` and `Notificaion`s are subscribed.
    ///
    /// Finally, once the `Player` is configured, the `currentMedia` is replaced with the newly created one. The system now awaits playback status to return `.readyToPlay`.
    fileprivate func readyPlayback(with mediaAsset: MediaAsset<Context.Source>) {
        currentAsset = mediaAsset
        
        let playerItem = mediaAsset.playerItem
        
        // Observe changes to .status for new playerItem
        handleStatusChange(mediaAsset: mediaAsset)
        
        // Observe BitRate changes
        handleBitrateChangedEvent(mediaAsset: mediaAsset)
        
        // Observe Buffering
        handleBufferingEvents(mediaAsset: mediaAsset)
        
        // Observe Duration changes
        handleDurationChangedEvent(mediaAsset: mediaAsset)
        
        // ADITIONAL KVO TO CONSIDER
        //[_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"]; // availableDuration?
        //[_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"]; // BUFFERING
        //[_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"]; // PLAYREADY?
        
        
        // Observe when currentItem has played to the end
        handlePlaybackCompletedEvent(mediaAsset: mediaAsset)
        
        // Update AVPlayer by replacing old AVPlayerItem with newly created currentItem
        if let currentlyPlaying = avPlayer.currentItem, currentlyPlaying == playerItem {
            // NOTE: Make surewe dont replace an item with the same item
            // TODO: Should this perhaps be done before we actully try replacing and unsub/sub KVO/notifications
            return
        }
        
        // Replace the player item with a new player item. The item replacement occurs
        // asynchronously; observe the currentItem property to find out when the
        // replacement will/did occur
        avPlayer.replaceCurrentItem(with: playerItem)
    }
}


// MARK: - Events
/// Player Item Status Change Events
extension HLSNative {
    /// Subscribes to and handles changes in `AVPlayerItem.status`
    ///
    /// This is the final step in the initialization process. Either the playback is ready to start at the specified *start time* or an error has occured. The specified start time may be at the start of the stream if `SessionShift` is not used.
    ///
    /// If `autoplay` has been specified as `true`, playback will commence right after `.readyToPlay`.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handleStatusChange(mediaAsset: MediaAsset<Context.Source>) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.observe(path: .status, on: playerItem) { [weak self] item, change in
            guard let `self` = self else { return }
            if let newValue = change.new as? Int, let status = AVPlayerItemStatus(rawValue: newValue) {
                switch status {
                case .unknown:
                    // TODO: Do we send anything on .unknown?
                    return
                case .readyToPlay:
                    // This will trigger every time the player is ready to play, including:
                    //  - first started
                    //  - after seeking
                    // Only send onPlaybackReady if the stream has not been started yet.
                    if self.playbackState == .notStarted {
                        if case let .enabled(value) = `self`.bookmark, let offset = value {
                            let cmTime = CMTime(value: offset, timescale: 1000)
                            `self`.avPlayer.seek(to: cmTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { [weak self] success in
                                
                                self?.startPlayback()
                            }
                        }
                        else {
                            `self`.startPlayback()
                        }
                    }
                case .failed:
                    let techError = PlayerError<HLSNative<Context>,Context>.tech(error: HLSNativeError.failedToReady(error: item.error))
                    `self`.eventDispatcher.onError(`self`, mediaAsset.source, techError)
                    mediaAsset.source.analyticsConnector.onError(tech: `self`, source: mediaAsset.source, error: techError)
                }
            }
        }
    }
    
    /// Private function to trigger the necessary final events right before playback starts.
    ///
    /// Status for the `AVPlayerItem` associated with the media in preparation has reached `.readyToPlay` state.
    private func startPlayback() {
        if let source = currentAsset?.source {
            eventDispatcher.onPlaybackStarted(self, source)
            source.analyticsConnector.onReady(tech: self, source: source)
        }
        
        // Start playback if autoplay is enabled
        if self.autoplay { self.play() }
    }
}

/// Bitrate Changed Events
extension HLSNative {
    /// Subscribes to and handles bitrate changes accessed through `AVPlayerItem`s `AVPlayerItemNewAccessLogEntry`.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handleBitrateChangedEvent(mediaAsset: MediaAsset<Context.Source>) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.subscribe(notification: .AVPlayerItemNewAccessLogEntry, for: playerItem) { [weak self] notification in
            guard let `self` = self else { return }
            if let item = notification.object as? AVPlayerItem, let accessLog = item.accessLog() {
                if let currentEvent = accessLog.events.last {
                    let newBitrate = currentEvent.indicatedBitrate
                    DispatchQueue.main.async {
                        `self`.eventDispatcher.onBitrateChanged(`self`, mediaAsset.source, newBitrate)
                        mediaAsset.source.analyticsConnector.onBitrateChanged(tech: `self`, source: mediaAsset.source, bitrate: newBitrate)
                    }
                }
            }
        }
    }
}

/// Buffering Events
extension HLSNative {
    
    /// Subscribes to and handles buffering events by tracking the status of `AVPlayerItem` `properties` related to buffering.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handleBufferingEvents(mediaAsset: MediaAsset<Context.Source>) {
        mediaAsset.itemObserver.observe(path: .isPlaybackLikelyToKeepUp, on: mediaAsset.playerItem) { [weak self] item, change in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                switch `self`.bufferState {
                case .buffering:
                    `self`.bufferState = .onPace
                    `self`.eventDispatcher.onBufferingStopped(`self`, mediaAsset.source)
                    mediaAsset.source.analyticsConnector.onBufferingStopped(tech: `self`, source: mediaAsset.source)
                default: return
                }
            }
        }
        
        
        mediaAsset.itemObserver.observe(path: .isPlaybackBufferFull, on: mediaAsset.playerItem) { item, change in
            DispatchQueue.main.async {
            }
        }
        
        mediaAsset.itemObserver.observe(path: .isPlaybackBufferEmpty, on: mediaAsset.playerItem) { [weak self] item, change in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                switch `self`.bufferState {
                case .onPace, .notInitialized:
                    `self`.bufferState = .buffering
                    `self`.eventDispatcher.onBufferingStarted(`self`, mediaAsset.source)
                    mediaAsset.source.analyticsConnector.onBufferingStarted(tech: `self`, source: mediaAsset.source)
                default: return
                }
            }
        }
    }
}

/// Duration Changed Events
extension HLSNative {
    /// Subscribes to and handles duration changed events by tracking the status of `AVPlayerItem.duration`. Once changes occur, `onDurationChanged:` will fire.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handleDurationChangedEvent(mediaAsset: MediaAsset<Context.Source>) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.observe(path: .duration, on: playerItem) { [weak self] item, change in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                // NOTE: This currently sends onDurationChanged events for all triggers of the KVO. This means events might be sent once duration is "updated" with the same value as before, effectivley assigning self.duration = duration.
                `self`.eventDispatcher.onDurationChanged(`self`, mediaAsset.source)
                mediaAsset.source.analyticsConnector.onDurationChanged(tech: `self`, source: mediaAsset.source)
            }
        }
    }
}

/// Playback Completed Events
extension HLSNative {
    /// Triggers `PlaybackCompleted` callbacks and analytics events.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handlePlaybackCompletedEvent(mediaAsset: MediaAsset<Context.Source>) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.subscribe(notification: .AVPlayerItemDidPlayToEndTime, for: playerItem) { [weak self] notification in
            guard let `self` = self else { return }
            `self`.eventDispatcher.onPlaybackCompleted(`self`, mediaAsset.source)
            mediaAsset.source.analyticsConnector.onCompleted(tech: `self`, source: mediaAsset.source)
        }
    }
}

/// Playback State Changes
extension HLSNative {
    /// Subscribes to and handles `AVPlayer.rate` changes.
    fileprivate func handlePlaybackStateChanges() {
        playerObserver.observe(path: .rate, on: avPlayer) { [weak self] player, change in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                guard let newRate = change.new as? Float else {
                    return
                }
                
                if newRate < 0 || 0 < newRate {
                    switch `self`.playbackState {
                    case .notStarted:
                        `self`.playbackState = .playing
                        if let source = `self`.currentAsset?.source {
                            `self`.eventDispatcher.onPlaybackStarted(`self`, source)
                            source.analyticsConnector.onStarted(tech: `self`, source: source)
                        }
                    case .paused:
                        `self`.playbackState = .playing
                        if let source = `self`.currentAsset?.source {
                            `self`.eventDispatcher.onPlaybackResumed(`self`, source)
                            source.analyticsConnector.onResumed(tech: `self`, source: source)
                        }
                    case .playing:
                        return
                    case .stopped:
                        return
                    }
                }
                else {
                    switch `self`.playbackState {
                    case .notStarted:
                        return
                    case .paused:
                        return
                    case .playing:
                        `self`.playbackState = .paused
                        if let source = `self`.currentAsset?.source {
                            `self`.eventDispatcher.onPlaybackPaused(`self`, source)
                            source.analyticsConnector.onPaused(tech: `self`, source: source)
                        }
                    case .stopped:
                        return
                    }
                }
            }
        }
    }
}

/// Current Item Changes
extension HLSNative {
    /// Subscribes to and handles `AVPlayer.currentItem` changes.
    fileprivate func handleCurrentItemChanges() {
        playerObserver.observe(path: .currentItem, on: avPlayer) { player, change in
            print("Player.currentItem changed",player, change.new, change.old)
            // TODO: Do we handle programChange here?
        }
    }
}

///// Audio Session Interruption Events
//extension HLSNative {
//    /// Subscribes to *Audio Session Interruption* `Notification`s.
//    fileprivate func handleAudioSessionInteruptionEvents() {
//        NotificationCenter.default.addObserver(self, selector: #selector(HLSNative.audioSessionInterruption), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
//    }
//
//    /// Handles *Audio Session Interruption* events by resuming playback if instructed to do so.
//    @objc fileprivate func audioSessionInterruption(notification: Notification) {
//        guard let userInfo = notification.userInfo,
//            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
//            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
//                return
//        }
//        switch type {
//        case .began:
//            print("AVAudioSessionInterruption BEGAN")
//        case .ended:
//            guard let flagsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
//            let flags = AVAudioSessionInterruptionOptions(rawValue: flagsValue)
//            print("AVAudioSessionInterruption ENDED",flags)
//            if flags.contains(.shouldResume) {
//                self.play()
//            }
//        }
//    }
//}
//
///// Backgrounding Events
//extension HLSNative {
//    /// Backgrounding the player events.
//    fileprivate func handleBackgroundingEvents() {
//        NotificationCenter.default.addObserver(self, selector: #selector(HLSNative.appDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(HLSNative.appWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(HLSNative.appWillTerminate), name: .UIApplicationWillTerminate, object: nil)
//    }
//
//    @objc fileprivate func appDidEnterBackground() {
//        print("UIApplicationDidEnterBackground")
//    }
//
//    @objc fileprivate func appWillEnterForeground() {
//        print("UIApplicationWillEnterForeground")
//    }
//
//    /// If the app is about to terminate make sure to stop playback. This will initiate teardown.
//    ///
//    /// Any attached `AnalyticsProvider` should hopefully be given enough time to finalize.
//    @objc fileprivate func appWillTerminate() {
//        print("UIApplicationWillTerminate")
//        self.stop()
//    }
//}

