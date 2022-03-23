//
//  PlayerObserver.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
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
