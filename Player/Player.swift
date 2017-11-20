//
//  Player.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation



public struct ManifestContext: PlaybackContext {
    public typealias Source = Manifest
    public let source: Manifest
    
    public let preferredTech: Tech<Manifest>? = HLSNative<Manifest>()
    public var analyticsGenerator: (Source) -> [AnalyticsProvider] = { _ in return [] }
}

public struct Manifest: MediaSource {
    public typealias SourceError = ManifestError
    
    public let drmAgent = DrmAgent.selfContained
    public let playSessionId: String
    public let url: URL
    
    func loadableBy(tech: Tech<Manifest>) -> Bool {
        return tech is HLSNative<Manifest>
    }
}

public enum ManifestError: MediaSourceError {
    case tech(reason: Error)
    case drm(reason: Error)
    
    public static func techError(from error: Error) -> ManifestError {
        return .tech(reason: error)
    }
    
    public static func drmError(from error: Error) -> ManifestError {
        return .drm(reason: error)
    }
}

extension Player where Context == ManifestContext {
    func play(manifest: Manifest) {
        for tech in techs {
            if manifest.loadableBy(tech: tech) {
                tech.load(source: manifest)
                break
            }
        }
    }
}

// PlaybackContext - ExposureContext
// MediaSource - Entitlement
// DrmAgent.ExternalDrm - ExposureFairplayRequester



public enum DrmAgent {
    case selfContained
    case external(agent: ExternalDrm)
}

public protocol MediaSourceError: Error {
    static func techError(from error: Error) -> Self
    static func drmError(from error: Error) -> Self
    
}

public protocol ExternalDrm {
//    associatedtype DrmError: Error
}


public protocol AnalyticsConnector {
    func onCreated<Source>(tech: Tech<Source>, source: Source)
    func onPrepared<Source>(tech: Tech<Source>, source: Source)
    func onReady<Source>(tech: Tech<Source>, source: Source)
    func onStarted<Source>(tech: Tech<Source>, source: Source)
    func onPaused<Source>(tech: Tech<Source>, source: Source)
    func onResumed<Source>(tech: Tech<Source>, source: Source)
    func onAborted<Source>(tech: Tech<Source>, source: Source)
    func onCompleted<Source>(tech: Tech<Source>, source: Source)
    func onError<Source>(tech: Tech<Source>, source: Source, error: Source.SourceError)

    func onBitrateChanged<Source>(tech: Tech<Source>, source: Source, bitrate: Double)
    func onBufferingStarted<Source>(tech: Tech<Source>, source: Source)
    func onBufferingStopped<Source>(tech: Tech<Source>, source: Source)
    func onScrubbedTo<Source>(tech: Tech<Source>, source: Source, offset: Int64)
    func onDurationChanged<Source>(tech: Tech<Source>, source: Source)
}






public final class Player<Context: PlaybackContext> {
    private let techs: [Tech<Context.Source>]
    fileprivate var selectedTech: Tech<Context.Source>
    fileprivate(set) public var source: Context.Source?
    
    private let context: Context
    public init(context: Context, defaultTech: Tech<Context.Source> = HLSNative<Context.Source>()) {
        self.context = context
        self.selectedTech = context.preferredTech ?? defaultTech
        self.techs = [context.preferredTech, defaultTech].flatMap{ $0 }
    }
    
    /// Returns a token string uniquely identifying this playSession.
    /// Example: “E621E1F8-C36C-495A-93FC-0C247A3E6E5F”
    public var playSessionId: String? {
        return source?.playSessionId
    }
    
    /// When autoplay is enabled, playback will resume as soon as the stream is loaded and prepared.
    public var autoplay: Bool = false
    
    
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
    fileprivate var onError: (Player, PlayerError) -> Void = { _,_  in }
    
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
    fileprivate var onPlaybackScrubbed: (Player, Int64) -> Void = { _,_  in }
    
    // MARK: AnalyticProvider
    public var analyticsProviderGenerator: (() -> AnalyticsProvider)? = nil
    
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
    /// Creates and configures the view used to render the media output.
    ///
    /// - parameter playerView:  *User supplied* view to configure for playback rendering.
    public func configure(playerView: UIView) {
        selectedTech.configure(playerView: playerView)
    }
}

// MARK: - MediaPlayback
extension Player: MediaPlayback {
    /// Starts or resumes playback.
    public func play() {
        selectedTech.play()
    }
    
    /// Pause playback if currently active
    public func pause() {
        selectedTech.pause()
    }
    
    /// Stops playback. This will trigger `PlaybackAborted` callbacks and analytics publication.
    public func stop() {
        selectedTech.stop()
    }
    
    
    /// Returns true if playback has been started and the current rate is not equal to 0
    public var isPlaying: Bool {
        return selectedTech.isPlaying
    }
    
    /// Use this method to seek to a specified time in the media timeline. The seek request will fail if interrupted by another seek request or by any other operation.
    ///
    /// - Parameter timeInterval: in milliseconds
    public func seek(to timeInterval: Int64) {
        selectedTech.seek(to: timeInterval)
    }
    
    /// Returns the current playback position of the player in *milliseconds*
    public var currentTime: Int64 {
        return selectedTech.currentTime
    }
    
    /// Returns the current playback position of the player in *milliseconds*, or `nil` if duration is infinite (live streams for example).
    public var duration: Int64? {
        return selectedTech.duration
    }
    
    /// The throughput required to play the stream, as advertised by the server, in *bits per second*. Will return nil if no bitrate can be reported.
    public var currentBitrate: Double? {
        return selectedTech.currentBitrate
    }
}

// MARK: - AnalyticsEventPublisher
extension Player: AnalyticsEventPublisher {
    
}

//// MARK: - Playback
//extension Player {
//    /// Configure and prepare a `MediaAsset` for playback. Please note this is an asynchronous process.
//    ///
//    /// Make sure the relevant `PlayerEventPublisher` callbacks has been registered.
//    ///
//    /// ```swift
//    /// player
//    ///     .onError{ player, error in
//    ///         // Handle and possibly present error to the user
//    ///     }
//    ///     .onPlaybackPaused{ player in
//    ///         // Toggle play/pause button
//    ///     }
//    ///     .onBitrateChanged{ bitrateEvent in
//    ///         // Update UI with stream quality indicator
//    ///     }
//    ///
//    /// ```
//    ///
//    /// - parameter mediaLocator: Specfies the *path* to where the media asset can be found.
//    /// - parameter fairplayRequester: Required for *Fairplay* `DRM` requests.
//    /// - parameter playSessionId: Optionally specify a unique session id for the playback session. If not provided, the system will generate a random `UUID`.
//    public func stream(url mediaLocator: String, using fairplayRequester: FairplayRequester? = nil, analyticsProvider: AnalyticsProvider? = nil, playSessionId: String? = nil) {
//        let provider = analyticsProvider ?? analyticsProviderGenerator?()
//        do {
//            let mediaAsset = try MediaAsset(mediaLocator: mediaLocator, fairplayRequester: fairplayRequester, analyticsProvider: provider, playSessionId: playSessionId)
//            stream(mediaAsset: mediaAsset)
//        }
//        catch {
//            if let playerError = error as? PlayerError {
//                handle(error: playerError, with: provider)
//            }
//            else {
//                let playerError = PlayerError.generalError(error: error)
//                handle(error: playerError, with: provider)
//            }
//        }
//    }
//
//    public func stream(urlAsset: AVURLAsset, using fairplayRequester: FairplayRequester? = nil, analyticsProvider: AnalyticsProvider? = nil, playSessionId: String? = nil) {
//        let mediaAsset = MediaAsset(avUrlAsset: urlAsset, fairplayRequester: fairplayRequester, analyticsProvider: analyticsProvider, playSessionId: playSessionId)
//        stream(mediaAsset: mediaAsset)
//    }
//
//}


/// Handle Errors
extension Player {
    /// Generic method to propagate `error` to any `onError` *listener* and the `AnalyticsProvider`.
    ///
    /// - parameter error: `PlayerError` to forward
    fileprivate func handle(error: PlayerError, for mediaAsset: MediaAsset) {
        handle(error: error, with: mediaAsset.analyticsProvider)
    }
    
    fileprivate func handle(error: PlayerError, with analyticsProvider: AnalyticsProvider?) {
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

