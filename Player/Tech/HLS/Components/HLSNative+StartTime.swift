//
//  HLSNative+StartTime.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Tracking Bookmarks.
public enum StartOffset {
    /// Default behaviour applies
    case defaultStartTime
    
    /// Playback should start from the specified `offset` into the buffer (milliseconds)
    case startPosition(position: Int64)
    
    /// Playback should start from the specified `wallclock timestamp` in unix epoch time (milliseconds)
    case startTime(time: Int64)
}

/// `HLSNative` optionally support setting a `StartTimeDelegate` to handle start time.
///
/// Classes conforming to `StartTimeDelegate` are expected to provide a valid start time during the initialization process of a new `MediaSource`
public protocol StartTimeDelegate: class {
    /// During the initialization process, `HLSNative` will ask its delegate for a `StartOffset`.
    ///
    /// Protocol adopters can use this method to for example implement a bookmarking service
    ///
    /// - parameter source: The `MediaSource` for which this start time request concerns.
    /// - parameter tech: Tech which will apply the start time.
    /// - returns: a valid `StartOffset`
    func startTime<Context>(for source: MediaSource, tech: HLSNative<Context>) -> StartOffset
}

/// `HLSNative` adoption of `StartTime`
extension HLSNative: StartTime {
    /// Returns a target buffer `offset` (in milliseconds) to start playback if it has been specified, else `nil`.
    ///
    /// If a `StartTimeDelegate` has been specified, it will take precedence over deciding the start time
    public var startPosition: Int64? {
        if let delegate = startTimeConfiguration.startTimeDelegate, let source = currentSource {
            let value = delegate.startTime(for: source, tech: self)
            switch value {
            case let .startPosition(position: result): return result
            default: return nil
            }
        }
        else {
            switch startTimeConfiguration.startOffset {
            case .startPosition(position: let value): return value
            default: return nil
            }
        }
    }
    
    /// Returns a target timestamp in wallclock unix epoch time (in milliseconds) to start playback if it has been specified, else `nil`.
    ///
    /// If a `StartTimeDelegate` has been specified, it will take precedence over deciding the start time
    public var startTime: Int64? {
        if let delegate = startTimeConfiguration.startTimeDelegate, let source = currentSource {
            let value = delegate.startTime(for: source, tech: self)
            switch value {
            case let .startTime(time: result): return result
            default: return nil
            }
        }
        else {
            switch startTimeConfiguration.startOffset {
            case .startTime(time: let value): return value
            default: return nil
            }
        }
    }
    
    /// Sets the `startPosition` (in milliseconds) to the specified `position` relative to the playback buffer.
    ///
    /// Specifying `nil` reverts to the default behaviour for startup but will not remove any `StartTimeDelegate` set.
    public func startTime(atPosition position: Int64?) {
        startTimeConfiguration.startOffset = position != nil ? .startPosition(position: position!) : .defaultStartTime
    }
    
    /// Sets the `startTime` to the specified `timestamp` in wallclock unix epoch time. (in milliseconds)
    ///
    /// Specifying `nil` reverts to the default behaviour for startup but will not remove any `StartTimeDelegate` set.
    public func startTime(atTime timestamp: Int64?) {
        startTimeConfiguration.startOffset = timestamp != nil ? .startTime(time: timestamp!) : .defaultStartTime
    }
}

extension HLSNative {
    /// Specifies `startTime` will be handled by a delegate responsible for supplying the correct `StartOffset`.
    ///
    /// This will take precedence over any static `startOffset` behavior set. Specifying `nil` will remove the current delegate
    public func startTime(byDelegate delegate: StartTimeDelegate?) {
        startTimeConfiguration.startTimeDelegate = delegate
    }
    
    internal func startOffset(for mediaSource: MediaAsset<Context.Source>) -> StartOffset {
        if let delegateOffset = startTimeConfiguration.startTimeDelegate?.startTime(for: mediaSource.source, tech: self) {
            return delegateOffset
        }
        return startTimeConfiguration.startOffset
    }
}
