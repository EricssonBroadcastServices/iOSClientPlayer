//
//  ExposurePlayback.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

public protocol ExposurePlayback {
    func stream(playback entitlement: PlaybackEntitlement)
    func offline(playback entitlement: PlaybackEntitlement)
}
