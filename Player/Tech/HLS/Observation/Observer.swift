//
//  Observer.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// `Observer`s represent the *observable* used to track a registered `KVO` subscriber
internal class Observer<T: NSObject>: NSObject {
    /// Target to observe
    internal unowned var object: T
    
    /// *KeyPath* on `object` to observe
    internal let path: String
    
    /// Fires when the `KVO` fires.
    internal var callback: (T, KVOChange) -> Void = { _,_  in }
    
    internal init(of object: T, at path: String, with options: NSKeyValueObservingOptions, callback: @escaping (T, KVOChange) -> Void) {
        self.object = object
        self.path = path
        self.callback = callback
        super.init()
        
        object.addObserver(self,
                           forKeyPath: path,
                           options: options,
                           context: nil)
    }
    
    /// Stops `KVO` observation of `object` at `path`
    internal func cancel() {
        object.removeObserver(self, forKeyPath: path)
    }
    
    /// Override that triggers the `callback` when a `KVO` change is observed.
    ///
    /// Please see Apple's documentation regarding *Key Value Observation* for more information.
    internal override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard path == keyPath else { return }
        guard self.object == object as? T else { return }
        
        callback(self.object, KVOChange(rawDict: change))
    }
}
