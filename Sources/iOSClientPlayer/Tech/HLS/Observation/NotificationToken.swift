//
//  NotificationToken.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// `NotificationToken`s represent the *observable* used to track a registered notification subscriber
struct NotificationToken {
    /// The `Notification` subscribed to.
    let notification: Notification.Name
    
    /// Token acting as the *observable*
    let token: NSObjectProtocol
    
    /// The object whose notifications the observer wants to receive; that is, only notifications sent by this sender are delivered to the observer.
    let object: Any?
}
