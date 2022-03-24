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
        
        if numberOfStalls > 0 {
            info += "PlaybackStalls: \(numberOfStalls)\n"
        }
        
        if numberOfBytesTransferred >= 0 {
            info += "BytesTransferred: \(numberOfBytesTransferred)\n"
        }
        
        if numberOfDroppedVideoFrames > 0 {
            info += "DroppedVideoFrames: \(numberOfDroppedVideoFrames)\n"
        }
        
        if downloadOverdue > 0 {
            info += "SegmentDownloadsOverdue: \(downloadOverdue)\n"
        }
        
        let downloadedDuration = Int64(segmentsDownloadedDuration)
        if downloadedDuration >= 0 {
            info += "DurationOfDownloadedSegments: \(downloadedDuration)\n"
        }
        
        let watched = Int64(durationWatched)
        if durationWatched >= 0 {
            info += "DurationWatched: \(watched)\n"
        }
        
        let startTime = Int64(startupTime)
        if startTime > 0 {
            info += "StartupTime: \(startTime)\n"
        }
        
        
        json["Info"] = info
        return json
    }
}
