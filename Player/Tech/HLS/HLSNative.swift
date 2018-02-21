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
    
    /// *Native* `AVPlayer` used for playback purposes.
    internal var avPlayer: AVPlayer {
        didSet {
            playerObserver.stopObservingAll()
            playerObserver.unsubscribeAll()
            handleCurrentItemChanges()
            handlePlaybackStateChanges()
        }
    }

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
    
    // MARK: TrackSelectable
    /// Sets the preferred audio language tag as defined by RFC 4646 standards
    public var preferredAudioLanguage: String?
    
    /// Should set the preferred text language tag as defined by RFC 4646 standards
    public var preferredTextLanguage: String?
    
    
    // MARK: MediaAsset
    /// `MediaAsset` contains and handles all information used for loading and preparing an asset.
    ///
    /// *Fairplay* protected media is processed by the supplied FairplayRequester
    internal class MediaAsset<Source: MediaSource> {
        /// Specifies the asset which is about to be loaded.
        internal var urlAsset: AVURLAsset
        
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
            urlAsset = asset
            playerItem = AVPlayerItem(asset: asset)
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
    
    /// Generates a fresh MediaAsset to use for loading and preparation of the specified `Source`.
    internal var assetGenerator: (Context.Source, HLSNativeConfiguration) -> MediaAsset<Context.Source> = { source, configuration in
        return MediaAsset<Context.Source>(source: source, configuration: configuration)
    }
    
    public required init() {
        avPlayer = AVPlayer()
        
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
    fileprivate var playerObserver: PlayerObserver = PlayerObserver()
}

// MARK: - Load Source
extension HLSNative where Context.Source: HLSNativeConfigurable {
    
    public func load(source: Context.Source, callback: @escaping () -> Void = { }) {
        loadAndPrepare(source: source, onTransitionReady: { mediaAsset in
            if let oldSource = currentAsset?.source {
                eventDispatcher.onPlaybackAborted(self, oldSource)
                oldSource.analyticsConnector.onAborted(tech: self, source: oldSource)
            }
            
            // Start notifications on new session
            // At this point the `AVURLAsset` has yet to perform async loading of values (such as `duration`, `tracks` or `playable`) through `loadValuesAsynchronously`.
            eventDispatcher.onPlaybackCreated(self, mediaAsset.source)
            mediaAsset.source.analyticsConnector.onCreated(tech: self, source: mediaAsset.source)
            
        }, onAssetPrepared: { [weak self] mediaAsset in
            guard let `self` = self else { return }
            
            self.eventDispatcher.onPlaybackPrepared(self, mediaAsset.source)
            mediaAsset.source.analyticsConnector.onPrepared(tech: self, source: mediaAsset.source)
        }, finalized: callback)
    }
    
    #if DEBUG
    /// Reloads the currently active `MediaSource`
    public func reloadSource() {
        guard let source = currentSource else { return }
        
        loadAndPrepare(source: source,
                       onTransitionReady: { _ in },
                       onAssetPrepared: { _ in },
                       finalized: { })
    }
    #endif
    
    private func loadAndPrepare(source: Context.Source,
                                onTransitionReady: ((MediaAsset<Context.Source>) -> Void),
                                onAssetPrepared: @escaping ((MediaAsset<Context.Source>) -> Void),
                                finalized: @escaping () -> Void) {
        let configuration = source.hlsNativeConfiguration
        
        let mediaAsset = assetGenerator(source, configuration)
        
        // Unsubscribe any current item
        currentAsset?.itemObserver.stopObservingAll()
        currentAsset?.itemObserver.unsubscribeAll()
        
        playbackState = .stopped
        avPlayer.pause()
        
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
            
            self.readyPlayback(with: mediaAsset, callback: finalized)
        }
    }
    
    /// Once the `MediaAsset` has been *prepared* through `mediaAsset.prepare(loading: callback:)` the relevant `KVO` and `Notificaion`s are subscribed.
    ///
    /// Finally, once the `Player` is configured, the `currentMedia` is replaced with the newly created one. The system now awaits playback status to return `.readyToPlay`.
    fileprivate func readyPlayback(with mediaAsset: MediaAsset<Context.Source>, callback: @escaping () -> Void) {
        currentAsset = nil
        
        // Observe changes to .status for new playerItem
        // We will perform "pre-load" seek of the `AVPlayerItem` to the requested *Start Time*
        handleStatusChange(mediaAsset: mediaAsset, onActive: { [weak self] in
            guard let `self` = self else { return }
            
            // `mediaAsset` is now prepared.
            self.currentAsset = mediaAsset
            
            // Replace the player item with a new player item. The item replacement occurs
            // asynchronously; observe the currentItem property to find out when the
            // replacement will/did occur
            self.avPlayer.replaceCurrentItem(with: mediaAsset.playerItem)
            
            // Apply preferred audio and subtitles
            /// NOTE: It seems we cant reliably select subs and audio until after `replaceCurrentItem(with:)` is called
            self.applyLanguagePreferences(on: mediaAsset)
        }) { [weak self] in
            guard let `self` = self else { return }
            self.playbackState = .preparing
            // Trigger on-ready callbacks and autoplay if available
            self.eventDispatcher.onPlaybackReady(self, mediaAsset.source)
            mediaAsset.source.analyticsConnector.onReady(tech: self, source: mediaAsset.source)
            if self.autoplay {
                self.play()
            }
            callback()
        }
        
        // Observe BitRate changes
        handleBitrateChangedEvent(mediaAsset: mediaAsset)
        
        // Observe Buffering
        handleBufferingEvents(mediaAsset: mediaAsset)
        
        // Observe Duration changes
        handleDurationChangedEvent(mediaAsset: mediaAsset)
        
        
        // Observe when currentItem has played to the end
        handlePlaybackCompletedEvent(mediaAsset: mediaAsset)
    }
}

// MARK: - Preferred Language
extension HLSNative {
    fileprivate func applyLanguagePreferences(on mediaAsset: MediaAsset<Context.Source>) {
        // 1. Preferred
        // 2. Default (stream based)
        // 3. None
        handle(preference: preferredTextLanguage, in: mediaAsset.playerItem.textGroup, for: mediaAsset)
        handle(preference: preferredAudioLanguage, in: mediaAsset.playerItem.audioGroup, for: mediaAsset)
    }
    
    private func handle(preference: String?,  in group: MediaGroup?, for mediaAsset: MediaAsset<Context.Source>) {
        guard let group = group else { return }
        if let preferedLanguage = preference, let preferedOption = group.mediaSelectionOption(forLanguage: preferedLanguage) {
            mediaAsset.playerItem.select(preferedOption, in: group.mediaGroup)
        }
        else if let defaultTrack = group.defaultTrack {
            mediaAsset.playerItem.select(defaultTrack.mediaOption, in: group.mediaGroup)
        }
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
extension HLSNative {
    /// Subscribes to and handles changes in `AVPlayerItem.status`
    ///
    /// This is the final step in the initialization process. Either the playback is ready to start at the specified *start time* or an error has occured. The specified start time may be at the start of the stream if `StartTime` is not used.
    ///
    /// If `autoplay` has been specified as `true`, playback will commence right after `.readyToPlay`.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handleStatusChange(mediaAsset: MediaAsset<Context.Source>, onActive: @escaping () -> Void, onReady: @escaping () -> Void) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.observe(path: .status, on: playerItem) { [weak self] item, change in
            guard let `self` = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                if let newValue = change.new as? Int, let status = AVPlayerItemStatus(rawValue: newValue) {
                    switch status {
                    case .unknown:
                        switch self.playbackState {
                        case .notStarted:
                            // Prepare the `AVPlayerItem` by seeking to the required startTime before we perform any loading or networking.
                            // We cant set the start time as a unix timestamp at this point since the `playerItem` has not yet loaded the manifest and does
                            // yet know the stream is *timestamp related*. Wait untill playback is ready to do that.
                            //
                            // BUGFIX: We cant trigger `onReady` here since that will trigger `onPlaybackStarted` before we have the manifest loaded. This will cause onPlaybackStarted for Date-Time associated streams to report playback position `nil/0` since the playheadTime cant associate bufferPosition with the manifest stream start.
                            if case let .startPosition(value) = self.startOffset {
                                // BUGFIX: AVPlayerItem CANT service a seek with a completion handler untill state == .readyToPlay
                                let cmTime = CMTime(value: value, timescale: 1000)
                                mediaAsset.playerItem.seek(to: cmTime)
                            }
                            onActive()
                        default: return
                        }
                    case .readyToPlay:
                        switch self.playbackState {
                        case .notStarted:
                            // The `playerItem` should now be associated with `avPlayer` and the manifest should be loaded. We now have access to the *timestmap related* functionality and can set startTime to a unix timestamp
                            if case .startPosition(_) = self.startOffset {
                                // This has been handled before
                                onReady()
                            }
                            else if case let .startTime(value) = self.startOffset {
                                let time = CMTime(value: value, timescale: 1000)
                                let inRange = self.seekableTimeRanges.reduce(false) { $0 || $1.containsTime(time) }
                                
                                guard inRange else {
                                    self.process(warning: .invalidStartTime(startTime: value, seekableRanges: self.seekableTimeRanges))
                                    onReady()
                                    return
                                }
                                let date = Date(milliseconds: value)
                                mediaAsset.playerItem.seek(to: date) { success in
                                    // TODO: What if the seek was not successful?
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
                        self.eventDispatcher.onError(self, mediaAsset.source, techError)
                        mediaAsset.source.analyticsConnector.onError(tech: self, source: mediaAsset.source, error: techError)
                    }
                }
            }
        }
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
            if let item = notification.object as? AVPlayerItem, let events = item.accessLog()?.events {
                let newBitrateGenerator: () -> Double? = {
                    if events.count == 1 {
                        return events.last?.indicatedBitrate
                    }
                    else {
                        let currentBitrate = events.last?.indicatedBitrate
                        let previous = events[events.count-2].indicatedBitrate
                        return currentBitrate != previous ? currentBitrate : nil
                    }
                }
                
                if let newBitrate = newBitrateGenerator() {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        self.eventDispatcher.onBitrateChanged(self, mediaAsset.source, newBitrate)
                        mediaAsset.source.analyticsConnector.onBitrateChanged(tech: self, source: mediaAsset.source, bitrate: newBitrate)
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
            if item.isPlaybackLikelyToKeepUp && !change.isPrior {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    switch self.bufferState {
                    case .buffering:
                        self.bufferState = .onPace
                        self.eventDispatcher.onBufferingStopped(self, mediaAsset.source)
                        mediaAsset.source.analyticsConnector.onBufferingStopped(tech: self, source: mediaAsset.source)
                    default: return
                    }
                }
            }
        }
        
        
        mediaAsset.itemObserver.observe(path: .isPlaybackBufferFull, on: mediaAsset.playerItem) { item, change in
            
        }
        
        mediaAsset.itemObserver.observe(path: .isPlaybackBufferEmpty, on: mediaAsset.playerItem) { [weak self] item, change in
            guard let `self` = self else { return }
            if item.isPlaybackBufferEmpty && !change.isPrior {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    switch self.bufferState {
                    case .onPace, .notInitialized:
                        self.bufferState = .buffering
                        self.eventDispatcher.onBufferingStarted(self, mediaAsset.source)
                        mediaAsset.source.analyticsConnector.onBufferingStarted(tech: self, source: mediaAsset.source)
                    default: return
                    }
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
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                // NOTE: This currently sends onDurationChanged events for all triggers of the KVO. This means events might be sent once duration is "updated" with the same value as before, effectivley assigning self.duration = duration.
                self.eventDispatcher.onDurationChanged(self, mediaAsset.source)
                mediaAsset.source.analyticsConnector.onDurationChanged(tech: self, source: mediaAsset.source)
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
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.eventDispatcher.onPlaybackCompleted(self, mediaAsset.source)
                mediaAsset.source.analyticsConnector.onCompleted(tech: self, source: mediaAsset.source)
                self.unloadOnStop()
            }
        }
    }
}

/// Playback State Changes
extension HLSNative {
    /// Subscribes to and handles `AVPlayer.rate` changes.
    fileprivate func handlePlaybackStateChanges() {
        playerObserver.observe(path: .rate, on: avPlayer) { [weak self] player, change in
            guard let `self` = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
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
        playerObserver.observe(path: .currentItem, on: avPlayer) { player, change in
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

