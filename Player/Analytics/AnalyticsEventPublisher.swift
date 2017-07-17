//
//  AnalyticsEventPublisher.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-07-17.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public protocol AnalyticsEventPublisher: class {
    var analyticsProvider: AnalyticsProvider? { get set }
}

extension AnalyticsEventPublisher {
    public func analytics(provider: AnalyticsProvider) -> Self {
        analyticsProvider = provider
        return self
    }
}
