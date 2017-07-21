//
//  PlayerError.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public enum PlayerError: Error {
    case generalError(error: Error)
    case asset(reason: AssetError)
    case fairplay(reason: FairplayError)
    
    public enum AssetError {
        case missingMediaUrl
        case failedToLoadValues(error: Error)
        case failedToPrepare(errors: [Error])
        case loadedButNotPlayable
        case failedToReady(error: Error?)
    }
    
    public enum FairplayError {
        // Application Certificate
        case networking(error: Error)
        case missingApplicationCertificateUrl
        case applicationCertificateDataFormatInvalid
        case applicationCertificateServer(code: Int, message: String)
        case applicationCertificateParsing
        case invalidContentIdentifier
        
        // Server Playback Context
        case serverPlaybackContext(error: Error)
        
        // Content Key Context
        case missingContentKeyContextUrl
        case missingPlaytoken
        case contentKeyContextDataFormatInvalid
        case contentKeyContextServer(code: Int, message: String)
        case contentKeyContextParsing
        case missingContentKeyContext
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
        case .failedToLoadValues(error: let error): return "Failed to load values: \(error.localizedDescription)"
        case .failedToPrepare(errors: let errors): return "Failed to prepare: \(errors)"
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
    public var code: Int {
        switch self {
        case .asset(reason: let reason): return reason.code
        case .fairplay(reason: let reason): return reason.code
        case .generalError(error: _): return 101
        }
    }
}

extension PlayerError.AssetError {
    public var code: Int {
        switch self {
        case .failedToLoadValues(error: _): return 201
        case .failedToPrepare(errors: _): return 202
        case .failedToReady(error: _): return 203
        case .loadedButNotPlayable: return 204
        case .missingMediaUrl: return 205
        }
    }
}

extension PlayerError.FairplayError {
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
