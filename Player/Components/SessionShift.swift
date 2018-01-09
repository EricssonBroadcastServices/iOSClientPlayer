//
//  SessionShift.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-08-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// SessionShift allows playback to start at a specified offset.
public protocol SessionShift: class {
    /// Returns an `offset` if it has been specified, else `nil`.
    ///
    /// No specified `offset` does not necessary mean *Session Shift* is disabled.
    var sessionShiftOffset: Int64? { get }
    
    /// Is *Session Shift* enabled or not.
    var sessionShiftEnabled: Bool { get }
    
    /// By specifying `true` you are signaling `sessionShift` is enabled and a starting `offset` will be supplied at *some time*, when is undefined.
    /// 
    /// This is useful when, for example, the `offset` is supplied by an external party (like a web service). If the `offset` to the starting position is known beforehand `sessionShift(enabledAt: someOffset)` should be used instead.
    ///
    /// - parameter enabled: `true` if enabled, `false` otherwise
    func sessionShift(enabled: Bool)
    
    /// Configure *Session Shift* manually to start at the supplied `offset`
    ///
    /// - parameter offset: Offset in the related stream where playback should start
    func sessionShift(enabledAt offset: Int64)
}

extension Player where Tech: SessionShift {
    /// Returns an `offset` if it has been specified, else `nil`.
    ///
    /// No specified `offset` does not necessary mean *Session Shift* is disabled.
    public var sessionShiftOffset: Int64? {
        return tech.sessionShiftOffset
    }
    
    /// Is *Session Shift* enabled or not.
    public var sessionShiftEnabled: Bool {
        return tech.sessionShiftEnabled
    }
    
    /// By specifying `true` you are signaling `sessionShift` is enabled and a starting `offset` will be supplied at *some time*, when is undefined.
    ///
    /// This is useful when, for example, the `offset` is supplied by an external party (like a web service). If the `offset` to the starting position is known beforehand `sessionShift(enabledAt: someOffset)` should be used instead.
    ///
    /// - parameter enabled: `true` if enabled, `false` otherwise
    /// - returns: `Self`
    @discardableResult
    public func sessionShift(enabled: Bool) -> Self {
        tech.sessionShift(enabled: enabled)
        return self
    }
    
    /// Configure *Session Shift* manually to start at the supplied `offset`
    ///
    /// - parameter offset: Offset in the related stream where playback should start
    /// - returns: `Self`
    @discardableResult
    public func sessionShift(enabledAt offset: Int64) -> Self {
        tech.sessionShift(enabledAt: offset)
        return self
    }
}
