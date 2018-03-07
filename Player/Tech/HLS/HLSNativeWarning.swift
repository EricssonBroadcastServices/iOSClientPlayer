//
//  HLSNativeWarning.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-01-30.
//  Copyright © 2018 emp. All rights reserved.
//

import AVFoundation


public enum HLSNativeWarning: WarningMessage {
    /// Seekable ranges was empty
    case seekableRangesEmpty
    
    /// Seekable ranges contained a discontinuity
    case discontinuousSeekableRanges(seekableRanges: [CMTimeRange])
    
    /// The requested seek time was beyond the live point
    case seekTimeBeyondLivePoint(timestamp: Int64, livePoint: Int64)
    
    /// The supplied startTime was invalid for the seekable ranges.
    case invalidStartTime(startTime: Int64, seekableRanges: [CMTimeRange])
}

extension HLSNativeWarning {
    public var message: String {
        switch self {
        case .seekableRangesEmpty: return "Seekable ranges was empty"
        case .discontinuousSeekableRanges(seekableRanges: let ranges): return "Seekable ranges contain discontinuity \(ranges)"
        case .seekTimeBeyondLivePoint(timestamp: let timestamp, livePoint: let live): return "Requested seek time \(timestamp) was beyond live point \(live)"
            
        case .invalidStartTime(startTime: let time, seekableRanges: let ranges): return "Invalid start time, \(time) set beyond seekable ranges, \(ranges)"
        }
    }
}
