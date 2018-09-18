//
//  AVPlayerItem+Extensions.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import AVFoundation

/// Defines typed *Key Value Observable* paths for `AVPlayerItem`.
extension AVPlayerItem: KeyValueObservable {
    typealias ObservableKeys = ObservableKey
    
    // MARK: ObservableKeys
    enum ObservableKey: String {
        /// `avPlayerItem.status`
        case status = "status"
        
        /// `avPlayerItem.tracks`
        case tracks = "tracks"
        
        /// `avPlayerItem.duration`
        case duration = "duration"
        
        /// `avPlayerItem.presentationSize`
        case presentationSize = "presentationSize"
        
        /// `avPlayerItem.timedMetadata`
        case timedMetadata = "timedMetadata"
        
        /// `avPlayerItem.playbackLikelyToKeepUp`
        case isPlaybackLikelyToKeepUp = "playbackLikelyToKeepUp"
        
        /// `avPlayerItem.playbackBufferFull`
        case isPlaybackBufferFull = "playbackBufferFull"
        
        /// `avPlayerItem.playbackBufferEmpty`
        case isPlaybackBufferEmpty = "playbackBufferEmpty"
        
        case seekableTimeRanges = "seekableTimeRanges"
        
        case loadedTimeRanges = "loadedTimeRanges"
    }
}

internal extension AVPlayerItem {
    // Convenience property returning the `AVMediaCharacteristic.audible`
    internal var audioGroup: MediaGroup? {
        guard let group = asset.mediaSelectionGroup(forMediaCharacteristic: .audible) else { return nil }
        return MediaGroup(mediaGroup: group, selectedMedia: selectedMediaOption(in: group))
    }
    
    // Convenience property returning the `AVMediaCharacteristic.legible`
    internal var textGroup: MediaGroup? {
        guard let group = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return nil }
        return MediaGroup(mediaGroup: group, selectedMedia: selectedMediaOption(in: group))
    }
}

// MARK: - TraceProvider Data
internal extension AVPlayerItem {
    /// Gathers TraceProvider data into json format
    internal var traceProviderStatusData: [String: Any] {
        var json: [String: Any] = [
            "Message": "PLAYER_ITEM_STATUS_TRACE_ENTRY",
            ]
        
        var info: String = ""
        info += "PlaybackLikelyToKeepUp: \(isPlaybackLikelyToKeepUp) \n"
        info += "PlaybackBufferFull: \(isPlaybackBufferFull) \n"
        info += "PlaybackBufferEmpty: \(isPlaybackBufferEmpty) \n"
        if let urlAsset = asset as? AVURLAsset {
            info += "URL: \(urlAsset.url) \n"
        }
        
        switch status {
        case .failed:
            info += "PlayerItem.Status: .failed \n"
            info += "PlayerItem.Error: " + (error?.debugInfoString ?? "nil") + " \n"
        case .readyToPlay:
            info += "PlayerItem.Status: .readyToPlay \n"
        case .unknown:
            info += "PlayerItem.Status: .unknown \n"
        }
        
        json["Info"] = info
        
        return json
    }
}

