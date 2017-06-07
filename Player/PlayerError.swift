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
        case missingApplicationCertificateUrl
        case applicationCertificateResponse(error: Error)
        case invalidCertificateData
        case invalidContentIdentifier
        case serverPlaybackContext(error: Error)
        case missingContentKeyContextUrl
        case contentKeyContext(error: Error)
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
        case .missingApplicationCertificateUrl: return "Application Certificate Url not found"
        case .applicationCertificateResponse(error: let error): return "Application Certificate Response: \(error.localizedDescription)"
        case .invalidCertificateData: return "Certificate Data invalid"
        case .invalidContentIdentifier: return "Invalid Content Identifier"
        case .serverPlaybackContext(error: let error): return "Server Playback Context: \(error.localizedDescription)"
        case .missingContentKeyContextUrl: return "Content Key Context Url not found"
        case .contentKeyContext(error: let error): return "Content Key Context: \(error.localizedDescription)"
        case .missingContentKeyContext: return "Content Key Context missing from response"
        case .missingDataRequest: return "Data Request missing"
        }
    }
}
