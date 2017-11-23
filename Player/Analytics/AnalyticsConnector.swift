//
//  AnalyticsConnector.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// `AnalyticsConnector` is responsible for managing the interaction between raw `PlaybackTech` events, tailored to the need of specific `AnalyticsProvider`s.
public protocol AnalyticsConnector: EventResponder {
    /// Analytics connector will manage, filter and possibly forward events to all providers specified here
    var providers: [AnalyticsProvider] { get set }
}
