//
//  StartTime.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-08-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// SessionShift allows playback to start at a specified offset.
public protocol StartTime: class {
    /// Returns a target buffer `offset` to start playback if it has been specified, else `nil`. (milliseconds)
    var startPosition: Int64? { get }
    
    /// Returns a target timestamp in wallclock unix epoch time to start playback if it has been specified, else `nil`. (milliseconds)
    var startTime: Int64? { get }
    
    /// Should set the `startPosition` (in milliseconds) to the specified `position` relative to the playback buffer.
    ///
    /// Specifying `nil` revert to the default behaviour for startup
    func startTime(atPosition position: Int64?)
    
    /// Should set the `startTime` to the specified `timestamp` in wallclock unix epoch time. (in milliseconds)
    ///
    /// Specifying `nil` revert to the default behaviour for startup
    func startTime(atTime timestamp: Int64?)
}

extension Player where Tech: StartTime {
    
    /// Returns a target buffer `offset` to start playback if it has been specified, else `nil`.
    public var startPosition: Int64? {
        return tech.startPosition
    }
    
    /// Returns a target timestamp in wallclock unix epoch time to start playback if it has been specified, else `nil`.
    public var startTime: Int64? {
        return tech.startTime
    }
    
    /// Should set the `startPosition` (in milliseconds) to the specified `position` relative to the playback buffer.
    ///
    /// Specifying `nil` revert to the default behaviour for startup
    public func startTime(atPosition position: Int64?) {
        tech.startTime(atPosition: position)
    }
    
    /// Should set the `startTime` to the specified `timestamp` in wallclock unix epoch time. (in milliseconds)
    ///
    /// Specifying `nil` revert to the default behaviour for startup
    public func startTime(atTime timestamp: Int64?) {
        tech.startTime(atTime: timestamp)
    }
}
