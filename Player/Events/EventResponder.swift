//
//  EventResponder.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Specifies a set of events that will be listened to.
public protocol EventResponder {
    /// Triggered when the requested media is created, but not yet loaded
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onCreated<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
    
    /// Triggered once the requested media is loaded
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onPrepared<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
    
    /// Triggered when playback is ready to start
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onReady<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
    
    /// Triggered once the playback starts for the first time
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onStarted<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
    
    /// Triggered by the user pausing playback
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onPaused<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
    
    /// Triggered by the user resuming playback
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onResumed<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
    
    /// Triggered by the user aborting playback
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onAborted<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
    
    /// Triggered once playback reaches end of stream
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onCompleted<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
    
    
    
    /// Triggered if the player encounters an error during its lifetime
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    /// - parameter error: `Error` encountered
    func onError<Tech, Source, Context>(tech: Tech, source: Source?, error: PlayerError<Tech, Context>) where Tech: PlaybackTech, Source: MediaSource, Context: MediaContext
    
    /// Triggered when the bitrate changes
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    /// - parameter bitrate: New bitrate
    func onBitrateChanged<Tech, Source>(tech: Tech, source: Source, bitrate: Double) where Tech: PlaybackTech, Source: MediaSource
    
    /// Triggered when buffering is required
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onBufferingStarted<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
    
    /// Triggered when buffering finished
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onBufferingStopped<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
    
    /// Triggered by the user seeking to time
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    /// - parameter offset: New offset
    func onScrubbedTo<Tech, Source>(tech: Tech, source: Source, offset: Int64) where Tech: PlaybackTech, Source: MediaSource
    
    /// Triggered when the duration of `source` changes
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onDurationChanged<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
    
//    /// Triggered if the current `MediaSource` was reloaded
//    ///
//    /// - parameter tech: `Tech` broadcasting the event
//    /// - parameter source: `MediaSource` causing the even
//    func onReloaded<Tech, Source>(tech: Tech, source: Source) where Tech: PlaybackTech, Source: MediaSource
}
