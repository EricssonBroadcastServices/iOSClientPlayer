//
//  PassThroughConnector.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Simple `AnalyticsConnector` that forwards all events to the specified `AnalyticsProvider`s
public class PassThroughConnector: AnalyticsConnector {
    public init(providers: [AnalyticsProvider] = []) {
        self.providers = providers
    }
    
    deinit {
        print("PassThroughConnector deinit")
    }
    
    public var providers: [AnalyticsProvider]
    
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
        providers.forEach{ $0.onBufferingStarted(tech: tech, source: source) }
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
    
    public func onWarning<Tech, Source, Context>(tech: Tech, source: Source?, warning: PlayerWarning<Tech, Context>) where Tech : PlaybackTech, Source : MediaSource, Context : MediaContext {
        providers.forEach{ $0.onWarning(tech: tech, source: source, warning: warning) }
    }
}
