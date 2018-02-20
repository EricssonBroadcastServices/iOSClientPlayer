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
        
        /// Returns all *Observable Keys*.
        var all: [ObservableKey] {
            return [.status, .tracks, .duration, .presentationSize, .timedMetadata, .isPlaybackLikelyToKeepUp, .isPlaybackBufferFull, .isPlaybackBufferEmpty, .seekableTimeRanges, .loadedTimeRanges]
        }
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
