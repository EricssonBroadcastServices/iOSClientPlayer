//
//  KeyValueObserver.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

protocol KeyValueObserver {
    associatedtype Object: NSObject
    var observers: [Observer<Object>] { get set }
}

extension KeyValueObserver where Object: KeyValueObservable, Object.ObservableKeys: RawRepresentable, Object.ObservableKeys.RawValue == String {
    mutating func observe(path: Object.ObservableKeys,
                          on object: Object,
                          with options: NSKeyValueObservingOptions = [.new, .old, .initial, .prior],
                          callback: @escaping (Object, KVOChange) -> Void) {
        let kvo = Observer<Object>(of: object,
                                   at: path.rawValue,
                                   with: options,
                                   callback: callback)
        observers.append(kvo)
    }
    
    func stopObserving(path: Object.ObservableKeys, on object: Object) {
        observers
            .filter{ $0.object == object && $0.path == path.rawValue }
            .forEach{ $0.cancel() }
    }
    
    mutating func stopObservingAll() {
        observers.forEach{ $0.cancel() }
        observers = []
    }
}
