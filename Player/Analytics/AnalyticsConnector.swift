//
//  AnalyticsConnector.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// `AnalyticsConnector` is responsible for managing the interaction between raw `PlaybackTech` events, tailored to the need of specific `AnalyticsProvider`s.
public protocol AnalyticsConnector: EventResponder, TraceProvider, TechDeallocationEventProvider {
    /// Analytics connector will manage, filter and possibly forward events to all providers specified here
    var providers: [AnalyticsProvider] { get set }
}

extension AnalyticsConnector {
    public func onTrace<Tech, Source>(tech: Tech?, source: Source?, data: [String : Any]) where Tech : PlaybackTech, Source : MediaSource {
        providers.forEach{
            if let provider = $0 as? TraceProvider {
                provider.onTrace(tech: tech, source: source, data: data)
            }
        }
    }
}

extension AnalyticsConnector {
    public func onTechDeallocated<Source>(beforeMediaPreparationFinalizedOf mediaSource: Source) where Source : MediaSource {
        providers.forEach{
            if let provider = $0 as? TechDeallocationEventProvider {
                provider.onTechDeallocated(beforeMediaPreparationFinalizedOf: mediaSource)
            }
        }
    }
}
