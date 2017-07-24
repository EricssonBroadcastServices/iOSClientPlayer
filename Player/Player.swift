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
    
    fileprivate var avPlayer: AVPlayer
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
    
    
    lazy fileprivate var playerObserver: PlayerObserver = { [unowned self] in
        return PlayerObserver()
    }()
    
    // MARK: MediaPlayback
    fileprivate var playbackState: PlaybackState = .notStarted
    fileprivate var bufferState: BufferState = .notInitialized
    
    // MARK: AnalyticsEventPublisher
    public var analyticsProvider: AnalyticsProvider?
}

// MARK: - PlayerEventPublisher
extension Player: PlayerEventPublisher {
    public typealias PlayerEventError = PlayerError
    
    
    // MARK: Lifecycle
    @discardableResult
    public func onPlaybackCreated(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackCreated = callback
        return self
    }
    
    @discardableResult
    public func onPlaybackPrepared(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackPrepared = callback
        return self
    }
    
    @discardableResult
    public func onError(callback: @escaping (Player, PlayerError) -> Void) -> Self {
        onError = callback
        return self
    }
    
    
    // MARK: Configuration
    @discardableResult
    public func onBitrateChanged(callback: @escaping (BitrateChangedEvent) -> Void) -> Self {
        onBitrateChanged = callback
        return self
    }
    
    @discardableResult
    public func onBufferingStarted(callback: @escaping (Player) -> Void) -> Self {
        onBufferingStarted = callback
        return self
    }
    
    @discardableResult
    public func onBufferingStopped(callback: @escaping (Player) -> Void) -> Self {
        onBufferingStopped = callback
        return self
    }
    
    @discardableResult
    public func onDurationChanged(callback: @escaping (Player) -> Void) -> Self {
        onDurationChanged = callback
        return self
    }
    
    // MARK: Playback
    @discardableResult
    public func onPlaybackReady(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackReady = callback
        return self
    }
    
    @discardableResult
    public func onPlaybackCompleted(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackCompleted = callback
        return self
    }
    @discardableResult
    public func onPlaybackStarted(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackStarted = callback
        return self
    }
    
    @discardableResult
    public func onPlaybackAborted(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackAborted = callback
        return self
    }
    
    @discardableResult
    public func onPlaybackPaused(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackPaused = callback
        return self
    }
    
    @discardableResult
    public func onPlaybackResumed(callback: @escaping (Player) -> Void) -> Self {
        onPlaybackResumed = callback
        return self
    }
    
}

// MARK: - MediaRendering
extension Player: MediaRendering {
    public func configure(playerView: UIView) {
        let renderingView = PlayerView(frame: playerView.frame)
        
        renderingView.avPlayerLayer.player = avPlayer
        renderingView.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        renderingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        playerView.addSubview(renderingView)
        
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
    }
}

// MARK: - MediaPlayback
extension Player: MediaPlayback {
    fileprivate enum PlaybackState {
        case notStarted
        case playing
        case paused
    }
    
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
    
    public func pause() {
        guard isPlaying else { return }
        avPlayer.pause()
    }
    
    public func stop() {
        // TODO: End playback? Unload resources? Leave that to user?
        avPlayer.pause()
        onPlaybackAborted(self)
        analyticsProvider?.playbackAbortedEvent(player: self)
    }
    
    public var isPlaying: Bool {
        return avPlayer.rate != 0
    }
    
    /// Number of miliseconds
    ///
    /// - Parameter timeInterval: in milliseconds
    ///
    public func seek(to timeInterval: Int64) {
        let seekTime = timeInterval > 0 ? timeInterval : 0
        let cmTime = CMTime(value: seekTime, timescale: 1000)
        currentAsset?.playerItem.seek(to: cmTime) { success in
            
        }
    }
    
    /// Returns the current playback position of the player in milliseconds
    ///
    /// - Returns: in milliseconds
    ///
    public var currentTime: Int64 {
        guard let cmTime = currentAsset?.playerItem.currentTime() else { return 0 }
        return Int64(cmTime.seconds*1000)
    }
    
    /// Returns the current playback position of the player in milliseconds, or nil if duration is infinite
    ///
    /// - Returns: in milliseconds
    ///
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
    public func stream(url mediaLocator: String, using fairplayRequester: FairplayRequester, playSessionId: String? = nil) {
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
    fileprivate func handle(error: PlayerError) {
        onError(self, error)
        analyticsProvider?.playbackErrorEvent(player: self, error: error)
    }
}

/// Player Item Status Change Events
extension Player {
    fileprivate func handleStatusChange(mediaAsset: MediaAsset) {
        let playerItem = mediaAsset.playerItem
        mediaAsset.itemObserver.observe(path: .status, on: playerItem) { [unowned self] item, change in
            if let newValue = change.new as? Int, let status = AVPlayerItemStatus(rawValue: newValue) {
                switch status {
                case .unknown:
                    // TODO: Do we send anything on .unknown?
                    return
                case .readyToPlay:
                    if self.playbackState == .notStarted {
                        // This will trigger every time the player is ready to play, including:
                        //  - first started
                        //  - after seeking
                        // Only send onPlaybackReady if the stream has not been started yet.
                        self.onPlaybackReady(self)
                        self.analyticsProvider?.playbackReadyEvent(player: self)
                        
                        // Start playback if autoplay is enabled
                        if self.autoplay { self.play() }
                    }
                case .failed:
                    let error = PlayerError.asset(reason: .failedToReady(error: item.error))
                    self.handle(error: error)
                }
            }
        }
    }
}

/// Bitrate Changed Events
extension Player {
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
    fileprivate enum BufferState {
        case notInitialized
        case buffering
        case onPace
    }
    
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
    fileprivate func handleCurrentItemChanges() {
        playerObserver.observe(path: .currentItem, on: avPlayer) { [unowned self] player, change in
            print("Player.currentItem changed",player, change.new)
        }
    }
}

/// Audio Session Interruption Events
extension Player {
    fileprivate func handleAudioSessionInteruptionEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(Player.audioSessionInterruption), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
    }
    
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
    
    @objc fileprivate func appWillTerminate() {
        print("UIApplicationWillTerminate")
        self.stop()
    }
}
