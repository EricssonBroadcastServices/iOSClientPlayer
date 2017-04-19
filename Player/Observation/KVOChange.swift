//
//  KVOChange.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

struct KVOChange {
    /// The kind of the change.
    /// - seealso: `NSKeyValueChangeKindKey`
    var kind: NSKeyValueChange? {
        return (self.rawDict?[.kindKey] as? UInt).flatMap(NSKeyValueChange.init)
    }
    
    /// The old value from the change.
    /// - seealso: `NSKeyValueChangeOldKey`
    var old: Any? {
        return self.rawDict?[.oldKey]
    }
    
    /// The new value from the change.
    /// - seealso: `NSKeyValueChangeNewKey`
    var new: Any? {
        return self.rawDict?[.newKey]
    }
    
    /// Whether this callback is being sent prior to the change.
    /// - seealso: `NSKeyValueChangeNotificationIsPriorKey`
    var isPrior: Bool {
        return self.rawDict?[.notificationIsPriorKey] as? Bool ?? false
    }
    
    /// The indexes of the inserted, removed, or replaced objects when relevant.
    /// - seealso: `NSKeyValueChangeIndexesKey`
    var indexes: IndexSet? {
        return self.rawDict?[.indexesKey] as? IndexSet
    }
    
    /// The raw change dictionary passed to `observeValueForKeyPath(_:ofObject:change:context:)`.
    let rawDict: [NSKeyValueChangeKey: Any]?
    
    init(rawDict: [NSKeyValueChangeKey: Any]?) {
        self.rawDict = rawDict
    }
}
