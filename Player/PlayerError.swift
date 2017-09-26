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
    case fairplay(reason: FairplayError)
    
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
    
    /// Errors associated with *Fairplay* can be categorized, broadly, into two types:
    /// * Fairplay server related *DRM* errors.
    /// * Application related.
    ///
    /// Server related issues most likely stem from an invalid or broken backend configuration. Application issues range from parsing errors, unexpected server response or networking issues.
    public enum FairplayError {
        // MARK: Application Certificate
        /// Networking issues caused the application to fail while verifying the *Fairplay* DRM.
        case networking(error: Error)
        
        /// No `URL` available to fetch the *Application Certificate*. This is a configuration issue.
        case missingApplicationCertificateUrl
        
        /// The *Application Certificate* response contained an unexpected or invalid data format.
        ///
        /// `FairplayRequester` failed to decode the raw data, most likely due to a missmatch between expected and supplied data format.
        case applicationCertificateDataFormatInvalid
        
        /// *Certificate Server* responded with an error message.
        /// 
        /// Details are expressed by `code` and `message`
        case applicationCertificateServer(code: Int, message: String)
        
        /// There was an error while parsing the *Application Certificate*. This is considered a general error
        case applicationCertificateParsing
        
        /// `AVAssetResourceLoadingRequest` failed to prepare the *Fairplay* related content identifier. This should normaly be encoded in the resouce loader's `urlRequest.url.host`.
        case invalidContentIdentifier
        
        // MARK: Server Playback Context
        /// An `error` occured while the `AVAssetResourceLoadingRequest` was trying to obtain the *Server Playback Context*, `SPC`, key request data for a specific combination of application and content.
        ///
        /// ```swift
        /// do {
        ///     try resourceLoadingRequest.streamingContentKeyRequestData(forApp: certificate, contentIdentifier: contentIdentifier, options: resourceLoadingRequestOptions)
        /// }
        /// catch {
        ///     // serverPlaybackContext error
        /// }
        /// ```
        ///
        /// For more information, please consult Apple's documentation.
        case serverPlaybackContext(error: Error)
        
        // MARK: Content Key Context
        /// `FairplayRequester` could not fetch a *Content Key Context*, `CKC`, since the *license acquisition url* was missing.
        case missingContentKeyContextUrl
        
        /// `CKC`, *content key context*, request data could not be generated because the identifying `playToken` was missing.
        case missingPlaytoken
        
        /// The *Content Key Context* response data contained an unexpected or invalid data format.
        ///
        /// `FairplayRequester` failed to decode the raw data, most likely due to a missmatch between expected and supplied data format.
        case contentKeyContextDataFormatInvalid
        
        /// *Content Key Context* server responded with an error message.
        ///
        /// Details are expressed by `code` and `message`
        case contentKeyContextServer(code: Int, message: String)
        
        /// There was an error while parsing the *Content Key Context*. This is considered a general error
        case contentKeyContextParsing
        
        /// *Content Key Context* server did not respond with an error not a valid `CKC`. This is considered a general error
        case missingContentKeyContext
        
        /// `FairplayRequester` could not complete the resource loading request because its associated `AVAssetResourceLoadingDataRequest` was `nil`. This indicates no data was being requested.
        case missingDataRequest
    }
}

extension PlayerError {
    public var localizedDescription: String {
        switch self {
        case .generalError(error: let error): return "General Error: " + error.localizedDescription
        case .asset(reason: let reason): return "Asset: " + reason.localizedDescription
        case .fairplay(reason: let reason): return "Fairplay: " + reason.localizedDescription
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

extension PlayerError.FairplayError {
    public var localizedDescription: String {
        switch self {
        // Application Certificate
        case .missingApplicationCertificateUrl: return "Application Certificate Url not found"
        case .networking(error: let error): return "Network error while fetching Application Certificate: \(error.localizedDescription)"
        case .applicationCertificateDataFormatInvalid: return "Certificate Data was not encodable using base64"
        case .applicationCertificateServer(code: let code, message: let message): return "Application Certificate server returned error: \(code) with message: \(message)"
        case .applicationCertificateParsing: return "Application Certificate server response lacks parsable data"
        case .invalidContentIdentifier: return "Invalid Content Identifier"
        
        // Server Playback Context
        case .serverPlaybackContext(error: let error): return "Server Playback Context: \(error.localizedDescription)"
            
        // Content Key Context
        case .missingContentKeyContextUrl: return "Content Key Context Url not found"
        case .missingPlaytoken: return "Content Key Context call requires a playtoken"
        case .contentKeyContextDataFormatInvalid: return "Content Key Context was not encodable using base64"
        case .contentKeyContextServer(code: let code, message: let message): return "Content Key Context server returned error: \(code) with message: \(message)"
        case .contentKeyContextParsing: return "Content Key Context server response lacks parsable data"
        case .missingContentKeyContext: return "Content Key Context missing from response"
        case .missingDataRequest: return "Data Request missing"
        }
    }
}

extension PlayerError {
    /// Defines the `domain` specific code for the underlying error.
    public var code: Int {
        switch self {
        case .asset(reason: let reason): return reason.code
        case .fairplay(reason: let reason): return reason.code
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

extension PlayerError.FairplayError {
    /// Defines the `domain` specific code for the underlying error.
    public var code: Int {
        switch self {
        case .applicationCertificateDataFormatInvalid: return 301
        case .applicationCertificateParsing: return 302
        case .applicationCertificateServer(code: _, message: _): return 303
        case .contentKeyContextDataFormatInvalid: return 304
        case .contentKeyContextParsing: return 305
        case .contentKeyContextServer(code: _, message: _): return 306
        case .invalidContentIdentifier: return 307
        case .missingApplicationCertificateUrl: return 308
        case .missingContentKeyContext: return 309
        case .missingContentKeyContextUrl: return 310
        case .missingDataRequest: return 311
        case .missingPlaytoken: return 312
        case .networking(error: _): return 313
        case .serverPlaybackContext(error: _): return 314
        }
    }
}
