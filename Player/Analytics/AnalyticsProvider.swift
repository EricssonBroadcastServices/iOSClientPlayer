//
//  AnalyticsProvider.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-07-17.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public protocol AnalyticsProvider {
    /// Triggered when the requested media is created, but not yet loaded
    func playbackCreatedEvent(player: Player)
    
    /// Triggered once the requested media is loaded
    func playbackPreparedEvent(player: Player)
    
    /// Triggered if the player encounters an error during its lifetime
    func playbackErrorEvent(player: Player, error: PlayerError)
    
    /// Triggered when the bitrate changes
    func playbackBitrateChanged(event: BitrateChangedEvent)
    
    /// Triggered when buffering is required
    func playbackBufferingStarted(player: Player)
    
    /// Triggered when buffering finished
    func playbackBufferingStopped(player: Player)
    
    /// Triggered once playback reaches end of stream
    func playbackCompletedEvent(player: Player)
}
