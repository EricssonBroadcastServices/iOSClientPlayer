//
//  TraceProvider.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-05-21.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

/// Endpoint hook for dealing with *Trace* analytics data.
///
/// This could be useful for logging custom events.
public protocol TraceProvider {
    /// Should process the specified *Trace* `data`
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    /// - parameter data: Any data describing the event in JSON format.
    func onTrace<Tech, Source>(tech: Tech?, source: Source?, data: [String: Any]) where Tech: PlaybackTech, Source: MediaSource
}
