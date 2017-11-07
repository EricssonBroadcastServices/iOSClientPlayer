//
//  AnalyticsEventPublisher.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-07-17.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// `AnalyticsEventPublisher` triggers events specified by the `AnalyticsProvider`.
public protocol AnalyticsEventPublisher: class {
    /// Events will be triggered on this `AnalyticsProvider`.
    var analyticsProviderGenerator: (() -> AnalyticsProvider)? { get set }
}

extension AnalyticsEventPublisher {
    /// Convenience function for setting an `AnalyticsProvider`, providing a chaining interface for configuration.
    ///
    /// - parameter provider: `AnalyticsProvider` to publish events to.
    /// - returns: `Self`
    @discardableResult
    public func analytics(callback: @escaping () -> AnalyticsProvider) -> Self {
        analyticsProviderGenerator = callback
        return self
    }
}
