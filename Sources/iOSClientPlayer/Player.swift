//
//  Player.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation



/// Generic class which implements a base set of functionality not specific to actual playback of media sources. This functionality is instead aquired through *Feature Components* directly tied to the underlying `PlaybackTech` and `MediaContext`.
///
/// In practice, this means `Player`s with different *tech* or *media sources* can express context sensitive methods in a highly configurable way.
public final class Player<Tech: PlaybackTech> {
    /// Active `PlaybackTech`
    fileprivate(set) public var tech: Tech
    
    /// Current `MediaContext`
    fileprivate(set) public var context: Tech.Context
    
    public init(tech: Tech, context: Tech.Context) {
        self.context = context
        self.tech = tech
    }
}

// MARK: - PlayerEventPublisher
extension Player {
    /// Sets the callback to fire when the associated media is created but not yet loaded. Playback is not yet ready to start.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackCreated(callback: @escaping (Player<Tech>, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackCreated = { [weak self] tech, source in
            guard let `self` = self else { return }
            callback(self, source)
        }
        return self
    }

    /// Sets the callback to fire when the associated media has loaded but is not playback ready.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self
    @discardableResult
    public func onPlaybackPrepared(callback: @escaping (Player<Tech>, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackPrepared = { [weak self] tech, source in
            guard let `self` = self else { return }
            callback(self,source)
        }
        return self
    }

    /// Sets the callback to fire once the associated media has loaded and is ready for playback. At this point, starting playback should be possible.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackReady(callback: @escaping (Player<Tech>, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackReady =  { [weak self] tech, source in
            guard let `self` = self else { return }
            callback(self,source)
        }
        return self
    }

    /// Sets the callback to fire once the playback first starts. This is fired once.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackStarted(callback: @escaping (Player<Tech>, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackStarted =  { [weak self] tech, source in
            guard let `self` = self else { return }
            callback(self,source)
        }
        return self
    }

    /// Sets the callback to fire if playback rate for transitions from *non-zero* to *zero.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackPaused(callback: @escaping (Player<Tech>, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackPaused =  { [weak self] tech, source in
            guard let `self` = self else { return }
            callback(self,source)
        }
        return self
    }

    /// Sets the callback to fire if playback is resumed from a paused state.
    ///
    /// This will not fire if the playback has not yet been started, ie `onPlaybackStarted:` has not fired yet.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackResumed(callback: @escaping (Player<Tech>, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackResumed =  { [weak self] tech, source in
            guard let `self` = self else { return }
            callback(self,source)
        }
        return self
    }

    /// Sets the callback to fire once playback is stopped by user action.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackAborted(callback: @escaping (Player<Tech>, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackAborted =  { [weak self] tech, source in
            guard let `self` = self else { return }
            callback(self,source)
        }
        return self
    }

    /// Sets the callback to fire once playback reached the end of the current media, ie when playback reaches `duration`.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackCompleted(callback: @escaping (Player<Tech>, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackCompleted =  { [weak self] tech, source in
            guard let `self` = self else { return }
            callback(self,source)
        }
        return self
    }

    /// Sets the callback to fire whenever an `error` occurs. Errors are thrown from throughout the `player` lifecycle. Make sure to handle them. If appropriate, present valid information to *end users*.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onError(callback: @escaping (Player<Tech>, Tech.Context.Source?, PlayerError<Tech, Tech.Context>) -> Void) -> Self {
        tech.eventDispatcher.onError =  { [weak self] tech, source, error in
            guard let `self` = self else { return }
            callback(self,source,error)
        }
        return self
    }

    /// Sets the callback to fire whenever the current *Bitrate* changes.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onBitrateChanged(callback: @escaping (Player<Tech>, Tech.Context.Source, Double) -> Void) -> Self {
        tech.eventDispatcher.onBitrateChanged =  { [weak self] tech, source, bitrate in
            guard let `self` = self else { return }
            callback(self,source,bitrate)
        }
        return self
    }

    /// Sets the callback to fire once buffering started.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onBufferingStarted(callback: @escaping (Player<Tech>, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onBufferingStarted =  { [weak self] tech, source in
            guard let `self` = self else { return }
            callback(self,source)
        }
        return self
    }

    /// Sets the callback to fire once buffering stopped.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onBufferingStopped(callback: @escaping (Player<Tech>, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onBufferingStopped =  { [weak self] tech, source in
            guard let `self` = self else { return }
            callback(self,source)
        }
        return self
    }

    /// Sets the callback to fire if user scrubs in player
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onPlaybackScrubbed(callback: @escaping (Player<Tech>, Tech.Context.Source, Int64) -> Void) -> Self {
        tech.eventDispatcher.onPlaybackScrubbed = { [weak self] tech, source, timestamp in
            guard let `self` = self else { return }
            callback(self,source,timestamp)
        }
        return self
    }

    /// Sets the callback to fire once the current playback `duration` changes.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onDurationChanged(callback: @escaping (Player<Tech>, Tech.Context.Source) -> Void) -> Self {
        tech.eventDispatcher.onDurationChanged =  { [weak self] tech, source in
            guard let `self` = self else { return }
            callback(self,source)
        }
        return self
    }
    /// Sets the callback to fire once the current playback `duration` changes.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onWarning(callback: @escaping (Player<Tech>, Tech.Context.Source?, PlayerWarning<Tech, Tech.Context>) -> Void) -> Self {
        tech.eventDispatcher.onWarning = { [weak self] tech, source, warning in
            guard let `self` = self else { return }
            callback(self,source,warning)
        }
        return self
    }
    
    /// Sets the callback to fire once the current playback `DateRangeMetadata` changes.
    ///
    /// #EXT-X-DATERANGE tag will be used to define date range metadata in a media playlist.
    /// This tag is useful for defining timed metadata for interstitial regions such as advertisements, but can be used to define any timed metadata needed by your stream.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    @discardableResult
    public func onDateRangeMetadataChanged(callback: @escaping ([AVDateRangeMetadataGroup], IndexSet, IndexSet) -> Void) -> Self {
        tech.eventDispatcher.onDateRangeMetadataChanged = { [weak self] metadata, indexesOfNewGroups, indexesOfModifiedGroups in
            guard let `self` = self else { return }
            callback(metadata, indexesOfNewGroups, indexesOfModifiedGroups)
        }
        return self
    }
}
