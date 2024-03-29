//
//  HLSNativeError.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import MapKit


/// HLSAVPlayerItemErrorLogEvent : Extended Tech Error for `AVPlayerItemErrorLogEvent` errors
public struct HLSAVPlayerItemErrorLogEventError: ExpandedError {
    public var code: Int
    public var message: String
    public var domain: String
    public var info: String?
    public init(code: Int, message: String, domain: String, info: String?) {
        self.code = code
        self.message = message
        self.domain = domain
        self.info = info
    }
}

/// `HLSNativeError` is the error type specific to the `HLSNative` `Tech`. It can manifest as both *native errors* to the framework and *nested errors* specific to underlying frameworks.
/// Effective error handling thus requires a deeper undestanding of the overall architecture.
public enum HLSNativeError: ExpandedError {
    /// Media is missing a valid `URL` to load data from.
    case missingMediaUrl
    
    /// `Player` failed to prepare the media for playback.
    ///
    /// This occurs when trying to asynchronously load values (eg `properties`) on `AVURLAsset` in preparation for playback. Examples include:
    /// * `duration`
    /// * `tracks`
    /// * `playable`
    ///
    /// Internally, `Player` calls `loadValuesAsynchronously(forKeys:)` and then checks the status of each *key* through `statusOfValue(forKey: error:)`. Any key-value pair which returns a `.failed` status will cause the preparation to fail, forwarding the assocaited error.
    ///
    /// For more information regarding the *async loading process* of `properties` on `AVAsset`s, please consult Apple's documentation regarding `AVAsynchronousKeyValueLoading`
    case failedToPrepare(errors: [Error])
    
    /// The *asynchronous loading* of `AVURLAsset` `properties` succeded but somehow `isPlayable` returned `false`.
    case loadedButNotPlayable
    
    /// Media could not ready for playback with the underlying `AVPlayerItem` status changed to `.failed`.
    case failedToReady(error: Error?)
    
    /// Meida could not complete playback.
    case failedToCompletePlayback(error: Error)
    
    /// Content Key Validation failed with the specified error, or `nil` if the underlyig error is expected.
    case failedToValdiateContentKey(error: Error?)
    
    /// Media preparation finished after `Tech` was torn down
    @available(*, deprecated: 2.0.85, message: "Deallocation of HLSNative during the media preparation phase is no longer considered an `Error`.")
    case techDeallocated
}

extension HLSNativeError {
    
    public var message: String {
        switch self {
        case .missingMediaUrl: return "MISSING_MEDIA_URL"
        case .failedToPrepare(errors: _): return "FAILED_TO_PREPARE"
        case .loadedButNotPlayable: return "LOADED_BUT_NOT_PLAYABLE"
        case .failedToReady(error: _): return "FAILED_TO_READY"
        case .failedToCompletePlayback(error: _): return "FAILED_TO_COMPLETE_PLAYBACK"
        case .failedToValdiateContentKey(error: _): return "FAILED_TO_VALIDATE_CONTENT_KEY"
        case .techDeallocated: return "TECH_DEALLOCATED"
        }
    }
    
    /// Returns detailed information about the error
    public var info: String? {
        switch self {
        case .missingMediaUrl: return "Missing media url"
        case .failedToPrepare(errors: let errors): return errors.map{ "\($0.debugInfoString)" }.joined(separator: "\n")
        case .loadedButNotPlayable: return "Asset loaded but not playable"
        case .failedToReady(error: let error): return error != nil ? error!.debugInfoString : "Unknown error"
        case .failedToCompletePlayback(error: let error): return error.debugInfoString
        case .failedToValdiateContentKey(error: let error): return error != nil ? error!.debugInfoString : "Unknown error"
        case .techDeallocated: return "Media preparation finished after Tech was deallocated"
        }
    }
}

extension HLSNativeError {
    /// Defines the specific code for the underlying error.
    public var code: Int {
        switch self {
        case .missingMediaUrl: return 101
        case .failedToPrepare(errors: _): return 102
        case .failedToReady(error: _): return 103
        case .loadedButNotPlayable: return 104
        case .failedToCompletePlayback(error: _): return 105
        case .failedToValdiateContentKey(error: _): return 106
        case .techDeallocated: return 107
        }
    }
}

extension HLSNativeError {
    public var domain: String { return String(describing: type(of: self))+"Domain" }
}

extension HLSNativeError {
    public var underlyingError: Error? {
        switch self {
        case .missingMediaUrl: return nil
        case .failedToPrepare(errors: let errors): return errors.first
        case .failedToReady(error: let error): return error
        case .loadedButNotPlayable: return nil
        case .failedToCompletePlayback(error: let error): return error
        case .failedToValdiateContentKey(error: let error): return error
        case .techDeallocated: return nil
        }
    }
}
