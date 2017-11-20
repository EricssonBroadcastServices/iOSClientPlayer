//
//  Player.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation



public final class ManifestContext: PlaybackContext {
    public typealias ContextError = ManifestContextError
    
    public typealias Source = Manifest
    
    func manifest(from url: URL) -> Manifest {
        let source = Manifest(playSessionId: UUID().uuidString,
                              url: url)
        source.analyticsConnector.providers = analyticsGenerator(source)
        return source
    }
    
    public let preferredTech: Tech<ManifestContext>? = HLSNative<ManifestContext>()
    public var analyticsGenerator: (Source) -> [AnalyticsProvider] = { _ in return [] }
}

public class Manifest: MediaSource {
    public let analyticsConnector: PassThroughConnector = PassThroughConnector()
    public let drmAgent = DrmAgent.selfContained
    public let playSessionId: String
    public let url: URL
    
    public init(playSessionId: String, url: URL) {
        self.playSessionId = playSessionId
        self.url = url
    }
//    func loadableBy(tech: Tech<ManifestContext>) -> Bool {
//        return tech is HLSNative<ManifestContext>
//    }
}

public enum ManifestContextError: PlaybackContextError {
    case source(reason: Error)
    case tech(reason: Error)
    case drm(reason: Error)
    
    public static func sourceError(error: Error) -> ManifestContextError {
        return .source(reason: error)
    }
    
    public static func techError(from error: Error) -> ManifestContextError {
        return .tech(reason: error)
    }
    
    public static func drmError(from error: Error) -> ManifestContextError {
        return .drm(reason: error)
    }
}

extension Player where Context == ManifestContext {
    func logAnalytics() -> Self {
        context.analyticsGenerator = { _ in [AnalyticsLogger()] }
    }
    
    func stream(url: URL) {
        for tech in techs {
            if let native = tech as? HLSNative<Context> {
                let manifest = context.manifest(from: url)
                native.load(source: manifest)
                break
            }
        }
    }
}


public enum DrmAgent {
    case selfContained
    case external(agent: ExternalDrm)
}

public protocol ExternalDrm { }

public protocol PlaybackContextError: Error {
    static func sourceError(error: Error) -> Self
    static func techError(from error: Error) -> Self
    static func drmError(from error: Error) -> Self
}



public protocol AnalyticsConnector: EventResponder {
    var providers: [AnalyticsProvider] { get set }
}

public class PassThroughConnector: AnalyticsConnector {
    public var providers: [AnalyticsProvider] = []
    
    public func onCreated<Context>(tech: Tech<Context>, source: Context.Source) {
        providers.forEach{ $0.onCreated(tech: tech, source: source) }
    }
    
    public func onPrepared<Context>(tech: Tech<Context>, source: Context.Source) {
        providers.forEach{ $0.onPrepared(tech: tech, source: source) }
    }
    
    public func onReady<Context>(tech: Tech<Context>, source: Context.Source) {
        providers.forEach{ $0.onReady(tech: tech, source: source) }
    }
    
    public func onStarted<Context>(tech: Tech<Context>, source: Context.Source) {
        providers.forEach{ $0.onStarted(tech: tech, source: source) }
    }
    
    public func onPaused<Context>(tech: Tech<Context>, source: Context.Source) {
        providers.forEach{ $0.onPaused(tech: tech, source: source) }
    }
    
    public func onResumed<Context>(tech: Tech<Context>, source: Context.Source) {
        providers.forEach{ $0.onResumed(tech: tech, source: source) }
    }
    
    public func onAborted<Context>(tech: Tech<Context>, source: Context.Source) {
        providers.forEach{ $0.onAborted(tech: tech, source: source) }
    }
    
    public func onCompleted<Context>(tech: Tech<Context>, source: Context.Source) {
        providers.forEach{ $0.onCompleted(tech: tech, source: source) }
    }
    
    public func onError<Context>(tech: Tech<Context>, source: Context.Source, error: Context.ContextError) {
        providers.forEach{ $0.onError(tech: tech, source: source, error: error) }
    }
    
    public func onBitrateChanged<Context>(tech: Tech<Context>, source: Context.Source, bitrate: Double) {
        providers.forEach{ $0.onBitrateChanged(tech: tech, source: source, bitrate: bitrate) }
    }
    
    public func onBufferingStarted<Context>(tech: Tech<Context>, source: Context.Source) {
        providers.forEach{ $0.onBufferingStarted(tech: tech, source: source) }
    }
    
    public func onBufferingStopped<Context>(tech: Tech<Context>, source: Context.Source) {
        providers.forEach{ $0.onBufferingStopped(tech: tech, source: source) }
    }
    
    public func onScrubbedTo<Context>(tech: Tech<Context>, source: Context.Source, offset: Int64) {
        providers.forEach{ $0.onScrubbedTo(tech: tech, source: source, offset: offset) }
    }
    
    public func onDurationChanged<Context>(tech: Tech<Context>, source: Context.Source) {
        providers.forEach{ $0.onDurationChanged(tech: tech, source: source) }
    }
}

public struct AnalyticsLogger: AnalyticsProvider {
    public func onCreated<Context>(tech: Tech<Context>, source: Context.Source) {
        print("🏷 AnalyticsLogger",type(of: tech),"🏗 onCreated",source.playSessionId)
    }
    
    public func onPrepared<Context>(tech: Tech<Context>, source: Context.Source) {
        print("🏷 AnalyticsLogger",type(of: tech),"🛁 onPrepared",source.playSessionId)
    }
    
    public func onReady<Context>(tech: Tech<Context>, source: Context.Source) {
        print("🏷 AnalyticsLogger",type(of: tech),"👍 onReady",source.playSessionId)
    }
    
    public func onStarted<Context>(tech: Tech<Context>, source: Context.Source) {
        print("🏷 AnalyticsLogger",type(of: tech),"🎬 onStarted",source.playSessionId)
    }
    
    public func onPaused<Context>(tech: Tech<Context>, source: Context.Source) {
        print("🏷 AnalyticsLogger",type(of: tech),"⏸ onPaused",source.playSessionId)
    }
    
    public func onResumed<Context>(tech: Tech<Context>, source: Context.Source) {
        print("🏷 AnalyticsLogger",type(of: tech),"▶️ onResumed",source.playSessionId)
    }
    
    public func onAborted<Context>(tech: Tech<Context>, source: Context.Source) {
        print("🏷 AnalyticsLogger",type(of: tech),"⏹ onAborted",source.playSessionId)
    }
    
    public func onCompleted<Context>(tech: Tech<Context>, source: Context.Source) {
        print("🏷 AnalyticsLogger",type(of: tech),"🏁 onCompleted",source.playSessionId)
    }
    
    public func onError<Context>(tech: Tech<Context>, source: Context.Source, error: Context.ContextError) {
        print("🏷 AnalyticsLogger",type(of: tech),"🚨 onError",source.playSessionId)
    }
    
    public func onBitrateChanged<Context>(tech: Tech<Context>, source: Context.Source, bitrate: Double) {
        print("🏷 AnalyticsLogger",type(of: tech),"📶 onBitrateChanged [\(bitrate)]",source.playSessionId)
    }
    
    public func onBufferingStarted<Context>(tech: Tech<Context>, source: Context.Source) {
        print("🏷 AnalyticsLogger",type(of: tech),"⏳ onBufferingStarted",source.playSessionId)
    }
    
    public func onBufferingStopped<Context>(tech: Tech<Context>, source: Context.Source) {
        print("🏷 AnalyticsLogger",type(of: tech),"⌛ onBufferingStopped",source.playSessionId)
    }
    
    public func onScrubbedTo<Context>(tech: Tech<Context>, source: Context.Source, offset: Int64) {
        print("🏷 AnalyticsLogger",type(of: tech),"🕘 onScrubbedTo [\(offset)]",source.playSessionId)
    }
    
    public func onDurationChanged<Context>(tech: Tech<Context>, source: Context.Source) {
        print("🏷 AnalyticsLogger",type(of: tech),"📅 onDurationChanged",source.playSessionId)
    }
}



public final class Player<Context: PlaybackContext> {
    fileprivate(set) public var techs: [Tech<Context>]
    fileprivate(set) public var selectedTech: Tech<Context>
    fileprivate(set) public var source: Context.Source?
    
    fileprivate(set) public var context: Context
    public init(context: Context, defaultTech: Tech<Context> = HLSNative<Context>()) {
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
    
    
    // MARK: PlayerEventPublisher
    // Stores the private callbacks specified by calling the associated `PlayerEventPublisher` functions.
    fileprivate var onPlaybackCreated: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    fileprivate var onPlaybackPrepared: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    fileprivate var onError: (Tech<Context>, Context.Source, Context.ContextError) -> Void = { _,_,_  in }
    
    fileprivate var onBitrateChanged: (Tech<Context>, Context.Source, Double) -> Void = { _,_,_ in }
    fileprivate var onBufferingStarted: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    fileprivate var onBufferingStopped: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    fileprivate var onDurationChanged: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    
    fileprivate var onPlaybackReady: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    fileprivate var onPlaybackCompleted: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    fileprivate var onPlaybackStarted: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    fileprivate var onPlaybackAborted: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    fileprivate var onPlaybackPaused: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    fileprivate var onPlaybackResumed: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    fileprivate var onPlaybackScrubbed: (Tech<Context>, Context.Source, Int64) -> Void = { _,_,_  in }
    
    // MARK: SessionShift
    /// `Bookmark` is a private state tracking `SessionShift` status. It should not be exposed externally.
    fileprivate var bookmark: Bookmark = .notEnabled
}

extension Player {
    /// Convenience function for setting an `AnalyticsProvider`, providing a chaining interface for configuration.
    ///
    /// - parameter provider: `AnalyticsProvider` to publish events to.
    /// - returns: `Self`
    @discardableResult
    public func analytics(callback: @escaping (Context.Source) -> [AnalyticsProvider]) -> Self {
        context.analyticsGenerator = callback
        return self
    }
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

