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
}


public protocol AnalyticsConnector: EventResponder {
    var providers: [AnalyticsProvider] { get set }
}


public class PassThroughConnector: AnalyticsConnector {
    public var providers: [AnalyticsProvider] = []
    
    public func onCreated<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onCreated(tech: tech, source: source) }
    }
    
    public func onPrepared<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onPrepared(tech: tech, source: source) }
    }
    
    public func onReady<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onReady(tech: tech, source: source) }
    }
    
    public func onStarted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onStarted(tech: tech, source: source) }
    }
    
    public func onPaused<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source: MediaSource {
        providers.forEach{ $0.onPaused(tech: tech, source: source) }
    }
    
    public func onResumed<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onResumed(tech: tech, source: source) }
    }
    
    public func onAborted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onAborted(tech: tech, source: source) }
    }
    
    public func onCompleted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onCompleted(tech: tech, source: source) }
    }
    
    public func onError<Tech, Source, Context>(tech: Tech, source: Source?, error: PlayerError<Tech, Context>) where Tech : PlaybackTech, Source : MediaSource, Context : MediaContext {
        providers.forEach{ $0.onError(tech: tech, source: source, error: error) }
    }
    
    public func onBitrateChanged<Tech, Source>(tech: Tech, source: Source, bitrate: Double) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onBitrateChanged(tech: tech, source: source, bitrate: bitrate) }
    }
    
    public func onBufferingStarted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onBufferingStopped(tech: tech, source: source) }
    }
    
    public func onBufferingStopped<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onBufferingStopped(tech: tech, source: source) }
    }
    
    public func onScrubbedTo<Tech, Source>(tech: Tech, source: Source, offset: Int64) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onScrubbedTo(tech: tech, source: source, offset: offset) }
    }
    
    public func onDurationChanged<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{ $0.onDurationChanged(tech: tech, source: source)}
    }
    
}

public struct AnalyticsLogger: AnalyticsProvider {
    public func onCreated<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"🏗 onCreated",source.playSessionId)
    }
    
    public func onPrepared<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"🛁 onPrepared",source.playSessionId)
    }
    
    public func onReady<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"👍 onReady",source.playSessionId)
    }
    
    public func onStarted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"🎬 onStarted",source.playSessionId)
    }
    
    public func onPaused<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"⏸ onPaused",source.playSessionId)
    }
    
    public func onResumed<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"▶️ onResumed",source.playSessionId)
    }
    
    public func onAborted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"⏹ onAborted",source.playSessionId)
    }
    
    public func onCompleted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"🏁 onCompleted",source.playSessionId)
    }
    
    public func onError<Tech, Source, Context>(tech: Tech, source: Source?, error: PlayerError<Tech, Context>) where Tech : PlaybackTech, Source : MediaSource, Context : MediaContext {
        print("🏷 AnalyticsLogger",type(of: tech),"🚨 onError",source?.playSessionId ?? "")
    }
    
    public func onBitrateChanged<Tech, Source>(tech: Tech, source: Source, bitrate: Double) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"📶 onBitrateChanged [\(bitrate)]",source.playSessionId)
    }
    
    public func onBufferingStarted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"⏳ onBufferingStarted",source.playSessionId)
    }
    
    public func onBufferingStopped<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"⌛ onBufferingStopped",source.playSessionId)
    }
    
    public func onScrubbedTo<Tech, Source>(tech: Tech, source: Source, offset: Int64) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"🕘 onScrubbedTo [\(offset)]",source.playSessionId)
    }
    
    public func onDurationChanged<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        print("🏷 AnalyticsLogger",type(of: tech),"📅 onDurationChanged",source.playSessionId)
    }
}
