//
//  HLSNative+StartTime.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// `HLSNative` adoption of `StartTime`
extension HLSNative: StartTime {
    /// Internal state for tracking Bookmarks.
    internal enum StartOffset {
        /// Default behaviour applies
        case defaultStartTime
        
        /// Playback should start from the specified `offset` into the buffer (milliseconds)
        case startPosition(position: Int64)
        
        /// Playback should start from the specified `wallclock timestamp` in unix epoch time (milliseconds)
        case startTime(time: Int64)
    }
    
    /// Returns a target buffer `offset` to start playback if it has been specified, else `nil`.
    public var startPosition: Int64? {
        switch startOffset {
        case .startPosition(position: let value): return value
        default: return nil
        }
    }
    
    /// Returns a target timestamp in wallclock unix epoch time to start playback if it has been specified, else `nil`.
    public var startTime: Int64? {
        switch startOffset {
        case .startTime(time: let value): return value
        default: return nil
        }
    }
    
    /// Should set the `startPosition`  (in milliseconds) to the specified `position` relative to the playback buffer.
    ///
    /// Specifying `nil` revert to the default behaviour for startup
    public func startOffset(atPosition position: Int64?) {
        startOffset = position != nil ? .startPosition(position: position!) : .defaultStartTime
    }
    
    /// Should set the `startTime` to the specified `timestamp` in wallclock unix epoch time. (in milliseconds)
    ///
    /// Specifying `nil` revert to the default behaviour for startup
    public func startOffset(atTime timestamp: Int64?) {
        startOffset = timestamp != nil ? .startTime(time: timestamp!) : .defaultStartTime
    }
}
