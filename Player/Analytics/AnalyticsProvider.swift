//
//  AnalyticsProvider.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-07-17.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Typealias for an `EventResponder` associated with analytics.
public typealias AnalyticsProvider = EventResponder

/// Specifies a set of events that will be listened to.
public protocol EventResponder {
    /// Triggered when the requested media is created, but not yet loaded
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onCreated<Context>(tech: Tech<Context>, source: Context.Source)
    
    /// Triggered once the requested media is loaded
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onPrepared<Context>(tech: Tech<Context>, source: Context.Source)
    
    /// Triggered when playback is ready to start
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onReady<Context>(tech: Tech<Context>, source: Context.Source)
    
    /// Triggered once the playback starts for the first time
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onStarted<Context>(tech: Tech<Context>, source: Context.Source)
    
    /// Triggered by the user pausing playback
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onPaused<Context>(tech: Tech<Context>, source: Context.Source)
    
    /// Triggered by the user resuming playback
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onResumed<Context>(tech: Tech<Context>, source: Context.Source)
    
    /// Triggered by the user aborting playback
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onAborted<Context>(tech: Tech<Context>, source: Context.Source)
    
    /// Triggered once playback reaches end of stream
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onCompleted<Context>(tech: Tech<Context>, source: Context.Source)
    
    /// Triggered if the player encounters an error during its lifetime
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    /// - parameter error: `Error` encountered
    func onError<Context>(tech: Tech<Context>, source: Context.Source, error: Context.ContextError)
    
    /// Triggered when the bitrate changes
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    /// - parameter bitrate: New bitrate
    func onBitrateChanged<Context>(tech: Tech<Context>, source: Context.Source, bitrate: Double)
    
    /// Triggered when buffering is required
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onBufferingStarted<Context>(tech: Tech<Context>, source: Context.Source)
    
    /// Triggered when buffering finished
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onBufferingStopped<Context>(tech: Tech<Context>, source: Context.Source)
    
    /// Triggered by the user seeking to time
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    /// - parameter offset: New offset
    func onScrubbedTo<Context>(tech: Tech<Context>, source: Context.Source, offset: Int64)
    
    /// Triggered when the duration of `source` changes
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    func onDurationChanged<Context>(tech: Tech<Context>, source: Context.Source)
}
