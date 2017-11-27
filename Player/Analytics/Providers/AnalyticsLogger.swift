//
//  AnalyticsLogger.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Simple `AnalyticsProvider` that logs any events it receives to the console.
public struct AnalyticsLogger: AnalyticsProvider {
    public init() { }
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
