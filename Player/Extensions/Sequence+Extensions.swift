//
//  Sequence+Extensions.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element: RawRepresentable {
    public var rawValues: [Iterator.Element.RawValue] {
        return self.map{ $0.rawValue }
    }
}
