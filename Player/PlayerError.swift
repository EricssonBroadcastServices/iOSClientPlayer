//
//  PlayerError.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// `PlayerError` is the error type returned by the *Player Framework*. It can manifest as both *native errors* to the framework and *nested errors* specific to underlying frameworks.
/// Effective error handling thus requires a deeper undestanding of the overall architecture.
///
/// - important: Nested errors have *error codes* specific to the related *domain*. A domain is defined as the `representing type` *(for example* `AssetError`*)* and may contain subtypes. This means different errors may share error codes. When this occurs, it is important to keep track of the underlying domain.
public enum PlayerError: Error {
    case generalError(error: Error)
    case asset(reason: AssetError)
    
    /// Errors related to preparing the media.
    public enum AssetError {
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
}

extension PlayerError {
    public var localizedDescription: String {
        switch self {
        case .generalError(error: let error): return "General Error: " + error.localizedDescription
        case .asset(reason: let reason): return "Asset: " + reason.localizedDescription
        }
    }
}

extension PlayerError.AssetError {
    public var localizedDescription: String {
        switch self {
        case .missingMediaUrl: return "Missing media url"
        case .failedToPrepare(errors: let errors): return "Media failed to prepare: \(errors)"
        case .loadedButNotPlayable: return "Asset loaded but not playable"
        case .failedToReady(error: let error): return "Asset failed to ready: \(String(describing: error?.localizedDescription))"
        }
    }
}

extension PlayerError {
    /// Defines the `domain` specific code for the underlying error.
    public var code: Int {
        switch self {
        case .asset(reason: let reason): return reason.code
        case .generalError(error: _): return 101
        }
    }
}

extension PlayerError.AssetError {
    /// Defines the `domain` specific code for the underlying error.
    public var code: Int {
        switch self {
        case .missingMediaUrl: return 201
        case .failedToPrepare(errors: _): return 202
        case .failedToReady(error: _): return 203
        case .loadedButNotPlayable: return 204
        }
    }
}
