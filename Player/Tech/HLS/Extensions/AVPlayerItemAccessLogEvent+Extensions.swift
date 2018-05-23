//
//  AVPlayerItemAccessLogEvent+Extensions.swift
//  Player-iOS
//
//  Created by Fredrik Sjöberg on 2018-05-23.
//  Copyright © 2018 emp. All rights reserved.
//

import AVFoundation

// MARK: - TraceProvider Data
internal extension AVPlayerItemAccessLogEvent {
    /// Gathers TraceProvider data into json format
    internal var traceProviderData: [String: Any] {
        var json: [String: Any] = [
            "Message": "PLAYER_ITEM_ACCESS_LOG_ENTRY",
            ]
        
        var info: String = ""
        if let value = uri {
            info += "URI: \(value)\n"
        }
        
        if let value = serverAddress {
            info += "ServerAddress: \(value)\n"
        }
        
        if let value = playbackType {
            info += "PlaybackType: \(value)\n"
        }
        
        json["Info"] = info
        return json
    }
}
