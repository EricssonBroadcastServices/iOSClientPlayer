//
//  HLSNative.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import AVFoundation

public class HLSNative<Source: MediaSource>: Tech<Source> {
    
    //    fileprivate var currentSource:
    public override func load(source: Source) {
        let drm = source.externalDrmAgent as? FairplayRequester
        let mediaAsset = MediaAsset<Source>(source: source)
        
        // Unsubscribe any current item
        currentAsset?.itemObserver.stopObservingAll()
        currentAsset?.itemObserver.unsubscribeAll()
        
        // THIS IS WHERE WE TRIGGER ASSET CHANGE CALLBACK
        
        // TODO: Stop playback?
        playbackState = .stopped
        avPlayer.pause()
        if let oldSource = currentAsset?.source { oldSource.analyticsConnector.onAborted(tech: self, source: oldSource) }
        
        // Start notifications on new session
        onPlaybackCreated(self)
        mediaAsset.source.analyticsConnector.onCreated(tech: self, source: mediaAsset.source)
        
        // Reset playbackState
        playbackState = .notStarted
        
        mediaAsset.prepare(loading: [.duration, .tracks, .playable]) { [weak self] error in
            guard let `self` = self else { return }
            guard error == nil else {
                `self`.handle(error: error!, for: mediaAsset)
                return
            }
            
            `self`.onPlaybackPrepared(`self`)
            mediaAsset.source.analyticsConnector.onPaused(tech: `self`, source: mediaAsset.source)
            
            `self`.readyPlayback(with: mediaAsset)
        }
    }
    
    /// *Native* `AVPlayer` used for playback purposes.
    fileprivate var avPlayer: AVPlayer
    
    /// The currently active `MediaAsset` is stored here.
    ///
    /// This may be `nil` due to several reasons, for example before any media is loaded.
    fileprivate var currentAsset: MediaAsset<Source>?
    
    /// `BufferState` is a private state tracking buffering events. It should not be exposed externally.
    fileprivate var bufferState: BufferState = .notInitialized
    
    /// `PlaybackState` is a private state tracker and should not be exposed externally.
    fileprivate var playbackState: PlaybackState = .notStarted
    
    public override init() {
        super.init()
        avPlayer = AVPlayer()
        
        handleCurrentItemChanges()
        handlePlaybackStateChanges()
        handleAudioSessionInteruptionEvents()
        handleBackgroundingEvents()
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
    
    
    /// Once the `MediaAsset` has been *prepared* through `mediaAsset.prepare(loading: callback:)` the relevant `KVO` and `Notificaion`s are subscribed.
    ///
    /// Finally, once the `Player` is configured, the `currentMedia` is replaced with the newly created one. The system now awaits playback status to return `.readyToPlay`.
    fileprivate func readyPlayback(with mediaAsset: MediaAsset<Source>) {
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
        /// - parameter mediaLocator: *Path* to where the media is located
        /// - parameter analyticsConnector: Delivers analytics per media session
        /// - parameter fairplayRequester: Will handle *Fairplay* `DRM`
        /// - throws: `PlayerError` if configuration is faulty or incomplete.
        internal init(source: Source) {
            self.source = source
            let drmAgent = source.externalDrmAgent as? FairplayRequester
            self.fairplayRequester = drmAgent
            
            urlAsset = AVURLAsset(url: source.url)
            if fairplayRequester != nil {
                urlAsset.resourceLoader.setDelegate(fairplayRequester,
                                                    queue: DispatchQueue(label: source.playSessionId + "-fairplayLoader"))
            }
        }
        
        //        internal init(avUrlAsset: AVURLAsset, fairplayRequester: FairplayRequester? = nil, analyticsProvider: AnalyticsProvider? = nil, playSessionId: String? = nil) {
        //            self.fairplayRequester = fairplayRequester
        //
        //            urlAsset = avUrlAsset
        //            if fairplayRequester != nil {
        //                urlAsset.resourceLoader.setDelegate(fairplayRequester,
        //                                                    queue: DispatchQueue(label: avUrlAsset.url.relativePath + "-fairplayLoader"))
        //            }
        //        }
        
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
        internal func prepare(loading keys: [AVAsset.LoadableKeys], callback: @escaping (PlayerError?) -> Void) {
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
                        callback(.asset(reason: .failedToPrepare(errors: errors)))
                        return
                    }
                    
                    guard let isPlayable = self?.urlAsset.isPlayable, isPlayable else {
                        callback(.asset(reason: .loadedButNotPlayable))
                        return
                    }
                    
                    // Success
                    callback(nil)
                }
            }
        }
    }
    
    // MARK: - MediaRendering
    /// Creates and configures the associated `CALayer` used to render the media output. This view will be added to the *user supplied* `playerView` as a sub view at `index: 0`. A strong reference to `playerView` is also established.
    ///
    /// - parameter playerView:  *User supplied* view to configure for playback rendering.
    override public func configure(playerView: UIView) {
        configureRendering{
            let renderingView = PlayerView(frame: playerView.frame)
            
            renderingView.avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            renderingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            playerView.insertSubview(renderingView, at: 0)
            
            renderingView
                .leadingAnchor
                .constraint(equalTo: playerView.leadingAnchor)
                .isActive = true
            renderingView
                .topAnchor
                .constraint(equalTo: playerView.topAnchor)
                .isActive = true
            renderingView
                .rightAnchor
                .constraint(equalTo: playerView.rightAnchor)
                .isActive = true
            renderingView
                .bottomAnchor
                .constraint(equalTo: playerView.bottomAnchor)
                .isActive = true
            
            return renderingView.avPlayerLayer
        }
    }
    
    /// This method allows for advanced configuration of the playback rendering.
    ///
    /// The caller is responsible for creating, configuring and retaining the related constituents. End by returning an `AVPlayerLayer` in which the rendering should take place.
    ///
    /// - parameter callback: closure detailing the custom rendering. Must return an `AVPlayerLayer` in which the rendering will take place
    public func configureRendering(closure: () -> AVPlayerLayer) {
        let layer = closure()
        layer.player = avPlayer
    }
    
    // MARK: - MediaPlayback
    /// Internal state for tracking playback.
    fileprivate enum PlaybackState {
        case notStarted
        case playing
        case paused
        case stopped
    }
    
    /// Starts or resumes playback.
    override public func play() {
        switch playbackState {
        case .notStarted:
            avPlayer.play()
        case .paused:
            avPlayer.play()
        default:
            return
        }
    }
    
    /// Pause playback if currently active
    override public func pause() {
        guard isPlaying else { return }
        avPlayer.pause()
    }
    
    /// Stops playback. This will trigger `PlaybackAborted` callbacks and analytics publication.
    override public func stop() {
        // TODO: End playback? Unload resources? Leave that to user?
        switch playbackState {
        case .stopped:
            return
        default:
            avPlayer.pause()
            playbackState = .stopped
            onPlaybackAborted(self)
            if let source = currentAsset?.source { source.analyticsConnector.onAborted(tech: self, source: source) }
        }
    }
    
    /// Returns true if playback has been started and the current rate is not equal to 0
    override public var isPlaying: Bool {
        guard isActive else { return false }
        // TODO: How does this relate to PlaybackState? NOT good practice with the currently uncoupled behavior.
        return avPlayer.rate != 0
    }
    
    /// Returns true if playback has been started, but makes no assumtions regarding the playback rate.
    private var isActive: Bool {
        switch playbackState {
        case .paused: return true
        case .playing: return true
        default: return false
        }
    }
    
    /// Use this method to seek to a specified time in the media timeline. The seek request will fail if interrupted by another seek request or by any other operation.
    ///
    /// - Parameter timeInterval: in milliseconds
    override public func seek(to timeInterval: Int64) {
        let seekTime = timeInterval > 0 ? timeInterval : 0
        let cmTime = CMTime(value: seekTime, timescale: 1000)
        currentAsset?.playerItem.seek(to: cmTime) { [weak self] success in
            guard let `self` = self else { return }
            if success {
                `self`.onPlaybackScrubbed(`self`, seekTime)
                if let source = `self`.currentAsset?.source { source.analyticsConnector.onScrubbedTo(tech: `self`, source: source, offset: seekTime) }
            }
        }
    }
    
    /// Returns the current playback position of the player in *milliseconds*
    override public var currentTime: Int64 {
        guard let cmTime = currentAsset?.playerItem.currentTime() else { return 0 }
        return Int64(cmTime.seconds*1000)
    }
    
    /// Returns the current playback position of the player in *milliseconds*, or `nil` if duration is infinite (live streams for example).
    override public var duration: Int64? {
        guard let cmTime = currentAsset?.playerItem.duration else { return nil }
        guard !cmTime.isIndefinite else { return nil }
        return Int64(cmTime.seconds*1000)
    }
    
    /// The throughput required to play the stream, as advertised by the server, in *bits per second*. Will return nil if no bitrate can be reported.
    override public var currentBitrate: Double? {
        return currentAsset?
            .playerItem
            .accessLog()?
            .events
            .last?
            .indicatedBitrate
        
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
    fileprivate func handleStatusChange(mediaAsset: MediaAsset<Source>) {
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
                    let error = PlayerError.asset(reason: .failedToReady(error: item.error))
                    `self`.handle(error: error, for: mediaAsset)
                }
            }
        }
    }
    
    /// Private function to trigger the necessary final events right before playback starts.
    private func startPlayback() {
        self.onPlaybackReady(self)
        if let source = currentAsset?.source { source.analyticsConnector.onReady(tech: self, source: source) }
        
        // Start playback if autoplay is enabled
        if self.autoplay { self.play() }
    }
}

/// Bitrate Changed Events
extension HLSNative {
    /// Subscribes to and handles bitrate changes accessed through `AVPlayerItem`s `AVPlayerItemNewAccessLogEntry`.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handleBitrateChangedEvent(mediaAsset: MediaAsset<Source>) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.subscribe(notification: .AVPlayerItemNewAccessLogEntry, for: playerItem) { [weak self] notification in
            guard let `self` = self else { return }
            if let item = notification.object as? AVPlayerItem, let accessLog = item.accessLog() {
                if let currentEvent = accessLog.events.last {
                    let previousIndex = accessLog
                        .events
                        .index(of: currentEvent)?
                        .advanced(by: -1)
                    let previousEvent = previousIndex != nil ? accessLog.events[previousIndex!] : nil
                    let newBitrate = currentEvent.indicatedBitrate
                    DispatchQueue.main.async {
                        self.onBitrateChanged(event)
                        if let source = `self`.currentAsset?.source { source.analyticsConnector.onBitrateChanged(tech: `self`, source: source, bitrate: newBitrate) }
                    }
                }
            }
        }
    }
}

/// Buffering Events
extension HLSNative {
    /// Private buffer state
    fileprivate enum BufferState {
        /// Buffering has not been started yet.
        case notInitialized
        
        /// Currently buffering
        case buffering
        
        /// Buffer has enough data to keep up with playback.
        case onPace
    }
    
    /// Subscribes to and handles buffering events by tracking the status of `AVPlayerItem` `properties` related to buffering.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handleBufferingEvents(mediaAsset: MediaAsset<Source>) {
        mediaAsset.itemObserver.observe(path: .isPlaybackLikelyToKeepUp, on: mediaAsset.playerItem) { [weak self] item, change in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                switch `self`.bufferState {
                case .buffering:
                    `self`.bufferState = .onPace
                    `self`.onBufferingStopped(`self`)
                    if let source = `self`.currentAsset?.source { source.analyticsConnector.onBufferingStopped(tech: `self`, source: source) }
                default: return
                }
            }
        }
        
        
        mediaAsset.itemObserver.observe(path: .isPlaybackBufferFull, on: mediaAsset.playerItem) { item, change in
            DispatchQueue.main.async {
            }
        }
        
        mediaAsset.itemObserver.observe(path: .isPlaybackBufferEmpty, on: mediaAsset.playerItem) { [unowned self] item, change in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                switch `self`.bufferState {
                case .onPace, .notInitialized:
                    `self`.bufferState = .buffering
                    `self`.onBufferingStarted(`self`)
                    if let source = `self`.currentAsset?.source { source.analyticsConnector.onBufferingStarted(tech: `self`, source: source) }
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
    fileprivate func handleDurationChangedEvent(mediaAsset: MediaAsset<Source>) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.observe(path: .duration, on: playerItem) { [unowned self] item, change in
            DispatchQueue.main.async {
                // NOTE: This currently sends onDurationChanged events for all triggers of the KVO. This means events might be sent once duration is "updated" with the same value as before, effectivley assigning self.duration = duration.
                self.onDurationChanged(self)
            }
        }
    }
}

/// Playback Completed Events
extension HLSNative {
    /// Triggers `PlaybackCompleted` callbacks and analytics events.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handlePlaybackCompletedEvent(mediaAsset: MediaAsset<Source>) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.subscribe(notification: .AVPlayerItemDidPlayToEndTime, for: playerItem) { [unowned self] notification in
            self.onPlaybackCompleted(self)
            if let source = currentAsset?.source { source.analyticsConnector.onCompleted(tech: self, source: source) }
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
                        `self`.onPlaybackStarted(`self`)
                        if let source = `self`.currentAsset?.source { source.analyticsConnector.onStarted(tech: `self`, source: source) }
                    case .paused:
                        `self`.playbackState = .playing
                        `self`.onPlaybackResumed(`self`)
                        if let source = `self`.currentAsset?.source { source.analyticsConnector.onResumed(tech: `self`, source: source) }
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
                        `self`.onPlaybackPaused(`self`)
                        if let source = `self`.currentAsset?.source { source.analyticsConnector.onPaused(tech: `self`, source: source) }
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

/// Audio Session Interruption Events
extension HLSNative {
    /// Subscribes to *Audio Session Interruption* `Notification`s.
    fileprivate func handleAudioSessionInteruptionEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(HLSNative.audioSessionInterruption), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
    }
    
    /// Handles *Audio Session Interruption* events by resuming playback if instructed to do so.
    @objc fileprivate func audioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        switch type {
        case .began:
            print("AVAudioSessionInterruption BEGAN")
        case .ended:
            guard let flagsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let flags = AVAudioSessionInterruptionOptions(rawValue: flagsValue)
            print("AVAudioSessionInterruption ENDED",flags)
            if flags.contains(.shouldResume) {
                self.play()
            }
        }
    }
}

/// Backgrounding Events
extension HLSNative {
    /// Backgrounding the player events.
    fileprivate func handleBackgroundingEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(HLSNative.appDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HLSNative.appWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HLSNative.appWillTerminate), name: .UIApplicationWillTerminate, object: nil)
    }
    
    @objc fileprivate func appDidEnterBackground() {
        print("UIApplicationDidEnterBackground")
    }
    
    @objc fileprivate func appWillEnterForeground() {
        print("UIApplicationWillEnterForeground")
    }
    
    /// If the app is about to terminate make sure to stop playback. This will initiate teardown.
    ///
    /// Any attached `AnalyticsProvider` should hopefully be given enough time to finalize.
    @objc fileprivate func appWillTerminate() {
        print("UIApplicationWillTerminate")
        self.stop()
    }
}
