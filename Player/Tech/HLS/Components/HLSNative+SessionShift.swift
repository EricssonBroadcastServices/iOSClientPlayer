//
//  HLSNative+SessionShift.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

extension HLSNative: SessionShift {
    /// Internal state for tracking Bookmarks.
    internal enum Bookmark {
        /// Bookmarking is not enabled
        case notEnabled
        
        /// Bookmarking is enabled. Optionaly, with a specified `offset`. No offset suggests that offset will be supplied at a later time.
        case enabled(offset: Int64?)
    }
    
    /// Is *Session Shift* enabled or not.
    ///
    /// SessionShift may be enabled without a specific `offset` defined.
    public var sessionShiftEnabled: Bool {
        switch bookmark {
        case .notEnabled: return false
        case .enabled(offset: _): return true
        }
    }
    
    /// Returns a *Session Shift* `offset` if one has been specified, else `nil`.
    ///
    /// No specified `offset` does not necessary mean *Session Shift* is disabled.
    public var sessionShiftOffset: Int64? {
        switch bookmark {
        case .notEnabled: return nil
        case .enabled(offset: let offset): return offset
        }
    }
    
    /// By specifying `true` you are signaling `sessionShift` is enabled and a starting `offset` will be supplied at *some time*, when is undefined.
    ///
    /// This is useful when you rely on some external party to supply the `player` with an `offset` at some point in its lifecycle.
    ///
    /// - parameter enabled: `true` if enabled, `false` otherwise
    /// - returns: `Self`
    public func sessionShift(enabled: Bool) {
        bookmark = enabled ? .enabled(offset: nil) : .notEnabled
    }
    
    /// Configure the `player` to start playback at the specified `offset`.
    ///
    /// - parameter offset: Offset into the media, in *milliseconds*.
    public func sessionShift(enabledAt offset: Int64) {
        bookmark = .enabled(offset: offset)
    }

}
