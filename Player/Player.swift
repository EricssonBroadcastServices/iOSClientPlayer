//
//  Player.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

public protocol PlaybackContext {
//    associatedtype ContextError: PlaybackContextError
    associatedtype Source: MediaSource
    
    /// TODO: Fetch/generate the playback context. This is optionaly an async process, contacting an external server.
//    func fetch(callback: @escaping (Source?, ContextError?) -> Void)
    
    var preferredTech: Tech<Source>? { get }
    var analyticsGenerator: (Source) -> [AnalyticsProvider] { get set }
    
//    /// Returns a string created from the UUID, such as "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
//    ///
//    /// A unique playSessionId should be generated for each new playSession.
//    fileprivate static func generatePlaySessionId() -> String {
//      return UUID().uuidString
//    }
}


public struct ManifestContext: PlaybackContext {
    public typealias Source = Manifest
    public let source: Manifest
    
    public let preferredTech: Tech<Manifest>? = NativeHLS<Manifest>()
    public var analyticsGenerator: (Source) -> [AnalyticsProvider] = { _ in return [] }
}

public struct Manifest: MediaSource {
    public typealias SourceError = ManifestError
    
    public let drmAgent = DrmAgent.selfContained
    public let playSessionId: String
    public let url: URL
    
    func loadableBy(tech: Tech<Manifest>) -> Bool {
        return tech is NativeHLS<Manifest>
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

public protocol MediaSource {
    associatedtype SourceError: MediaSourceError
    associatedtype Connector: AnalyticsConnector
    var analyticsConnector: Connector { get }
    
    /// Optional DRM agent used to validate the context
    var drmAgent: DrmAgent { get }
    
    /// A unique identifier for this playback session
    var playSessionId: String { get }
    
    /// The location for this media
    var url: URL { get }
    
//    func load<Tech: Tech>(using tech: Tech, callback: @escaping (Tech.TechError?) -> Void)
}

extension MediaSource {
    func loadableBy(tech: Tech<Self>) -> Bool {
        return false
    }
}

extension MediaSource {
    var externalDrmAgent: ExternalDrm? {
        switch drmAgent {
        case .external(agent: let agent): return agent
        case .selfContained: return nil
        }
    }
}

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

public protocol FairplayRequesterTest: ExternalDrm, AVAssetResourceLoaderDelegate {
    
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

open class Tech<Source: MediaSource>: MediaRendering, MediaPlayback {
    public func configure(playerView: UIView) { }
    
    public func play() { }
    
    public func pause() { }
    
    public func stop() { }
    
    public var isPlaying: Bool { return false }
    
    public func seek(to timeInterval: Int64) { }
    
    public var currentTime: Int64 { return 0 }
    
    public var duration: Int64? { return nil }
    
    public var currentBitrate: Double? { return nil }
    
    
    public func load(source: Source) { }
}



public class NativeHLS<Source: MediaSource>: Tech<Source> {
    
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
        print("NativeHLS.deinit")
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

public final class Player<Context: PlaybackContext> {
    private let techs: [Tech<Context.Source>]
    fileprivate var selectedTech: Tech<Context.Source>
    fileprivate(set) public var source: Context.Source?
    
    private let context: Context
    public init(context: Context, defaultTech: Tech<Context.Source> = NativeHLS<Context.Source>()) {
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

// MARK: - Events
/// Player Item Status Change Events
extension NativeHLS {
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
extension NativeHLS {
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
extension NativeHLS {
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
extension NativeHLS {
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
extension NativeHLS {
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
extension NativeHLS {
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
extension NativeHLS {
    /// Subscribes to and handles `AVPlayer.currentItem` changes.
    fileprivate func handleCurrentItemChanges() {
        playerObserver.observe(path: .currentItem, on: avPlayer) { player, change in
            print("Player.currentItem changed",player, change.new, change.old)
            // TODO: Do we handle programChange here?
        }
    }
}

/// Audio Session Interruption Events
extension NativeHLS {
    /// Subscribes to *Audio Session Interruption* `Notification`s.
    fileprivate func handleAudioSessionInteruptionEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(NativeHLS.audioSessionInterruption), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
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
extension NativeHLS {
    /// Backgrounding the player events.
    fileprivate func handleBackgroundingEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(NativeHLS.appDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NativeHLS.appWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NativeHLS.appWillTerminate), name: .UIApplicationWillTerminate, object: nil)
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
