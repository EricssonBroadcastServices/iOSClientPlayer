//
//  AVPlayerItemErrorLogEvent+Extensions.swift
//  Player-iOS
//
//  Created by Fredrik Sjöberg on 2018-05-23.
//  Copyright © 2018 emp. All rights reserved.
//

import AVFoundation

// MARK: - TraceProvider Data
internal extension AVPlayerItemErrorLogEvent {
    /// Gathers TraceProvider data into json format
    internal var traceProviderData: [String: Any] {
        var json: [String: Any] = [
            "Message": "PLAYER_ITEM_ERROR_LOG_ENTRY",
            "Domain": errorDomain,
            "Code": errorStatusCode
        ]
        
        var info: String = ""
        if let comment = errorComment {
            info += "ErrorComment: \(comment) \n"
        }
        
        if let serverAddress = serverAddress {
            info += "ServerAddress: \(serverAddress) \n"
        }
        
        if let uri = uri {
            info += "URI: \(uri) \n"
        }
        
        json["Info"] = info
        return json
    }
}
