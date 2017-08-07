//
//  SessionShift.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-08-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public protocol SessionShift {
    /// Returns an `offset` if it has been specified, else nil.
    ///
    /// - note: No offset can be specified if *Session Shift* is not enabled.
    var sessionShiftOffset: Int64? { get }
    
    /// Is *Session Shift* enabled or not.
    var sessionShiftEnabled: Bool { get }
    
    /// By specifying `true` you are instructing the `player` to expect an offset to be supplied at a later time.
    ///
    /// - note: This method is inteded to use during setup to signal the player an `offset` to the starting position will be supplied before playback should begin. This is useful for example when that `offset` is supplied by an external party, like a web service. If the `offset` to the starting position is known beforehand `sessionShift(enabledAt: someOffset)` should be used instead.
    ///
    /// - parameter enabled: `true` if enabled, `false` otherwise
    /// - returns: `Self`
    func sessionShift(enabled: Bool) -> Self
    
    /// Configure *Session Shift* manually to start at the supplied `offset`
    ///
    /// - parameter offset: Offset in the related stream where playback should start
    /// - returns: `Self`
    func sessionShift(enabledAt offset: Int64) -> Self
}
