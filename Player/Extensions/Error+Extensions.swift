//
//  Error+Extensions.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-19.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import AVFoundation
extension Error {
    internal var debugInfoString: String {
        if let expandedError = self as? ExpandedError {
            var message = "[\(expandedError.code):" + expandedError.domain + "] \n"
            if let underlyingError = expandedError.underlyingError {
                message += underlyingError.debugInfoString
            }
            else {
                message += "[" + expandedError.message + " " + (expandedError.info ?? "") + "]"
            }
            return message
        }
        else if let nsError = self as? NSError {
            var message = "[\(nsError.code):\(nsError.domain)] \n "
            message += "[\(nsError.debugDescription)] \n "
            
            if let uError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                message += uError.debugInfoString
            }
            return message
        }
        return "[\(self.localizedDescription)] \n"
    }
}
