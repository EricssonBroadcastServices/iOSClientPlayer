//
//  SessionShift.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-08-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public protocol SessionShift {
    var sessionShiftEnabled: Bool { get }
    
    func sessionShift(enabled: Bool) -> Self
    
    func sessionShift(enabled: Bool, offset: Int64) -> Self
}
