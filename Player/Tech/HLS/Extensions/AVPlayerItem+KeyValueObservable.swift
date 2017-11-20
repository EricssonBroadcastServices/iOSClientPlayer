//
//  AVPlayerItem+KeyValueObservable.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
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
        
        
        /// Returns all *Observable Keys*.
        var all: [ObservableKey] {
            return [.status, .tracks, .duration, .presentationSize, .timedMetadata, .isPlaybackLikelyToKeepUp, .isPlaybackBufferFull, .isPlaybackBufferEmpty]
        }
    }
}
