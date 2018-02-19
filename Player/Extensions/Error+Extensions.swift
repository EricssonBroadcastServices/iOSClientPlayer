//
//  Error+Extensions.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-19.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

extension Error {
    internal var debugInfoString: String {
        if let nsError = self as? NSError {
            return nsError.userInfo.description
        }
        return self.localizedDescription
    }
}
