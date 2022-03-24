//
//  Airplay.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-03-15.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

public protocol AirplayHandler: class {
    /// Defines an interaction point for handling status events related to Airplay
    ///
    /// - parameter active: If *Airplay* was tuned on of off
    /// - parameter tech: The tech used to play `source`
    /// - parameter source: The `Source` currently under playback for which the airplay event occured.
    func handleAirplayEvent<Tech, Source>(active: Bool, tech: Tech, source: Source?) where Tech: PlaybackTech, Source: MediaSource
}
