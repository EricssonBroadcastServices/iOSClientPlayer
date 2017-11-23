//
//  MediaContext.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Core protocol defining a strict context in which playback can take place.
///
/// This context should be considered a staging ground for defining, managing and preparing playback sessions.
public protocol MediaContext: class {
    /// Context related error
    associatedtype ContextError: Error
    
    /// Defines the individual source object used to initate a distinct playback session.
    associatedtype Source: MediaSource
    
    /// A generator closure which creates `AnalyticsProvider`s per `Source`.
    var analyticsGenerator: (Source) -> [AnalyticsProvider] { get set }
}
