//
//  PlayerEventPublisher.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Event publishing defines a set of events that can be listened to.
public protocol EventPublisher {
    associatedtype EventContext: PlaybackContext
    
    /// Published when associated media is created but not yet loaded. Playback is not yet ready to start.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onPlaybackCreated(callback: @escaping (Tech<EventContext>, EventContext.Source) -> Void) -> Self
    
    /// Published when the associated media has loaded but is not playback ready.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onPlaybackPrepared(callback: @escaping (Tech<EventContext>, EventContext.Source) -> Void) -> Self
    
    // MARK: Playback
    /// Published when the associated media has loaded and is ready for playback. At this point, starting playback should be possible.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onPlaybackReady(callback: @escaping (Tech<EventContext>, EventContext.Source) -> Void) -> Self
    
    /// Published once the playback first starts. This should be a one-time-event.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onPlaybackStarted(callback: @escaping (Tech<EventContext>, EventContext.Source) -> Void) -> Self
    
    /// Published when playback is paused for some reason.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onPlaybackPaused(callback: @escaping (Tech<EventContext>, EventContext.Source) -> Void) -> Self
    
    /// Published when playback is resumed from a paused state for some reason.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onPlaybackResumed(callback: @escaping (Tech<EventContext>, EventContext.Source) -> Void) -> Self

    /// Published when playback is stopped by user action.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onPlaybackAborted(callback: @escaping (Tech<EventContext>, EventContext.Source) -> Void) -> Self
    
    /// Published when playback reached the end of the current media, ie when playback reaches `duration`.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onPlaybackCompleted(callback: @escaping (Tech<EventContext>, EventContext.Source) -> Void) -> Self
    
    
    
    /// Published whenever an `error` occurs.
    ///
    /// - parameter callback: callback to fire once the event is fired. `PlayerEventError` specifies that error.
    /// - returns: `Self`
    func onError(callback: @escaping (Tech<EventContext>?, EventContext.Source?, EventContext.ContextError) -> Void) -> Self
    
    // MARK: Configuration
    /// Published whenever the current *Bitrate* changes.
    ///
    /// - parameter callback: callback to fire once the event is fired. `BitrateChangedEvent` specifies the event.
    /// - returns: `Self`
    func onBitrateChanged(callback: @escaping (Tech<EventContext>, EventContext.Source, Double) -> Void) -> Self
    
    /// Published once buffering started.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onBufferingStarted(callback: @escaping (Tech<EventContext>, EventContext.Source) -> Void) -> Self
    
    /// Published once buffering stopped.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onBufferingStopped(callback: @escaping (Tech<EventContext>, EventContext.Source) -> Void) -> Self
    
    /// Published when user scrubs in the player.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onPlaybackScrubbed(callback: @escaping (Tech<EventContext>, EventContext.Source, Int64) -> Void) -> Self
    
    /// Published if the current playback `duration` changed.
    ///
    /// - parameter callback: callback to fire once the event is fired.
    /// - returns: `Self`
    func onDurationChanged(callback: @escaping (Tech<EventContext>, EventContext.Source) -> Void) -> Self
}
