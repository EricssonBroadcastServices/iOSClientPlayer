//
//  ItemObserver.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

/// Internal class wrapping `KVO` and `Notifications` related to `AVPlayerItem`
internal class PlayerItemObserver: NotificationObserver, KeyValueObserver {
    internal typealias Object = AVPlayerItem
    
    internal var observers: [Observer<AVPlayerItem>] = []
    internal var tokens: [NotificationToken] = []
}
