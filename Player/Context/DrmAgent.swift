//
//  DrmAgent.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public enum DrmAgent {
    case selfContained
    case external(agent: ExternalDrm)
}

public protocol ExternalDrm { }
