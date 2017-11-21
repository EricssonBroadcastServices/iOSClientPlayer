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
    
    public let supportedTechs: [Tech<ManifestContext>.Type] = [HLSNative<ManifestContext>.self]
    public var preferredTech: Tech<ManifestContext>.Type? {
        return supportedTechs.first
    }
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
    
    public func onError<Context>(tech: Tech<Context>?, source: Context.Source?, error: Context.ContextError) {
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
    
    public func onError<Context>(tech: Tech<Context>?, source: Context.Source?, error: Context.ContextError) {
        print("🏷 AnalyticsLogger",type(of: tech),"🚨 onError",source?.playSessionId ?? "")
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


public class EventDispatcher<Context: PlaybackContext> {
    internal(set) public var onPlaybackCreated: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackPrepared: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackReady: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackStarted: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackPaused: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackResumed: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackAborted: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackCompleted: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    internal(set) public var onError: (Tech<Context>?, Context.Source?, Context.ContextError) -> Void = { _,_,_  in }
    internal(set) public var onBitrateChanged: (Tech<Context>, Context.Source, Double) -> Void = { _,_,_ in }
    internal(set) public var onBufferingStarted: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    internal(set) public var onBufferingStopped: (Tech<Context>, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackScrubbed: (Tech<Context>, Context.Source, Int64) -> Void = { _,_,_  in }
    internal(set) public var onDurationChanged: (Tech<Context>, Context.Source) -> Void = { _,_ in }
}

public final class Player<Context: PlaybackContext> {
    fileprivate(set) public var techs: [Tech<Context>.Type]
    fileprivate var selectedTech: Tech<Context>
    public var activeTech: Tech<Context>.Type {
        return type(of: selectedTech)
    }
    
    fileprivate(set) public var source: Context.Source?
    fileprivate(set) public var eventDispatcher: EventDispatcher<Context> = EventDispatcher()
    
    fileprivate(set) public var context: Context
    public init(context: Context, defaultTech: Tech<Context>.Type = HLSNative<Context>.self) {
        self.context = context
        
        if let protoTech = context.preferredTech {
            self.selectedTech = protoTech.init()
            self.techs = (protoTech == defaultTech) ? [protoTech] : [protoTech, defaultTech]
        }
        else {
            self.selectedTech = defaultTech.init()
            self.techs = [defaultTech]
        }
    }
    
    /// Returns a token string uniquely identifying this playSession.
    /// Example: “E621E1F8-C36C-495A-93FC-0C247A3E6E5F”
    public var playSessionId: String? {
        return source?.playSessionId
    }
    
    /// When autoplay is enabled, playback will resume as soon as the stream is loaded and prepared.
    public var autoplay: Bool = false
    
    
    // MARK: SessionShift
    /// `Bookmark` is a private state tracking `SessionShift` status. It should not be exposed externally.
    fileprivate var bookmark: Bookmark = .notEnabled
}

// MARK: - Tech
extension Player {
    
    public func load(source: Context.Source) {
        // 1. Check if the current tech can load this source
        let usableTech = canPlay(source: source)
        
        switch usableTech {
        case .active(tech: let tech): tech.load(source: source)
        case .available(techs: let available):
            cycle(techs: available) { success in
                if let prepared = success {
                    print("Tech: Prepared tech: \(prepared.name)")
                }
                else {
                    print("Tech: Unable to prepare")
                }
            }
        case .supportedButUnavailable(tech: let unavailable):
            print("Tech: Remaining techs \(unavailable) supported by context not available to load")
        }
    }
    
    public func select(tech protoTech: Tech<Context>.Type) {
        selectAndPrepare(tech: protoTech) { _ in }
    }
    
    private func cycle(techs: [Tech<Context>.Type], callback: @escaping (Tech<Context>.Type?) -> Void) {
        guard !techs.isEmpty else {
            callback(nil)
            return
        }
        let protoTech = techs.first!
        selectAndPrepare(tech: protoTech) { [weak self] success in
            if success {
                callback(protoTech)
            }
            else {
                let slice = Array(techs[1..<techs.count])
                self?.cycle(techs: slice, callback: callback)
            }
        }
    }
    
    private func selectAndPrepare(tech protoTech: Tech<Context>.Type, callback: @escaping (Bool) -> Void) {
        // 1. Same Tech, return
        guard activeTech != protoTech else { return }
        
        // 2. Change Tech
        unload(tech: selectedTech)
        
        // 3. Load new tech
        //      * Attach eventDispatcher
        //      * Switch selectedTech
        let realizedTech = protoTech.init(eventDispatcher: eventDispatcher)
        selectedTech = realizedTech
        realizedTech.prepare{ [weak self] in
            if let error = $0 {
                self?.eventDispatcher.onError(realizedTech, nil, error)
            }
        }
    }
    
    private func unload(tech: Tech<Context>) {
        // 1. Unload/deactivate current tech
        //      * Stop current playback
        //      * Deliver events
        //      * Dispatch analytics
        //      * Break eventDispatcher association
        
    }
    
    private enum CanPlay {
        case active(tech: Tech<Context>)
        case available(techs: [Tech<Context>.Type])
        case supportedButUnavailable(tech: [Tech<Context>.Type])
    }
    
    private func canPlay(source: Context.Source) -> CanPlay {
        // 1. Active Tech
        let selected = context.supportedTechs.contains{ $0 == activeTech }
        if selected { return .active(tech: selectedTech) }
        
        // 2. Available Techs
        let available = match(left: techs, right: context.supportedTechs)
        if !available.isEmpty { return .available(techs: available) }
        
        // 3. Supported But Unavailable Techs
        return .supportedButUnavailable(tech: not(in: techs, butIn: context.supportedTechs))
    }
    
    
    private func match(left: [Tech<Context>.Type], right: [Tech<Context>.Type]) -> [Tech<Context>.Type] {
        return left.filter{ val -> Bool in
            return right.contains{ val == $0 }
        }
    }
    
    private func not(in left: [Tech<Context>.Type], butIn right: [Tech<Context>.Type]) -> [Tech<Context>.Type] {
        return left.filter{ val -> Bool in
        return right.contains{ val != $0 }
        }
    }
    
    private func exists(left: [Tech<Context>.Type], right: [Tech<Context>.Type]) -> Bool {
        return left.reduce(false) { prev, next in
            return prev || right.contains{ $0 == next }
        }
    }
}

// MARK: - Analytics Generator
extension Player {
    /// Convenience function for setting `AnalyticsProvider`s through a generator.
    ///
    /// - parameter callback: closure to use for generating [`AnalyticsProvider`].
    /// - returns: `Self`
    @discardableResult
    public func analytics(callback: @escaping (Context.Source) -> [AnalyticsProvider]) -> Self {
        context.analyticsGenerator = callback
        return self
    }
}

// MARK: - PlayerEventPublisher
extension Player: EventPublisher {
    public typealias EventContext = Context
    
    /// Sets the callback to fire when the associated media is created but not yet loaded. Playback is not yet ready to start.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackCreated(callback: @escaping (Tech<Context>, Context.Source) -> Void) -> Self {
        eventDispatcher.onPlaybackCreated = callback
        return self
    }
    
    /// Sets the callback to fire when the associated media has loaded but is not playback ready.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self
    @discardableResult
    public func onPlaybackPrepared(callback: @escaping (Tech<Context>, Context.Source) -> Void) -> Self {
        eventDispatcher.onPlaybackPrepared = callback
        return self
    }
    
    /// Sets the callback to fire once the associated media has loaded and is ready for playback. At this point, starting playback should be possible.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackReady(callback: @escaping (Tech<Context>, Context.Source) -> Void) -> Self {
        eventDispatcher.onPlaybackReady = callback
        return self
    }
    
    /// Sets the callback to fire once the playback first starts. This is fired once.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackStarted(callback: @escaping (Tech<Context>, Context.Source) -> Void) -> Self {
        eventDispatcher.onPlaybackStarted = callback
        return self
    }
    
    /// Sets the callback to fire if playback rate for transitions from *non-zero* to *zero.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackPaused(callback: @escaping (Tech<Context>, Context.Source) -> Void) -> Self {
        eventDispatcher.onPlaybackPaused = callback
        return self
    }
    
    /// Sets the callback to fire if playback is resumed from a paused state.
    ///
    /// This will not fire if the playback has not yet been started, ie `onPlaybackStarted:` has not fired yet.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackResumed(callback: @escaping (Tech<Context>, Context.Source) -> Void) -> Self {
        eventDispatcher.onPlaybackResumed = callback
        return self
    }
    
    /// Sets the callback to fire once playback is stopped by user action.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackAborted(callback: @escaping (Tech<Context>, Context.Source) -> Void) -> Self {
        eventDispatcher.onPlaybackAborted = callback
        return self
    }
    
    /// Sets the callback to fire once playback reached the end of the current media, ie when playback reaches `duration`.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackCompleted(callback: @escaping (Tech<Context>, Context.Source) -> Void) -> Self {
        eventDispatcher.onPlaybackCompleted = callback
        return self
    }
    
    /// Sets the callback to fire whenever an `error` occurs. Errors are thrown from throughout the `player` lifecycle. Make sure to handle them. If appropriate, present valid information to *end users*.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onError(callback: @escaping (Tech<Context>?, Context.Source?, Context.ContextError) -> Void) -> Self {
        eventDispatcher.onError = callback
        return self
    }
    
    /// Sets the callback to fire whenever the current *Bitrate* changes.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onBitrateChanged(callback: @escaping (Tech<Context>, Context.Source, Double) -> Void) -> Self {
        eventDispatcher.onBitrateChanged = callback
        return self
    }
    
    /// Sets the callback to fire once buffering started.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onBufferingStarted(callback: @escaping (Tech<Context>, Context.Source) -> Void) -> Self {
        eventDispatcher.onBufferingStarted = callback
        return self
    }
    
    /// Sets the callback to fire once buffering stopped.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onBufferingStopped(callback: @escaping (Tech<Context>, Context.Source) -> Void) -> Self {
        eventDispatcher.onBufferingStopped = callback
        return self
    }
    
    /// Sets the callback to fire if user scrubs in player
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackScrubbed(callback: @escaping (Tech<Context>, Context.Source, Int64) -> Void) -> Self {
        eventDispatcher.onPlaybackScrubbed = callback
        return self
    }
    
    /// Sets the callback to fire once the current playback `duration` changes.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onDurationChanged(callback: @escaping (Tech<Context>, Context.Source) -> Void) -> Self {
        eventDispatcher.onDurationChanged = callback
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

