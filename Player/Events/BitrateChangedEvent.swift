//
//  BitrateChangedEvent.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public struct BitrateChangedEvent {
    unowned public let player: Player
    
    /// Measured in bits/sec
    public let previousRate: Double?
    
    /// Measured in bits/sec
    public let currentRate: Double
}
