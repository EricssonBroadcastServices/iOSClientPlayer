//
//  NetworkLimitation.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-21.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

public protocol NetworkLimitation {
    /// Should specify the desired limit, in bits per second, of network bandwidth consumption allowed during playback or `nil` if no limit is required
    var preferredMaxBitrate: Int64? { get set }
}
