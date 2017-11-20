//
//  KeyValueObserver.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation


/// `KVO` wrapper for convenience access to *key value observation.
///
/// For more information regarding *Key Value Observation*, please see Apple's documentation
internal protocol KeyValueObserver {
    /// Observed object type.
    associatedtype Object: NSObject
    
    /// Storage for the *observables* used to track registered `KVO`.
    var observers: [Observer<Object>] { get set }
}


extension KeyValueObserver where Object: KeyValueObservable, Object.ObservableKeys: RawRepresentable, Object.ObservableKeys.RawValue == String {
    /// Registers an *observer* that receives `KVO` notifications for the *key path* relative to `object`.
    ///
    /// - parameter path: KeyPath to observe
    /// - parameter object: Object to observe `path` for
    /// - parameter options: `NSKeyValueObservingOptions` specifying which value changes to include
    /// - parameter callback: Executes when the `KVO` change fires.
    internal mutating func observe(path: Object.ObservableKeys,
                          on object: Object,
                          with options: NSKeyValueObservingOptions = [.new, .old, .initial, .prior],
                          callback: @escaping (Object, KVOChange) -> Void) {
        let kvo = Observer<Object>(of: object,
                                   at: path.rawValue,
                                   with: options,
                                   callback: callback)
        observers.append(kvo)
    }
    
    /// Stops `KVO` observation of `path` on `object`.
    internal func stopObserving(path: Object.ObservableKeys, on object: Object) {
        observers
            .filter{ $0.object == object && $0.path == path.rawValue }
            .forEach{ $0.cancel() }
    }
    
    /// Removes all `KVO` observations, no matter the *path* or *target*.
    internal mutating func stopObservingAll() {
        observers.forEach{ $0.cancel() }
        observers = []
    }
}
