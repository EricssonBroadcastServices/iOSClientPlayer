//
//  BitrateChangedEvent.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public struct BitrateChangedEvent {
    unowned let player: Player
    let previousRate: Double?
    let currentRate: Double
}
