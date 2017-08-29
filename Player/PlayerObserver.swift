//
//  PlayerObserver.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

/// Internal class wrapping `KVO` and `Notifications` related to `AVPlayer`
internal class PlayerObserver: NotificationObserver, KeyValueObserver {
    internal typealias Object = AVPlayer
    
    internal var observers: [Observer<AVPlayer>] = []
    internal var tokens: [NotificationToken] = []
}

/// Internal class wrapping `KVO` and `Notifications` related to `AVPlayerItem`
internal class PlayerItemObserver: NotificationObserver, KeyValueObserver {
    internal typealias Object = AVPlayerItem
    
    internal var observers: [Observer<AVPlayerItem>] = []
    internal var tokens: [NotificationToken] = []
}
