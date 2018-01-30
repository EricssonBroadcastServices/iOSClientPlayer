//
//  Tech.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

/// A `PlaybackTech` is defined as a technology through which playback in a specified `Context` can occur.
public protocol PlaybackTech: class {
    /// Error specific to the `Tech`
    associatedtype TechError: ExpandedError
    
    /// Warning message associated with the `Tech`
    associatedtype TechWarning: WarningMessage
    
    /// Specifies the required data to configure the `Tech`.
    ///
    /// This could include `DRM` agents, `url`, app tokens or `Tech` specific environment variables
    associatedtype Configuration
    
    /// The `MediaContext` defining the playback. This can be a generic context or one stricly tied to the `Tech`
    associatedtype Context: MediaContext
    
    /// Used by `Player` to register event callbacks.
    ///
    /// `Tech`s are expected to trigger defined events according to their specification.
    var eventDispatcher: EventDispatcher<Context, Self> { get }
    
    /// Retrieve the currently active source, if any
    var currentSource: Context.Source? { get }
}

