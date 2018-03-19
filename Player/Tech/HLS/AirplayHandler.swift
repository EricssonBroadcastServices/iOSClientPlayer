//
//  Airplay.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-03-15.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

public protocol AirplayHandler: class {
    func handleAirplayEvent<Tech, Source>(active: Bool, tech: Tech, source: Source?) where Tech: PlaybackTech, Source: MediaSource
}
