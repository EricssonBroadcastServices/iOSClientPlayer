//
//  AnalyticsProvider.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-07-17.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Specifies a set of events for which analytics can be associated.
public protocol AnalyticsProvider {
    /// Triggered when the requested media is created, but not yet loaded
    ///
    /// - parameter player: `Player` broadcasting the event
    func playbackCreatedEvent(player: Player)
    
    /// Triggered once the requested media is loaded
    ///
    /// - parameter player: `Player` broadcasting the event
    func playbackPreparedEvent(player: Player)
    
    /// Triggered if the player encounters an error during its lifetime
    ///
    /// - parameter player: `Player` broadcasting the event
    /// - parameter error: `PlayerError` causing the event to fire
    func playbackErrorEvent(player: Player, error: PlayerError)
    
    /// Triggered when the bitrate changes
    ///
    /// - parameter event: Event describing the bitrate change
    func playbackBitrateChanged(event: BitrateChangedEvent)
    
    /// Triggered when buffering is required
    ///
    /// - parameter player: `Player` broadcasting the event
    func playbackBufferingStarted(player: Player)
    
    /// Triggered when buffering finished
    ///
    /// - parameter player: `Player` broadcasting the event
    func playbackBufferingStopped(player: Player)
    
    /// Triggered when playback is ready to start
    ///
    /// - parameter player: `Player` broadcasting the event
    func playbackReadyEvent(player: Player)
    
    /// Triggered once playback reaches end of stream
    ///
    /// - parameter player: `Player` broadcasting the event
    func playbackCompletedEvent(player: Player)
    
    /// Triggered once the playback starts for the first time
    ///
    /// - parameter player: `Player` broadcasting the event
    func playbackStartedEvent(player: Player)
    
    /// Triggered by the user aborting playback
    ///
    /// - parameter player: `Player` broadcasting the event
    func playbackAbortedEvent(player: Player)
    
    /// Triggered by the user pausing playback
    ///
    /// - parameter player: `Player` broadcasting the event
    func playbackPausedEvent(player: Player)
    
    /// Triggered by the user resuming playback
    ///
    /// - parameter player: `Player` broadcasting the event
    func playbackResumedEvent(player: Player)


    /// Triggered by the user seeking to time
    ///
    /// - parameter player: `Player` broadcasting the evet
    /// - parameter offset: `Int64` time beeing seekd
    func playbackScrubbedTo(player: Player, offset: Int64)
}
