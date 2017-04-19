//
//  NotificationObserver.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

protocol NotificationObserver {
    associatedtype Object: NSObject
    var tokens: [NotificationToken] { get set }
}

extension NotificationObserver {
    mutating func subscribe(notification name: NSNotification.Name, for object: Object? = nil, queue: OperationQueue? = OperationQueue.main, callback: @escaping (Notification) -> Void) {
        let token = NotificationCenter
            .default
            .addObserver(forName: name,
                         object: object,
                         queue: queue,
                         using: callback)
        let notification = NotificationToken(notification: name,
                                             token: token,
                                             object: object)
        tokens.append(notification)
    }
    
    func unsubscribe(notification name: NSNotification.Name, for object: Object) {
        let center = NotificationCenter.default
        tokens
            .filter{
                if let item = $0.object as? Object, item == object, $0.notification == name {
                    return true
                }
                return false
            }
            .forEach{ center.removeObserver($0.token, name: $0.notification, object: $0.object) }
    }
    
    func unsubscribe(notification name: NSNotification.Name) {
        let center = NotificationCenter.default
        tokens
            .filter{ $0.notification == name }
            .forEach{ center.removeObserver($0.token) }
    }
    
    func unsubscribe(forObject object: Object) {
        let center = NotificationCenter.default
        tokens
            .filter{
                if let item = $0.object as? Object, item == object {
                    return true
                }
                return false
            }
            .forEach{ center.removeObserver($0.token) }
    }
    
    mutating func unsubscribeAll() {
        let center = NotificationCenter.default
        tokens.forEach{ center.removeObserver($0.token) }
        tokens = []
    }
}
