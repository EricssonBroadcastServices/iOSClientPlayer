//
//  Int64+Extensions.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-10-16.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

extension Int64 {
    /// If `self` is a buffer positon, transform it to a wallclock timestamp in relation to `time` and `position`
    public func timestampFrom(referenceTime time: Int64, referencePosition position: Int64) -> Int64 {
        return time - position + self
    }
    
    /// If `self` is a wallclock timestamp, transform it to a buffer positon in relation to `time` and `position`
    public func positionFrom(referenceTime time: Int64, referencePosition position: Int64) -> Int64 {
        return position - time + self
    }
    
    /// If `self` is a buffer positon, transform it to a wallclock timestamp in relation to `time` and `position`
    ///
    /// Will return nil if `time` is nil
    public func timestampFrom(referenceTime time: Int64?, referencePosition position: Int64) -> Int64? {
        guard let time = time else { return nil }
        return time - position + self
    }
    
    /// If `self` is a wallclock timestamp, transform it to a buffer positon in relation to `time` and `position`
    ///
    /// Will return nil if `time` is nil
    public func positionFrom(referenceTime time: Int64?, referencePosition position: Int64) -> Int64? {
        guard let time = time else { return nil }
        return position - time + self
    }
    
}
