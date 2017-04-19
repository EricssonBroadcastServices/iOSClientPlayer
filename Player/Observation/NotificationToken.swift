//
//  NotificationToken.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

struct NotificationToken {
    let notification: Notification.Name
    let token: NSObjectProtocol
    let object: Any?
}
