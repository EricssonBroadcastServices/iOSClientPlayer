//
//  AVPlayerItem+KeyValueObservable.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayerItem: KeyValueObservable {
    typealias ObservableKeys = ObservableKey
    
    // MARK: ObservableKeys
    enum ObservableKey: String {
        case status = "status"
        case tracks = "tracks"
        case duration = "duration"
        case presentationSize = "presentationSize"
        case timedMetadata = "timedMetadata"
        case isPlaybackLikelyToKeepUp = "playbackLikelyToKeepUp"
        case isPlaybackBufferFull = "playbackBufferFull"
        case isPlaybackBufferEmpty = "playbackBufferEmpty"
        
        var all: [ObservableKey] {
            return [.status, .tracks, .duration, .presentationSize, .timedMetadata, .isPlaybackLikelyToKeepUp, .isPlaybackBufferFull, .isPlaybackBufferEmpty]
        }
    }
}
