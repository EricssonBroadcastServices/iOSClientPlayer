//
//  AVPlayer+KeyValueObservable.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayer: KeyValueObservable {
    typealias ObservableKeys = ObservableKey
    
    // MARK: ObservableKeys
    enum ObservableKey: String {
        case status = "status"
        case rate = "rate"
        case timeControlStatus = "timeControlStatus"
        case reasonForWaitingToPlay = "reasonForWaitingToPlay"
        case currentItem = "currentItem"
        case currentItemTimedMetadata = "currentItem.timedMetadata"
        //case isOutputObscuredDueToInsufficientExternalProtection = "isOutputObscuredDueToInsufficientExternalProtection"
        
        var all: [ObservableKey] {
            return [.status, .rate, .timeControlStatus, .reasonForWaitingToPlay, .currentItem]
        }
    }
}
