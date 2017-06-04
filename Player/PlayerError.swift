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
        case failedToPrepare(errors: [Error])
        case loadedButNotPlayable
        case failedToReady(error: Error?)
    }
    
    public enum FairplayError {
        case missingApplicationCertificateUrl
        case invalidApplicationCertificateUrl(error: Error)
        case invalidContentIdentifier
        case serverPlaybackContext(error: Error)
        case missingContentKeyContextUrl
        case contentKeyContext(error: Error)
        case missingContentKeyContext
        case missingDataRequest
    }
}
