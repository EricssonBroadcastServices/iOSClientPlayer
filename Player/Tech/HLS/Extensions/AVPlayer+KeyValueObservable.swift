//
//  AVPlayer+KeyValueObservable.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

/// Defines typed *Key Value Observable* paths for `AVPlayer`.
extension AVPlayer: KeyValueObservable {
    typealias ObservableKeys = ObservableKey
    
    // MARK: ObservableKeys
    enum ObservableKey: String {
        /// `avPlayer.status`
        case status = "status"
        
        /// `avPlayer.rate`
        case rate = "rate"
        
        /// `avPlayer.timeControlStatus`
        case timeControlStatus = "timeControlStatus"
        
        /// `avPlayer.reasonForWaitingToPlay`
        case reasonForWaitingToPlay = "reasonForWaitingToPlay"
        
        /// `avPlayer.currentItem`
        case currentItem = "currentItem"
        
        /// `avPlayer.currentItemTimedMetadata`
        case currentItemTimedMetadata = "currentItem.timedMetadata"
        
        /// Returns all *Observable Keys*.
        var all: [ObservableKey] {
            return [.status, .rate, .timeControlStatus, .reasonForWaitingToPlay, .currentItem]
        }
    }
}
