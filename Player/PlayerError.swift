//
//  PlayerError.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

extension Player {
    public enum PlayerError: Error {
        case asset(reason: AssetError)
        
        public enum AssetError {
            case failedToPrepare(errors: [Error])
            case loadedButNotPlayable
            case failedToReady(error: Error?)
        }
    }
}
