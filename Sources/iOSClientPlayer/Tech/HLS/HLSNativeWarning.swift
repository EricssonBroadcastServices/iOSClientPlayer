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
    
    /// Another media source was loaded before the currently loading source finalized preparation
    case mediaPreparationAbandoned(playSessionId: String, url: URL)
    
    /// Content Key Validation failed with the specified error, or `nil` if the underlyig error is expected.
    case coreMediaErrorDomain(error: Error?)
    
}

extension HLSNativeWarning {
    public var message: String {
        switch self {
        case .seekableRangesEmpty: return "Seekable ranges was empty"
        case .discontinuousSeekableRanges(seekableRanges: let ranges): return "Seekable ranges contain discontinuity \(ranges)"
        case .seekTimeBeyondLivePoint(timestamp: let timestamp, livePoint: let live): return "Requested seek time \(timestamp) was beyond live point \(live)"
        case .invalidStartTime(startTime: let time, seekableRanges: let ranges): return "Invalid start time, \(time) set beyond seekable ranges, \(ranges)"
        case .mediaPreparationAbandoned(playSessionId: let sessionId, url: let url): return "Preparation of media source with playsessionId: \(sessionId) was abandoned before finalizing. Url: \(url)"
        case .coreMediaErrorDomain(error: let error): if let error = error as? HLSAVPlayerItemErrorLogEventError { return "PLAYER_ITEM_ERROR_LOG_ENTRY : CoreMediaErrorDomain : \n info: \(error.info) \n message : \(error.message) \n code: \(error.code) \n Error : \(error)"  } else { return "PLAYER_ITEM_ERROR_LOG_ENTRY : CoreMediaErrorDomain" }
        }
    }
}
