//
//  Player.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

public final class Player {
    /// `Player` uses the *native* `AVPlayer` for playback purposes.
    fileprivate var avPlayer: AVPlayer
    
    /// The currently active `MediaAsset` is stored here.
    ///
    /// This may be `nil` due to several reasons, for example before any media is loaded.
    fileprivate var currentAsset: MediaAsset?
    
    /// Returns a token string uniquely identifying this playSession.
    /// Example: “E621E1F8-C36C-495A-93FC-0C247A3E6E5F”
    fileprivate(set) public var playSessionId: String
    
    /// When autoplay is enabled, playback will resume as soon as the stream is loaded and prepared.
    public var autoplay: Bool = false
    
    public init() {
        avPlayer = AVPlayer()
        playSessionId = Player.generatePlaySessionId()
        
        handleCurrentItemChanges()
        handlePlaybackStateChanges()
        handleAudioSessionInteruptionEvents()
        handleBackgroundingEvents()
    }
    
    deinit {
        print("Player.deinit")
        playerObserver.stopObservingAll()
        playerObserver.unsubscribeAll()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Returns a string created from the UUID, such as "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
    ///
    /// A unique playSessionId should be generated for each new playSession.
    fileprivate static func generatePlaySessionId() -> String {
        return UUID().uuidString
    }
    
    /*
     Periodic Observer: AVPlayer
     
     open func addPeriodicTimeObserver(forInterval interval: CMTime, queue: DispatchQueue?, using block: @escaping (CMTime) -> Swift.Void) -> Any
     open func addBoundaryTimeObserver(forTimes times: [NSValue], queue: DispatchQueue?, using block: @escaping () -> Swift.Void) -> Any
     open func removeTimeObserver(_ observer: Any)
    */
    
    // MARK: PlayerEventPublisher
    // Stores the private callbacks specified by calling the associated `PlayerEventPublisher` functions.
    fileprivate var onPlaybackCreated: (Player) -> Void = { _ in }
    fileprivate var onPlaybackPrepared: (Player) -> Void = { _ in }
    fileprivate var onError: (Player, PlayerError) -> Void = { _ in }
    
    fileprivate var onBitrateChanged: (BitrateChangedEvent) -> Void = { _ in }
    fileprivate var onBufferingStarted: (Player) -> Void = { _ in }
    fileprivate var onBufferingStopped: (Player) -> Void = { _ in }
    fileprivate var onDurationChanged: (Player) -> Void = { _ in }
    
    fileprivate var onPlaybackReady: (Player) -> Void = { _ in }
    fileprivate var onPlaybackCompleted: (Player) -> Void = { _ in }
    fileprivate var onPlaybackStarted: (Player) -> Void = { _ in }
    fileprivate var onPlaybackAborted: (Player) -> Void = { _ in }
    fileprivate var onPlaybackPaused: (Player) -> Void = { _ in }
    fileprivate var onPlaybackResumed: (Player) -> Void = { _ in }
    fileprivate var onPlaybackScrubbed: (Player, Int64) -> Void = { _ in }
    
    
    /// Wrapper observing changes to the underlying `AVPlayer`
    lazy fileprivate var playerObserver: PlayerObserver = {
        return PlayerObserver()
    }()
    
    // MARK: MediaPlayback
    /// `PlaybackState` is a private state tracker and should not be exposed externally.
    fileprivate var playbackState: PlaybackState = .notStarted
    
    /// `BufferState` is a private state tracking buffering events. It should not be exposed externally.
    fileprivate var bufferState: BufferState = .notInitialized
    
    // MARK: AnalyticsEventPublisher
    public var analyticsProvider: AnalyticsProvider?
    
    // MARK: SessionShift
    /// `Bookmark` is a private state tracking `SessionShift` status. It should not be exposed externally.
    fileprivate var bookmark: Bookmark = .notEnabled
}

// MARK: - PlayerEventPublisher
extension Player: PlayerEventPublisher {
    public typealias PlayerEventError = PlayerError
    
    
    // MARK: Lifecycle
    /// Sets the callback to fire when the associated media is created but not yet loaded. Playback is not yet ready to start.
    ///
    /// At this point the `AVURLAsset` has yet to perform async loading of values (such as `duration`, `tracks` or `playable`) through `loadValuesAsynchronously`.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackCreated(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackCreated = callback
        return self
    }
    
    /// Sets the callback to fire when the associated media has loaded but is not playback ready.
    ///
    /// At this point event listeners (*KVO* and *Notifications*) for the media in preparation have not registered. `AVPlayer` has not yet replaced the current (if any) `AVPlayerItem`.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self
    @discardableResult
    public func onPlaybackPrepared(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackPrepared = callback
        return self
    }
    
    /// Sets the callback to fire whenever an `error` occurs. Errors are thrown from throughout the `player` lifecycle. Make sure to handle them. If appropriate, present valid information to *end users*.
    ///
    /// - parameter callback: callback to fire once the event is fired. `PlayerError` specifies that error.
    /// - returns: `Self`
    @discardableResult
    public func onError(callback: @escaping (Player, PlayerError) -> Void) -> Self {
        onError = callback
        return self
    }
    
    
    // MARK: Configuration
    /// Sets the callback to fire whenever the current *Bitrate* changes.
    ///
    /// - parameter callback: callback to fire once the event is fired. `BitrateChangedEvent` specifies the event.
    /// - returns: `Self`
    @discardableResult
    public func onBitrateChanged(callback: @escaping (BitrateChangedEvent) -> Void) -> Self {
        onBitrateChanged = callback
        return self
    }
    
    /// Sets the callback to fire once buffering started.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onBufferingStarted(callback: @escaping (Player) -> Void) -> Self {
        onBufferingStarted = callback
        return self
    }
    
    /// Sets the callback to fire once buffering stopped.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onBufferingStopped(callback: @escaping (Player) -> Void) -> Self {
        onBufferingStopped = callback
        return self
    }
    
    /// Sets the callback to fire once the current playback `duration` changes.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onDurationChanged(callback: @escaping (Player) -> Void) -> Self {
        onDurationChanged = callback
        return self
    }
    
    // MARK: Playback
    /// Sets the callback to fire once the associated media has loaded and is ready for playback. At this point, starting playback should be possible.
    ///
    /// Status for the `AVPlayerItem` associated with the media in preparation has reached `.readyToPlay` state.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackReady(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackReady = callback
        return self
    }
    
    /// Sets the callback to fire once playback reached the end of the current media, ie when playback reaches `duration`.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackCompleted(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackCompleted = callback
        return self
    }
    
    /// Sets the callback to fire once the playback first starts. This is fired once.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackStarted(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackStarted = callback
        return self
    }
    
    /// Sets the callback to fire once playback is stopped by user action.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackAborted(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackAborted = callback
        return self
    }
    
    /// Sets the callback to fire if playback rate for `AVPlayer` transitions from *non-zero* to *zero.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackPaused(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackPaused = callback
        return self
    }
    
    /// Sets the callback to fire if playback is resumed from a paused state.
    ///
    /// This will not fire if the playback has not yet been started, ie `onPlaybackStarted:` has not fired yet.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackResumed(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackResumed = callback
        return self
    }

    /// Sets the callback to fire if user scrubs in player
    /// 
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackScrubbed(callback: @escaping (Player, _ toTime: Int64) -> Void) -> Self {
        onPlaybackScrubbed = callback
        return self
    }
    
}

// MARK: - MediaRendering
extension Player: MediaRendering {
    /// Creates and configures the associated `CALayer` used to render the media output. This view will be added to the *user supplied* `playerView` as a sub view at `index: 0`. A strong reference to `playerView` is also established.
    ///
    /// - parameter playerView:  *User supplied* view to configure for playback rendering.
    public func configure(playerView: UIView) {
        configureRendering{
            let renderingView = PlayerView(frame: playerView.frame)
            
            renderingView.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
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
}

// MARK: - MediaPlayback
extension Player: MediaPlayback {
    /// Internal state for tracking playback.
    fileprivate enum PlaybackState {
        case notStarted
        case playing
        case paused
    }
    
    /// Starts or resumes playback.
    public func play() {
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
    public func pause() {
        guard isPlaying else { return }
        avPlayer.pause()
    }
    
    /// Stops playback. This will trigger `PlaybackAborted` callbacks and analytics publication.
    public func stop() {
        // TODO: End playback? Unload resources? Leave that to user?
        avPlayer.pause()
        onPlaybackAborted(self)
        analyticsProvider?.playbackAbortedEvent(player: self)
    }
    
    /// Returns true if playback has been started and the current rate is not equal to 0
    public var isPlaying: Bool {
        guard isActive else { return false }
        // TODO: How does this relate to PlaybackState? NOT good practice with the currently uncoupled behavior.
        return avPlayer.rate != 0
    }
    
    /// Returns true if playback has been started, but makes no assumtions regarding the playback rate.
    public var isActive: Bool {
        switch playbackState {
        case .notStarted: return false
        default: return true
        }
    }
    
    /// Use this method to seek to a specified time in the media timeline. The seek request will fail if interrupted by another seek request or by any other operation.
    ///
    /// - Parameter timeInterval: in milliseconds
    public func seek(to timeInterval: Int64) {
        let seekTime = timeInterval > 0 ? timeInterval : 0
        let cmTime = CMTime(value: seekTime, timescale: 1000)
        currentAsset?.playerItem.seek(to: cmTime) { success in
            if success {
                self.onPlaybackScrubbed(self, seekTime)
                self.analyticsProvider?.playbackScrubbedTo(player: self, offset: seekTime)
            }
        }
    }
    
    /// Returns the current playback position of the player in *milliseconds*
    public var currentTime: Int64 {
        guard let cmTime = currentAsset?.playerItem.currentTime() else { return 0 }
        return Int64(cmTime.seconds*1000)
    }
    
    /// Returns the current playback position of the player in *milliseconds*, or `nil` if duration is infinite (live streams for example).
    public var duration: Int64? {
        guard let cmTime = currentAsset?.playerItem.duration else { return nil }
        guard !cmTime.isIndefinite else { return nil }
        return Int64(cmTime.seconds*1000)
    }
}

// MARK: - AnalyticsEventPublisher
extension Player: AnalyticsEventPublisher {
    
}

// MARK: - Playback
extension Player {
    /// Configure and prepare a `MediaAsset` for playback. Please note this is an asynchronous process.
    ///
    /// Make sure the relevant `PlayerEventPublisher` callbacks has been registered.
    ///
    /// ```swift
    /// player
    ///     .onError{ player, error in
    ///         // Handle and possibly present error to the user
    ///     }
    ///     .onPlaybackPaused{ player in
    ///         // Toggle play/pause button
    ///     }
    ///     .onBitrateChanged{ bitrateEvent in
    ///         // Update UI with stream quality indicator
    ///     }
    ///
    /// ```
    ///
    /// - parameter mediaLocator: Specfies the *path* to where the media asset can be found.
    /// - parameter fairplayRequester: Required for *Fairplay* `DRM` requests.
    /// - parameter playSessionId: Optionally specify a unique session id for the playback session. If not provided, the system will generate a random `UUID`.
    public func stream(url mediaLocator: String, using fairplayRequester: FairplayRequester? = nil, playSessionId: String? = nil) {
        do {
            currentAsset = try MediaAsset(mediaLocator: mediaLocator, fairplayRequester: fairplayRequester)
            // Use the supplied play token or generate a new one
            self.playSessionId = playSessionId ?? Player.generatePlaySessionId()
            
            onPlaybackCreated(self)
            analyticsProvider?.playbackCreatedEvent(player: self)
            
            // Reset playbackState
            playbackState = .notStarted
            
            currentAsset?.prepare(loading: [.duration, .tracks, .playable]) { [weak self] error in
                guard let weakSelf = self, let currentAsset = weakSelf.currentAsset else {
                    return
                }
                guard error == nil else {
                    weakSelf.handle(error: error!)
                    return
                }
                
                weakSelf.onPlaybackPrepared(weakSelf)
                weakSelf.analyticsProvider?.playbackPreparedEvent(player: weakSelf)
                
                weakSelf.readyPlayback(with: currentAsset)
            }
        }
        catch {
            if let playerError = error as? PlayerError {
                handle(error: playerError)
            }
            else {
                let playerError = PlayerError.generalError(error: error)
                handle(error: playerError)
            }
        }
    }
    
    /// Once the `MediaAsset` has been *prepared* through `mediaAsset.prepare(loading: callback:)` the relevant `KVO` and `Notificaion`s are subscribed.
    ///
    /// Finally, once the `Player` is configured, the `currentMedia` is replaced with the newly created one. The system now awaits playback status to return `.readyToPlay`.
    fileprivate func readyPlayback(with mediaAsset: MediaAsset) {
        // Unsubscribe any current item
        currentAsset?.itemObserver.stopObservingAll()
        currentAsset?.itemObserver.unsubscribeAll()
        
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

/// Configuration and Status
extension Player {
    /// The throughput required to play the stream, as advertised by the server, in *bits per second*. Will return nil if no bitrate can be reported.
    public var currentBitrate: Double? {
        return currentAsset?
            .playerItem
            .accessLog()?
            .events
            .last?
            .indicatedBitrate
        
    }
}

/// Handle Errors
extension Player {
    /// Generic method to propagate `error` to any `onError` *listener* and the `AnalyticsProvider`.
    ///
    /// - parameter error: `PlayerError` to forward
    fileprivate func handle(error: PlayerError) {
        onError(self, error)
        analyticsProvider?.playbackErrorEvent(player: self, error: error)
    }
}

// MARK: - SessionShift
extension Player: SessionShift {
    /// Internal state for tracking Bookmarks.
    internal enum Bookmark {
        /// Bookmarking is not enabled
        case notEnabled
        
        /// Bookmarking is enabled. Optionaly, with a specified `offset`. No offset suggests that offset will be supplied at a later time.
        case enabled(offset: Int64?)
    }
    
    /// Is *Session Shift* enabled or not.
    ///
    /// SessionShift may be enabled without a specific `offset` defined.
    public var sessionShiftEnabled: Bool {
        switch bookmark {
        case .notEnabled: return false
        case .enabled(offset: _): return true
        }
    }
    
    /// Returns a *Session Shift* `offset` if one has been specified, else `nil`.
    ///
    /// No specified `offset` does not necessary mean *Session Shift* is disabled.
    public var sessionShiftOffset: Int64? {
        switch bookmark {
        case .notEnabled: return nil
        case .enabled(offset: let offset): return offset
        }
    }
    
    /// By specifying `true` you are signaling `sessionShift` is enabled and a starting `offset` will be supplied at *some time*, when is undefined.
    ///
    /// This is useful when you rely on some external party to supply the `player` with an `offset` at some point in its lifecycle.
    ///
    /// - parameter enabled: `true` if enabled, `false` otherwise
    /// - returns: `Self`
    @discardableResult
    public func sessionShift(enabled: Bool) -> Player {
        bookmark = enabled ? .enabled(offset: nil) : .notEnabled
        return self
    }
    
    /// Configure the `player` to start playback at the specified `offset`.
    ///
    /// - parameter offset: Offset into the media, in *milliseconds*.
    @discardableResult
    public func sessionShift(enabledAt offset: Int64) -> Player {
        bookmark = .enabled(offset: offset)
        return self
    }
}

// MARK: - Events
/// Player Item Status Change Events
extension Player {
    /// Subscribes to and handles changes in `AVPlayerItem.status`
    ///
    /// This is the final step in the initialization process. Either the playback is ready to start at the specified *start time* or an error has occured. The specified start time may be at the start of the stream if `SessionShift` is not used.
    ///
    /// If `autoplay` has been specified as `true`, playback will commence right after `.readyToPlay`.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handleStatusChange(mediaAsset: MediaAsset) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.observe(path: .status, on: playerItem) { [unowned self] item, change in
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
                        if case let .enabled(value) = self.bookmark, let offset = value {
                            let cmTime = CMTime(value: offset, timescale: 1000)
                            self.avPlayer.seek(to: cmTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { [unowned self] success in
                                
                                self.startPlayback()
                            }
                        }
                        else {
                            self.startPlayback()
                        }
                    }
                case .failed:
                    let error = PlayerError.asset(reason: .failedToReady(error: item.error))
                    self.handle(error: error)
                }
            }
        }
    }
    
    /// Private function to trigger the necessary final events right before playback starts.
    private func startPlayback() {
        self.onPlaybackReady(self)
        self.analyticsProvider?.playbackReadyEvent(player: self)
        
        // Start playback if autoplay is enabled
        if self.autoplay { self.play() }
    }
}

/// Bitrate Changed Events
extension Player {
    /// Subscribes to and handles bitrate changes accessed through `AVPlayerItem`s `AVPlayerItemNewAccessLogEntry`.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handleBitrateChangedEvent(mediaAsset: MediaAsset) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.subscribe(notification: .AVPlayerItemNewAccessLogEntry, for: playerItem) { [unowned self] notification in
            if let item = notification.object as? AVPlayerItem, let accessLog = item.accessLog() {
                if let currentEvent = accessLog.events.last {
                    let previousIndex = accessLog
                        .events
                        .index(of: currentEvent)?
                        .advanced(by: -1)
                    let previousEvent = previousIndex != nil ? accessLog.events[previousIndex!] : nil
                    let event = BitrateChangedEvent(player: self,
                                                    previousRate: previousEvent?.indicatedBitrate,
                                                    currentRate: currentEvent.indicatedBitrate)
                    DispatchQueue.main.async {
                        self.onBitrateChanged(event)
                        self.analyticsProvider?.playbackBitrateChanged(event: event)
                    }
                }
            }
        }
    }
}

/// Buffering Events
extension Player {
    /// Private buffer state
    fileprivate enum BufferState {
        /// Buffering, and thus playback, has not been started yet.
        case notInitialized
        
        /// Currently buffering
        case buffering
        
        /// Buffer has enough data to keep up with playback.
        case onPace
    }
    
    /// Subscribes to and handles buffering events by tracking the status of `AVPlayerItem` `properties` related to buffering.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handleBufferingEvents(mediaAsset: MediaAsset) {
        mediaAsset.itemObserver.observe(path: .isPlaybackLikelyToKeepUp, on: mediaAsset.playerItem) { [unowned self] item, change in
            DispatchQueue.main.async {
                switch self.bufferState {
                case .buffering:
                    self.bufferState = .onPace
                    self.onBufferingStopped(self)
                    self.analyticsProvider?.playbackBufferingStopped(player: self)
                default: return
                }
            }
        }
        
        
        mediaAsset.itemObserver.observe(path: .isPlaybackBufferFull, on: mediaAsset.playerItem) { [unowned self] item, change in
            DispatchQueue.main.async {
            }
        }
        
        mediaAsset.itemObserver.observe(path: .isPlaybackBufferEmpty, on: mediaAsset.playerItem) { [unowned self] item, change in
            DispatchQueue.main.async {
                switch self.bufferState {
                case .onPace, .notInitialized:
                    self.bufferState = .buffering
                    self.onBufferingStarted(self)
                    self.analyticsProvider?.playbackBufferingStarted(player: self)
                default: return
                }
            }
        }
    }
}

/// Duration Changed Events
extension Player {
    /// Subscribes to and handles duration changed events by tracking the status of `AVPlayerItem.duration`. Once changes occur, `onDurationChanged:` will fire.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handleDurationChangedEvent(mediaAsset: MediaAsset) {
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
extension Player {
    /// Triggers `PlaybackCompleted` callbacks and analytics events.
    ///
    /// - parameter mediaAsset: asset to observe and manage event for
    fileprivate func handlePlaybackCompletedEvent(mediaAsset: MediaAsset) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.subscribe(notification: .AVPlayerItemDidPlayToEndTime, for: playerItem) { [unowned self] notification in
            self.onPlaybackCompleted(self)
            self.analyticsProvider?.playbackCompletedEvent(player: self)
        }
    }
}

/// Playback State Changes
extension Player {
    /// Subscribes to and handles `AVPlayer.rate` changes.
    fileprivate func handlePlaybackStateChanges() {
        playerObserver.observe(path: .rate, on: avPlayer) { [unowned self] player, change in
            DispatchQueue.main.async {
                guard let newRate = change.new as? Float else {
                    return
                }
                
                if newRate < 0 || 0 < newRate {
                    switch self.playbackState {
                    case .notStarted:
                        self.playbackState = .playing
                        self.onPlaybackStarted(self)
                        self.analyticsProvider?.playbackStartedEvent(player: self)
                    case .paused:
                        self.playbackState = .playing
                        self.onPlaybackResumed(self)
                        self.analyticsProvider?.playbackResumedEvent(player: self)
                    case .playing:
                        return
                    }
                }
                else {
                    switch self.playbackState {
                    case .notStarted:
                        return
                    case .paused:
                        return
                    case .playing:
                        self.playbackState = .paused
                        self.onPlaybackPaused(self)
                        self.analyticsProvider?.playbackPausedEvent(player: self)
                    }
                }
            }
        }
    }
}

/// Current Item Changes
extension Player {
    /// Subscribes to and handles `AVPlayer.currentItem` changes.
    fileprivate func handleCurrentItemChanges() {
        playerObserver.observe(path: .currentItem, on: avPlayer) { [unowned self] player, change in
            print("Player.currentItem changed",player, change.new, change.old)
            // TODO: Do we handle programChange here?
        }
    }
}

/// Audio Session Interruption Events
extension Player {
    /// Subscribes to *Audio Session Interruption* `Notification`s.
    fileprivate func handleAudioSessionInteruptionEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(Player.audioSessionInterruption), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
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
extension Player {
    /// Backgrounding the player events.
    fileprivate func handleBackgroundingEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(Player.appDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Player.appWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Player.appWillTerminate), name: .UIApplicationWillTerminate, object: nil)
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
