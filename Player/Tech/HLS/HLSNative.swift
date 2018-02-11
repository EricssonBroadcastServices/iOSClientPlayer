//
//  HLSNative.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import AVFoundation

/// Defines a protocol enabling adopters to create the configuration source for a `HLSNative` *tech*.
public protocol HLSNativeConfigurable {
    var hlsNativeConfiguration: HLSNativeConfiguration { get }
}

/// Playback configuration specific for the `HLSNative` *tech*.
public struct HLSNativeConfiguration {
    /// Media locator for the media source
    public let url: URL
    
    /// Unique playsession id
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
    public typealias TechWarning = HLSNativeWarning
    
    public var eventDispatcher: EventDispatcher<Context, HLSNative<Context>> = EventDispatcher()
    
    /// Returns the currently active `MediaSource` if available.
    public var currentSource: Context.Source? {
        return currentAsset?.source
    }
    
    /// Media Player used to control playback. By default this is the *Native* `AVPlayer`.
    internal var srcPlayer: AVPlayer
    
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
        case preparing
        case playing
        case paused
        case stopped
    }
    
    /// Storage for autoplay toggle
    public var autoplay: Bool = false
    
    // MARK: StartTime
    /// Private state tracking `StartTime` status. It should not be exposed externally.
    internal var startOffset: StartOffset = .defaultStartTime
    
    // Background notifier
    internal let backgroundWatcher = BackgroundWatcher()
    
    /// `MediaAsset` contains and handles all information used for loading and preparing an asset.
    ///
    /// *Fairplay* protected media is processed by the supplied FairplayRequester
    internal class MediaAsset<Source: MediaSource> {
        /// Specifies the asset which is about to be loaded.
        fileprivate var urlAsset: AVURLAsset
        
        /// AVPlayerItem models the timing and presentation state of an asset played by an AVPlayer object. It provides the interface to seek to various times in the media, determine its presentation size, identify its current time, and much more.
        internal var playerItem: AVPlayerItem
        
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
            
            let asset = AVURLAsset(url: configuration.url)
            if fairplayRequester != nil {
                asset.resourceLoader.setDelegate(fairplayRequester,
                                                 queue: DispatchQueue(label: configuration.playSessionId + "-fairplayLoader"))
            }
            playerItem = AVPlayerItem(asset: asset)
            urlAsset = asset
        }
        
        // MARK: Change Observation
        /// Wrapper observing changes to the underlying `AVPlayerItem`
        lazy internal var itemObserver: PlayerItemObserver = { [unowned self] in
            return PlayerItemObserver()
            }()
        
        deinit {
            print("MediaAsset deinit")
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
        srcPlayer = AVPlayer()
        
        handleCurrentItemChanges()
        handlePlaybackStateChanges()
        
        backgroundWatcher.handleWillTerminate { [weak self] in self?.stop() }
        backgroundWatcher.handleWillBackgrounding { }
        backgroundWatcher.handleDidEnterBackgrounding { }
        backgroundWatcher.handleAudioSessionInteruption { [weak self] event in
            switch event {
            case .began: return
            case .ended(shouldResume: let shouldResume):
                if shouldResume { self?.play() }
            }
        }
    }
    
    deinit {
        print("HLSNative.deinit")
        playerObserver.stopObservingAll()
        playerObserver.unsubscribeAll()
        stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    /// Wrapper observing changes to the underlying `AVPlayer`
    lazy fileprivate var playerObserver: PlayerObserver = {
        return PlayerObserver()
    }()
}

// MARK: - Load Source
extension HLSNative where Context.Source: HLSNativeConfigurable {
    
    public func load(source: Context.Source) {
        loadAndPrepare(source: source, onTransitionReady: { mediaAsset in
            if let oldSource = currentAsset?.source {
                eventDispatcher.onPlaybackAborted(self, oldSource)
                oldSource.analyticsConnector.onAborted(tech: self, source: oldSource)
            }
            
            // Start notifications on new session
            // At this point the `AVURLAsset` has yet to perform async loading of values (such as `duration`, `tracks` or `playable`) through `loadValuesAsynchronously`.
            eventDispatcher.onPlaybackCreated(self, mediaAsset.source)
            mediaAsset.source.analyticsConnector.onCreated(tech: self, source: mediaAsset.source)
            
        }) { mediaAsset in
            self.eventDispatcher.onPlaybackPrepared(self, mediaAsset.source)
            mediaAsset.source.analyticsConnector.onPrepared(tech: self, source: mediaAsset.source)
        }
    }
    
    #if DEBUG
    /// Reloads the currently active `MediaSource`
    public func reloadSource() {
        guard let source = currentSource else { return }
        
        loadAndPrepare(source: source)
    }
    #endif
    
    private func loadAndPrepare(source: Context.Source,
                                onTransitionReady: ((MediaAsset<Context.Source>) -> Void) = { _ in },
                                onAssetPrepared: @escaping((MediaAsset<Context.Source>) -> Void) = { _ in }) {
        let configuration = source.hlsNativeConfiguration
        
        let mediaAsset = MediaAsset<Context.Source>(source: source, configuration: configuration)
        
        // Unsubscribe any current item
        currentAsset?.itemObserver.stopObservingAll()
        currentAsset?.itemObserver.unsubscribeAll()
        
        playbackState = .stopped
        srcPlayer.pause()
        
        // Fire the transition callback
        onTransitionReady(mediaAsset)
        
        // Reset playbackState
        playbackState = .notStarted
        
        mediaAsset.prepare(loading: [.duration, .tracks, .playable]) { [weak self] error in
            guard let `self` = self else { return }
            guard error == nil else {
                let techError = PlayerError<HLSNative<Context>,Context>.tech(error: error!)
                self.eventDispatcher.onError(self, mediaAsset.source, techError)
                mediaAsset.source.analyticsConnector.onError(tech: self, source: mediaAsset.source, error: techError)
                return
            }
            // At this point event listeners (*KVO* and *Notifications*) for the media in preparation have not registered. `AVPlayer` has not yet replaced the current (if any) `AVPlayerItem`.
            onAssetPrepared(mediaAsset)
            
            self.readyPlayback(with: mediaAsset)
        }
    }
    
    /// Once the `MediaAsset` has been *prepared* through `mediaAsset.prepare(loading: callback:)` the relevant `KVO` and `Notificaion`s are subscribed.
    ///
    /// Finally, once the `Player` is configured, the `currentMedia` is replaced with the newly created one. The system now awaits playback status to return `.readyToPlay`.
    fileprivate func readyPlayback(with mediaAsset: MediaAsset<Context.Source>) {
        currentAsset = nil
        
        // Observe changes to .status for new playerItem
        // We will perform "pre-load" seek of the `AVPlayerItem` to the requested *Start Time*
        mediaAsset.handleStatusChange(tech: self, onActive: { [weak self] in
            guard let `self` = self else { return }
            
            
            // `mediaAsset` is now prepared.
            self.currentAsset = mediaAsset
            
            // Replace the player item with a new player item. The item replacement occurs
            // asynchronously. Observe the currentItem property to find out when the
            // replacement will/did occur
            self.srcPlayer.replaceCurrentItem(with: mediaAsset.playerItem)
        }) { [weak self] in
            guard let `self` = self else { return }
            self.playbackState = .preparing
            // Trigger on-ready callbacks and autoplay if available
            self.eventDispatcher.onPlaybackReady(self, mediaAsset.source)
            mediaAsset.source.analyticsConnector.onReady(tech: self, source: mediaAsset.source)
            if self.autoplay {
                self.play()
            }
        }
        
        // Observe BitRate changes
        mediaAsset.handleBitrateChangedEvent(tech: self)
        
        // Observe Buffering
        mediaAsset.handleBufferingEvents(tech: self)
        
        // Observe Duration changes
        mediaAsset.handleDurationChangedEvent(tech: self)
        
        
        // Observe when currentItem has played to the end
        mediaAsset.handlePlaybackCompletedEvent(tech: self)
    }
}

// MARK: - Manifest Data
extension HLSNative {
    /// Returns the playback type if available, else `nil`.
    ///
    /// Valid types include:
    ///     * Live
    ///     * VOD
    ///     * File
    public var playbackType: String? {
        return currentAsset?.playerItem
            .accessLog()?
            .events
            .last?
            .playbackType
    }
}


// MARK: - Warnings
extension HLSNative {
    public func process(warning: HLSNativeWarning) {
//        if logWarnings {
        eventDispatcher.onWarning(self, currentSource, .tech(warning: warning))
//        }
    }
}

// MARK: - Events
/// Player Item Status Change Events
extension HLSNative.MediaAsset {
    /// Subscribes to and handles changes in `AVPlayerItem.status`
    ///
    /// This is the final step in the initialization process. Either the playback is ready to start at the specified *start time* or an error has occured. The specified start time may be at the start of the stream if `StartTime` is not used.
    ///
    /// If `autoplay` has been specified as `true`, playback will commence right after `.readyToPlay`.
    ///
    /// - parameter mediaAsset: tech to handle the callback event
    func handleStatusChange<Context>(tech: HLSNative<Context>, onActive: @escaping () -> Void, onReady: @escaping () -> Void) where Context.Source == Source {
        itemObserver.observe(path: .status, on: playerItem) { [weak self, weak tech, weak playerItem] item, change in
            guard let `self` = self, let tech = tech, let playerItem = playerItem else { return }
            DispatchQueue.main.async {
                if let newValue = change.new as? Int, let status = AVPlayerItemStatus(rawValue: newValue) {
                    switch status {
                    case .unknown:
                        switch tech.playbackState {
                        case .notStarted:
                            // Prepare the `AVPlayerItem` by seeking to the required startTime before we perform any loading or networking.
                            // We cant set the start time as a unix timestamp at this point since the `playerItem` has not yet loaded the manifest and does
                            // yet know the stream is *timestamp related*. Wait untill playback is ready to do that.
                            //
                            // BUGFIX: We cant trigger `onReady` here since that will trigger `onPlaybackStarted` before we have the manifest loaded. This will cause onPlaybackStarted for Date-Time associated streams to report playback position `nil/0` since the playheadTime cant associate bufferPosition with the manifest stream start.
                            if case let .startPosition(value) = tech.startOffset {
                                let cmTime = CMTime(value: value, timescale: 1000)
                                playerItem.seek(to: cmTime) { success in
                                    // TODO: What if the seek was not successful?
                                    print("<< .notStarted startPosition Seek",success)
                                    onActive()
                                }
                            }
                            else {
                                onActive()
                            }
                        default: return
                        }
                    case .readyToPlay:
                        switch tech.playbackState {
                        case .notStarted:
                            // The `playerItem` should now be associated with `avPlayer` and the manifest should be loaded. We now have access to the *timestmap related* functionality and can set startTime to a unix timestamp
                            if case .startPosition(_) = tech.startOffset {
                                // This has been handled before
                                onReady()
                            }
                            else if case let .startTime(value) = tech.startOffset {
                                let time = CMTime(value: value, timescale: 1000)
                                let inRange = tech.seekableTimeRanges.reduce(false) { $0 || $1.containsTime(time) }
                                
                                guard inRange else {
                                    tech.process(warning: .invalidStartTime(startTime: value, seekableRanges: tech.seekableTimeRanges))
                                    onReady()
                                    return
                                }
                                let date = Date(milliseconds: value)
                                playerItem.seek(to: date) { success in
                                    // TODO: What if the seek was not successful?
                                    print("<< .readyToPlay startTime Seek",success)
                                    onReady()
                                }
                            }
                            else {
                                onReady()
                            }
                        default:
                            return
                        }
                    case .failed:
                        let techError = PlayerError<HLSNative<Context>,Context>.tech(error: HLSNativeError.failedToReady(error: item.error))
                        tech.eventDispatcher.onError(tech, self.source, techError)
                        self.source.analyticsConnector.onError(tech: tech, source: self.source, error: techError)
                    }
                }
            }
        }
    }
}

/// Bitrate Changed Events
extension HLSNative.MediaAsset {
    /// Subscribes to and handles bitrate changes accessed through `AVPlayerItem`s `AVPlayerItemNewAccessLogEntry`.
    ///
    /// - parameter mediaAsset: tech to handle the callback event
    func handleBitrateChangedEvent<Context>(tech: HLSNative<Context>) where Context.Source == Source {
        itemObserver.subscribe(notification: .AVPlayerItemNewAccessLogEntry, for: playerItem) { [weak self, weak tech] notification in
            guard let `self` = self, let tech = tech else { return }
            if let item = notification.object as? AVPlayerItem, let accessLog = item.accessLog() {
                if let currentEvent = accessLog.events.last {
                    let newBitrate = currentEvent.indicatedBitrate
                    DispatchQueue.main.async {
                        tech.eventDispatcher.onBitrateChanged(tech, self.source, newBitrate)
                        self.source.analyticsConnector.onBitrateChanged(tech: tech, source: self.source, bitrate: newBitrate)
                    }
                }
            }
        }
    }
}

/// Buffering Events
extension HLSNative.MediaAsset {
    /// Subscribes to and handles buffering events by tracking the status of `AVPlayerItem` `properties` related to buffering.
    ///
    /// - parameter mediaAsset: tech to handle the callback event
    func handleBufferingEvents<Context>(tech: HLSNative<Context>) where Context.Source == Source {
        itemObserver.observe(path: .isPlaybackLikelyToKeepUp, on: playerItem) { [weak self, weak tech] item, change in
            guard let `self` = self, let tech = tech else { return }
            DispatchQueue.main.async {
                switch tech.bufferState {
                case .buffering:
                    tech.bufferState = .onPace
                    tech.eventDispatcher.onBufferingStopped(tech, self.source)
                    self.source.analyticsConnector.onBufferingStopped(tech: tech, source: self.source)
                default: return
                }
            }
        }
        
        
        itemObserver.observe(path: .isPlaybackBufferFull, on: playerItem) { item, change in
            DispatchQueue.main.async {
            }
        }
        
        itemObserver.observe(path: .isPlaybackBufferEmpty, on: playerItem) { [weak self, weak tech] item, change in
            guard let `self` = self, let tech = tech else { return }
            DispatchQueue.main.async {
                switch tech.bufferState {
                case .onPace, .notInitialized:
                    tech.bufferState = .buffering
                    tech.eventDispatcher.onBufferingStarted(tech, self.source)
                    self.source.analyticsConnector.onBufferingStarted(tech: tech, source: self.source)
                default: return
                }
            }
        }
    }
}

/// Duration Changed Events
extension HLSNative.MediaAsset {
    /// Subscribes to and handles duration changed events by tracking the status of `AVPlayerItem.duration`. Once changes occur, `onDurationChanged:` will fire.
    ///
    /// - parameter tech: tech to handle the callback event
    func handleDurationChangedEvent<Context>(tech: HLSNative<Context>) where Context.Source == Source {
        itemObserver.observe(path: .duration, on: playerItem) { [weak self, weak tech] item, change in
            guard let `self` = self, let tech = tech else { return }
            DispatchQueue.main.async {
                // NOTE: This currently sends onDurationChanged events for all triggers of the KVO. This means events might be sent once duration is "updated" with the same value as before, effectivley assigning self.duration = duration.
                tech.eventDispatcher.onDurationChanged(tech, self.source)
                self.source.analyticsConnector.onDurationChanged(tech: tech, source: self.source)
            }
        }
    }
}

/// Playback Completed Events
extension HLSNative.MediaAsset {
    /// Triggers `PlaybackCompleted` callbacks and analytics events.
    ///
    /// - parameter tech: tech to handle the callback event
    func handlePlaybackCompletedEvent<Context>(tech: HLSNative<Context>) where Context.Source == Source {
        itemObserver.subscribe(notification: .AVPlayerItemDidPlayToEndTime, for: playerItem) { [weak self, weak tech] notification in
            guard let `self` = self, let tech = tech else { return }
            DispatchQueue.main.async {
                tech.eventDispatcher.onPlaybackCompleted(tech, self.source)
                self.source.analyticsConnector.onCompleted(tech: tech, source: self.source)
                tech.unloadOnStop()
            }
        }
    }
}

// MARK: State Changes
/// Playback State Changes
extension HLSNative {
    /// Subscribes to and handles `AVPlayer.rate` changes.
    fileprivate func handlePlaybackStateChanges() {
        playerObserver.observe(path: .rate, on: srcPlayer) { [weak self] player, change in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                guard let newRate = change.new as? Float else {
                    return
                }
                
                if newRate < 0 || 0 < newRate {
                    switch self.playbackState {
                    case .notStarted:
                        return
                    case .preparing:
                        self.playbackState = .playing
                        if let source = self.currentAsset?.source {
                            self.eventDispatcher.onPlaybackStarted(self, source)
                            source.analyticsConnector.onStarted(tech: self, source: source)
                        }
                    case .paused:
                        self.playbackState = .playing
                        if let source = self.currentAsset?.source {
                            self.eventDispatcher.onPlaybackResumed(self, source)
                            source.analyticsConnector.onResumed(tech: self, source: source)
                        }
                    case .playing:
                        return
                    case .stopped:
                        return
                    }
                }
                else {
                    switch self.playbackState {
                    case .notStarted:
                        return
                    case .preparing:
                        return
                    case .paused:
                        return
                    case .playing:
                        self.playbackState = .paused
                        if let source = self.currentAsset?.source {
                            self.eventDispatcher.onPlaybackPaused(self, source)
                            source.analyticsConnector.onPaused(tech: self, source: source)
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
        playerObserver.observe(path: .currentItem, on: srcPlayer) { player, change in
            print("Player.currentItem changed",player, change.new ?? "nil", change.old ?? "nil")
        }
    }
}

/// Audio Session Interruption Events
internal class BackgroundWatcher {
    internal enum AudioSessionInterruption {
        case began
        case ended(shouldResume: Bool)
    }
    
    /// Closure to fire when *Audio Session Interruption* `Notification`s fire.
    fileprivate var onAudioSessionInterruption: (AudioSessionInterruption) -> Void = { _ in }
    
    /// Closure to fire when the app is about to enter foreground
    fileprivate var onWillEnterForeground: () -> Void = { }
    
    /// Closure to fire when the app enters background
    fileprivate var onDidEnterBackground: () -> Void = { }
    
    /// Closure to fire when the app is about to terminate
    fileprivate var onWillTerminate: () -> Void = { }
    
    /// Subscribes to *Audio Session Interruption* `Notification`s.
    internal func handleAudioSessionInteruption(callback: @escaping (AudioSessionInterruption) -> Void) {
        onAudioSessionInterruption = callback
        NotificationCenter.default.addObserver(self, selector: #selector(BackgroundWatcher.audioSessionInterruption), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
    }

    /// Handles *Audio Session Interruption* events by resuming playback if instructed to do so.
    @objc internal func audioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        switch type {
        case .began:
            onAudioSessionInterruption(.began)
        case .ended:
            guard let flagsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let flags = AVAudioSessionInterruptionOptions(rawValue: flagsValue)
            onAudioSessionInterruption(.ended(shouldResume: flags.contains(.shouldResume)))
        }
    }
}

/// Backgrounding Events
extension BackgroundWatcher {
    /// Backgrounding the player events.
    internal func handleDidEnterBackgrounding(callback: @escaping () -> Void) {
        onDidEnterBackground = callback
        NotificationCenter.default.addObserver(self, selector: #selector(BackgroundWatcher.appDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
    }
    internal func handleWillBackgrounding(callback: @escaping () -> Void) {
        onWillEnterForeground = callback
        NotificationCenter.default.addObserver(self, selector: #selector(BackgroundWatcher.appWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    internal func handleWillTerminate(callback: @escaping () -> Void) {
        onWillTerminate = callback
        NotificationCenter.default.addObserver(self, selector: #selector(BackgroundWatcher.appWillTerminate), name: .UIApplicationWillTerminate, object: nil)
    }

    @objc internal func appDidEnterBackground() {
        onDidEnterBackground()
    }

    @objc internal func appWillEnterForeground() {
        onWillEnterForeground()
    }

    /// If the app is about to terminate make sure to stop playback. This will initiate teardown.
    ///
    /// Any attached `AnalyticsProvider` should hopefully be given enough time to finalize.
    @objc internal func appWillTerminate() {
        onWillTerminate()
    }
}

