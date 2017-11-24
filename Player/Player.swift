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

extension PlayerError {
    public var localizedDescription: String {
        switch self {
        case .tech(error: let error): return error.localizedDescription
        case .context(error: let error): return error.localizedDescription
        }
    }
}

extension PlayerError {
    public var code: Int {
        switch self {
        case .tech(error: let error): return error.code
        case .context(error: let error): return error.code
        }
    }
}

public protocol ErrorCode: Error {
    var code: Int { get }
}






public final class Player<Tech: PlaybackTech> {
    fileprivate(set) public var source: Tech.Context.Source?
    
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
extension Player {
    /// Sets the callback to fire when the associated media is created but not yet loaded. Playback is not yet ready to start.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackCreated(callback: @escaping (Tech, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackCreated = callback
        return self
    }

    /// Sets the callback to fire when the associated media has loaded but is not playback ready.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self
    @discardableResult
    public func onPlaybackPrepared(callback: @escaping (Tech, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackPrepared = callback
        return self
    }

    /// Sets the callback to fire once the associated media has loaded and is ready for playback. At this point, starting playback should be possible.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackReady(callback: @escaping (Tech, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackReady = callback
        return self
    }

    /// Sets the callback to fire once the playback first starts. This is fired once.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackStarted(callback: @escaping (Tech, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackStarted = callback
        return self
    }

    /// Sets the callback to fire if playback rate for transitions from *non-zero* to *zero.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackPaused(callback: @escaping (Tech, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackPaused = callback
        return self
    }

    /// Sets the callback to fire if playback is resumed from a paused state.
    ///
    /// This will not fire if the playback has not yet been started, ie `onPlaybackStarted:` has not fired yet.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackResumed(callback: @escaping (Tech, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackResumed = callback
        return self
    }

    /// Sets the callback to fire once playback is stopped by user action.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackAborted(callback: @escaping (Tech, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackAborted = callback
        return self
    }

    /// Sets the callback to fire once playback reached the end of the current media, ie when playback reaches `duration`.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackCompleted(callback: @escaping (Tech, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackCompleted = callback
        return self
    }

    /// Sets the callback to fire whenever an `error` occurs. Errors are thrown from throughout the `player` lifecycle. Make sure to handle them. If appropriate, present valid information to *end users*.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onError(callback: @escaping (Tech?, Tech.Context.Source?, PlayerError<Tech, Tech.Context>) -> Void) -> Self {
        tech.eventDispatcher.onError = callback
        return self
    }

    /// Sets the callback to fire whenever the current *Bitrate* changes.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onBitrateChanged(callback: @escaping (Tech, Tech.Context.Source, Double) -> Void) -> Self {
        tech.eventDispatcher.onBitrateChanged = callback
        return self
    }

    /// Sets the callback to fire once buffering started.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onBufferingStarted(callback: @escaping (Tech, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onBufferingStarted = callback
        return self
    }

    /// Sets the callback to fire once buffering stopped.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onBufferingStopped(callback: @escaping (Tech, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onBufferingStopped = callback
        return self
    }

    /// Sets the callback to fire if user scrubs in player
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackScrubbed(callback: @escaping (Tech, Tech.Context.Source, Int64) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackScrubbed = callback
        return self
    }

    /// Sets the callback to fire once the current playback `duration` changes.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onDurationChanged(callback: @escaping (Tech, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onDurationChanged = callback
        return self
    }
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

