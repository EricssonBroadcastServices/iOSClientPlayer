//
//  NetworkLimitation.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-21.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

public protocol NetworkLimitation {
    var preferredMaxBitrate: Int64? { get set }
    var allowCellularAccess: Bool { get set }
}
