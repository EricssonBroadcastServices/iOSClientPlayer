//
//  HLSNativeError.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// `HLSNativeError` is the error type specific to the `HLSNative` `Tech`. It can manifest as both *native errors* to the framework and *nested errors* specific to underlying frameworks.
/// Effective error handling thus requires a deeper undestanding of the overall architecture.
public enum HLSNativeError: Error {
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
}

extension HLSNativeError {
    public var localizedDescription: String {
        switch self {
        case .missingMediaUrl: return "Missing media url"
        case .failedToPrepare(errors: let errors): return "Media failed to prepare: \(errors)"
        case .loadedButNotPlayable: return "Asset loaded but not playable"
        case .failedToReady(error: let error): return "Asset failed to ready: \(String(describing: error?.localizedDescription))"
        }
    }
}

extension HLSNativeError {
    /// Defines the `domain` specific code for the underlying error.
    public var code: Int {
        switch self {
        case .missingMediaUrl: return 101
        case .failedToPrepare(errors: _): return 102
        case .failedToReady(error: _): return 103
        case .loadedButNotPlayable: return 104
        }
    }
}
