//
//  Player.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation


public enum PlayerError<Tech: PlaybackTech, Context: MediaContext> {
    public typealias TechError = Tech.TechError
    public typealias ContextError = Context.ContextError
    
    case tech(error: TechError)
    case context(error: ContextError)
}

public final class ManifestContext: MediaContext {
    public typealias ContextError = Error
    public typealias Source = Manifest
    
    func manifest(from url: URL) -> Manifest {
        let source = Manifest(playSessionId: UUID().uuidString,
                              url: url)
        source.analyticsConnector.providers = analyticsGenerator(source)
        return source
    }
    
    public var analyticsGenerator: (Source) -> [AnalyticsProvider] = { _ in return [] }
    
    public enum Error: Swift.Error {
        case someError
    }
}

public class Manifest: MediaSource {
    public var analyticsConnector: AnalyticsConnector = PassThroughConnector()
    public let drmAgent = DrmAgent.selfContained
    public let playSessionId: String
    public let url: URL
    
    public init(playSessionId: String, url: URL) {
        self.playSessionId = playSessionId
        self.url = url
    }
}

extension Player where Context == ManifestContext {
    func logAnalytics() -> Self {
        context.analyticsGenerator = { _ in [AnalyticsLogger()] }
        return self
    }
    
    func stream(url: URL) {
        let manifest = context.manifest(from: url)
        load(source: manifest)
    }
}


public enum DrmAgent {
    case selfContained
    case external(agent: ExternalDrm)
}

public protocol ExternalDrm { }




public class EventDispatcher<Context: MediaContext, Tech: PlaybackTech> {
    internal(set) public var onPlaybackCreated: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackPrepared: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackReady: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackStarted: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackPaused: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackResumed: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackAborted: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackCompleted: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onError: (Tech?, Context.Source?, PlayerError<Tech, Context>) -> Void = { _,_,_  in }
    internal(set) public var onBitrateChanged: (Tech, Context.Source, Double) -> Void = { _,_,_ in }
    internal(set) public var onBufferingStarted: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onBufferingStopped: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackScrubbed: (Tech, Context.Source, Int64) -> Void = { _,_,_  in }
    internal(set) public var onDurationChanged: (Tech, Context.Source) -> Void = { _,_ in }
}

public final class Player<Tech: PlaybackTech> {
    fileprivate(set) public var source: Tech.Context.Source?
//    fileprivate(set) public var eventDispatcher: EventDispatcher<Tech.Context, Tech> = EventDispatcher()
    
    fileprivate(set) public var tech: Tech
    fileprivate(set) public var context: Tech.Context
    public init(tech: Tech, context: Tech.Context) {
        self.context = context
        self.tech = tech
    }
    
//    /// Returns a token string uniquely identifying this playSession.
//    /// Example: “E621E1F8-C36C-495A-93FC-0C247A3E6E5F”
//    public var playSessionId: String? {
//        return source?.playSessionId
//    }
//
//    /// When autoplay is enabled, playback will resume as soon as the stream is loaded and prepared.
//    public var autoplay: Bool = false
//
//
//    // MARK: SessionShift
//    /// `Bookmark` is a private state tracking `SessionShift` status. It should not be exposed externally.
//    fileprivate var bookmark: Bookmark = .notEnabled
}


//// MARK: - Analytics Generator
//extension Player {
//    /// Convenience function for setting `AnalyticsProvider`s through a generator.
//    ///
//    /// - parameter callback: closure to use for generating [`AnalyticsProvider`].
//    /// - returns: `Self`
//    @discardableResult
//    public func analytics(callback: @escaping (Context.Source) -> [AnalyticsProvider]) -> Self {
//        context.analyticsGenerator = callback
//        return self
//    }
//}

// MARK: - PlayerEventPublisher
//extension Player: EventPublisher {
//
//    /// Sets the callback to fire when the associated media is created but not yet loaded. Playback is not yet ready to start.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onPlaybackCreated(callback: @escaping (Tech, Context.Source) -> Void) -> Self {
//        eventDispatcher.onPlaybackCreated = callback
//        return self
//    }
//
//    /// Sets the callback to fire when the associated media has loaded but is not playback ready.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self
//    @discardableResult
//    public func onPlaybackPrepared(callback: @escaping (Tech, Context.Source) -> Void) -> Self {
//        eventDispatcher.onPlaybackPrepared = callback
//        return self
//    }
//
//    /// Sets the callback to fire once the associated media has loaded and is ready for playback. At this point, starting playback should be possible.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onPlaybackReady(callback: @escaping (Tech, Context.Source) -> Void) -> Self {
//        eventDispatcher.onPlaybackReady = callback
//        return self
//    }
//
//    /// Sets the callback to fire once the playback first starts. This is fired once.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onPlaybackStarted(callback: @escaping (Tech, Context.Source) -> Void) -> Self {
//        eventDispatcher.onPlaybackStarted = callback
//        return self
//    }
//
//    /// Sets the callback to fire if playback rate for transitions from *non-zero* to *zero.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onPlaybackPaused(callback: @escaping (Tech, Context.Source) -> Void) -> Self {
//        eventDispatcher.onPlaybackPaused = callback
//        return self
//    }
//
//    /// Sets the callback to fire if playback is resumed from a paused state.
//    ///
//    /// This will not fire if the playback has not yet been started, ie `onPlaybackStarted:` has not fired yet.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onPlaybackResumed(callback: @escaping (Tech, Context.Source) -> Void) -> Self {
//        eventDispatcher.onPlaybackResumed = callback
//        return self
//    }
//
//    /// Sets the callback to fire once playback is stopped by user action.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onPlaybackAborted(callback: @escaping (Tech, Context.Source) -> Void) -> Self {
//        eventDispatcher.onPlaybackAborted = callback
//        return self
//    }
//
//    /// Sets the callback to fire once playback reached the end of the current media, ie when playback reaches `duration`.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onPlaybackCompleted(callback: @escaping (Tech, Context.Source) -> Void) -> Self {
//        eventDispatcher.onPlaybackCompleted = callback
//        return self
//    }
//
//    /// Sets the callback to fire whenever an `error` occurs. Errors are thrown from throughout the `player` lifecycle. Make sure to handle them. If appropriate, present valid information to *end users*.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onError(callback: @escaping (Tech?, Context.Source?, Context.ContextError) -> Void) -> Self {
//        eventDispatcher.onError = callback
//        return self
//    }
//
//    /// Sets the callback to fire whenever the current *Bitrate* changes.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onBitrateChanged(callback: @escaping (Tech, Context.Source, Double) -> Void) -> Self {
//        eventDispatcher.onBitrateChanged = callback
//        return self
//    }
//
//    /// Sets the callback to fire once buffering started.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onBufferingStarted(callback: @escaping (Tech, Context.Source) -> Void) -> Self {
//        eventDispatcher.onBufferingStarted = callback
//        return self
//    }
//
//    /// Sets the callback to fire once buffering stopped.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onBufferingStopped(callback: @escaping (Tech, Context.Source) -> Void) -> Self {
//        eventDispatcher.onBufferingStopped = callback
//        return self
//    }
//
//    /// Sets the callback to fire if user scrubs in player
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onPlaybackScrubbed(callback: @escaping (Tech, Context.Source, Int64) -> Void) -> Self {
//        eventDispatcher.onPlaybackScrubbed = callback
//        return self
//    }
//
//    /// Sets the callback to fire once the current playback `duration` changes.
//    ///
//    /// - parameter callback: callback to fire once the event is fired.
//    /// - returns: `Self`
//    @discardableResult
//    public func onDurationChanged(callback: @escaping (Tech, Context.Source) -> Void) -> Self {
//        eventDispatcher.onDurationChanged = callback
//        return self
//    }
//}

// MARK: - MediaRendering
//extension Player: MediaRendering {
//    /// Creates and configures the view used to render the media output.
//    ///
//    /// - parameter playerView:  *User supplied* view to configure for playback rendering.
//    public func configure(playerView: UIView) {
//        selectedTech.configure(playerView: playerView)
//    }
//}
//
//// MARK: - MediaPlayback
//extension Player: MediaPlayback {
//    /// Starts or resumes playback.
//    public func play() {
//        selectedTech.play()
//    }
//
//    /// Pause playback if currently active
//    public func pause() {
//        selectedTech.pause()
//    }
//
//    /// Stops playback. This will trigger `PlaybackAborted` callbacks and analytics publication.
//    public func stop() {
//        selectedTech.stop()
//    }
//
//
//    /// Returns true if playback has been started and the current rate is not equal to 0
//    public var isPlaying: Bool {
//        return selectedTech.isPlaying
//    }
//
//    /// Use this method to seek to a specified time in the media timeline. The seek request will fail if interrupted by another seek request or by any other operation.
//    ///
//    /// - Parameter timeInterval: in milliseconds
//    public func seek(to timeInterval: Int64) {
//        selectedTech.seek(to: timeInterval)
//    }
//
//    /// Returns the current playback position of the player in *milliseconds*
//    public var currentTime: Int64 {
//        return selectedTech.currentTime
//    }
//
//    /// Returns the current playback position of the player in *milliseconds*, or `nil` if duration is infinite (live streams for example).
//    public var duration: Int64? {
//        return selectedTech.duration
//    }
//
//    /// The throughput required to play the stream, as advertised by the server, in *bits per second*. Will return nil if no bitrate can be reported.
//    public var currentBitrate: Double? {
//        return selectedTech.currentBitrate
//    }
//}

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



//// MARK: - SessionShift
//extension Player: SessionShift {
//    /// Internal state for tracking Bookmarks.
//    internal enum Bookmark {
//        /// Bookmarking is not enabled
//        case notEnabled
//
//        /// Bookmarking is enabled. Optionaly, with a specified `offset`. No offset suggests that offset will be supplied at a later time.
//        case enabled(offset: Int64?)
//    }
//
//    /// Is *Session Shift* enabled or not.
//    ///
//    /// SessionShift may be enabled without a specific `offset` defined.
//    public var sessionShiftEnabled: Bool {
//        switch bookmark {
//        case .notEnabled: return false
//        case .enabled(offset: _): return true
//        }
//    }
//
//    /// Returns a *Session Shift* `offset` if one has been specified, else `nil`.
//    ///
//    /// No specified `offset` does not necessary mean *Session Shift* is disabled.
//    public var sessionShiftOffset: Int64? {
//        switch bookmark {
//        case .notEnabled: return nil
//        case .enabled(offset: let offset): return offset
//        }
//    }
//
//    /// By specifying `true` you are signaling `sessionShift` is enabled and a starting `offset` will be supplied at *some time*, when is undefined.
//    ///
//    /// This is useful when you rely on some external party to supply the `player` with an `offset` at some point in its lifecycle.
//    ///
//    /// - parameter enabled: `true` if enabled, `false` otherwise
//    /// - returns: `Self`
//    @discardableResult
//    public func sessionShift(enabled: Bool) -> Player {
//        bookmark = enabled ? .enabled(offset: nil) : .notEnabled
//        return self
//    }
//
//    /// Configure the `player` to start playback at the specified `offset`.
//    ///
//    /// - parameter offset: Offset into the media, in *milliseconds*.
//    @discardableResult
//    public func sessionShift(enabledAt offset: Int64) -> Player {
//        bookmark = .enabled(offset: offset)
//        return self
//    }
//}

