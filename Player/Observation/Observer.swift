//
//  Observer.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

class Observer<T: NSObject>: NSObject {
    unowned var object: T
    let path: String
    var callback: (T, KVOChange) -> Void = { _ in }
    init(of object: T, at path: String, with options: NSKeyValueObservingOptions, callback: @escaping (T, KVOChange) -> Void) {
        self.object = object
        self.path = path
        self.callback = callback
        super.init()
        
        object.addObserver(self,
                           forKeyPath: path,
                           options: options,
                           context: nil)
    }
    
    func cancel() {
        object.removeObserver(self, forKeyPath: path)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard path == keyPath else { return }
        guard self.object == object as? T else { return }
        
        callback(self.object, KVOChange(rawDict: change))
    }
}
