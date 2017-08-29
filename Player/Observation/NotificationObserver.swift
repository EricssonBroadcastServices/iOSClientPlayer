//
//  NotificationObserver.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// `Notification` wrapper for convenience access to notification system.
internal protocol NotificationObserver {
    associatedtype Object: NSObject
    
    /// Storage for the *observables* used to track registered notifications.
    var tokens: [NotificationToken] { get set }
}

extension NotificationObserver {
    /// Registers to receive `Notification`s published by the specified `object`.
    ///
    /// - parameter name: `Notification` identifier
    /// - parameter object: Target whose notifications the observer wants to receive
    /// - parameter queue: Optionally specified queue to receive the `Notification`s.
    /// - parameter callback: Executes when the `Notification` fires.
    internal mutating func subscribe(notification name: NSNotification.Name, for object: Object? = nil, queue: OperationQueue? = OperationQueue.main, callback: @escaping (Notification) -> Void) {
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
    
    /// Stops *observer* from listening for notifications with `name` on `object`
    ///
    /// This will filter all remaining *observer* `token`s still active and cancel the related subsciptions matching `name` and `object`.
    ///
    /// - parameter name: `Notification` identifier to unsubscribe from
    /// - parameter object: Target to unsubscribe `name` from.
    internal func unsubscribe(notification name: NSNotification.Name, for object: Object) {
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
    
    internal func unsubscribe(notification name: NSNotification.Name) {
        let center = NotificationCenter.default
        tokens
            .filter{ $0.notification == name }
            .forEach{ center.removeObserver($0.token) }
    }
    
    internal func unsubscribe(forObject object: Object) {
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
    
    internal mutating func unsubscribeAll() {
        let center = NotificationCenter.default
        tokens.forEach{ center.removeObserver($0.token) }
        tokens = []
    }
}
