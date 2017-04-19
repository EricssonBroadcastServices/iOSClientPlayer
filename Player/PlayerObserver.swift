//
//  PlayerObserver.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

extension Player {
    class PlayerObserver: NotificationObserver, KeyValueObserver {
        typealias Object = AVPlayer
        
        var observers: [Observer<AVPlayer>] = []
        var tokens: [NotificationToken] = []
    }
    
    class PlayerItemObserver: NotificationObserver, KeyValueObserver {
        typealias Object = AVPlayerItem
        
        var observers: [Observer<AVPlayerItem>] = []
        var tokens: [NotificationToken] = []
    }
}
