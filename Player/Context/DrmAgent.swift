//
//  DrmAgent.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Loose definition of a `DRM` agent.
public enum DrmAgent {
    /// The specified agent is self contained. This normally indicates `DRM` is either handled by the related `Tech`, managed by the `MediaContext` or absent (as in the form of *unencrypted* playback)
    case selfContained
    
    /// Defines an external agent, normally supplied to the related `Tech`
    case external(agent: ExternalDrm)
}

/// Adopted by external `DRM` solutions.
public protocol ExternalDrm { }
