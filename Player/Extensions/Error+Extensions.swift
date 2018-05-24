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
            return expandedError.domain + " \(expandedError.code): " + expandedError.message + " " + (expandedError.info ?? "")
        }
        if let nsError = self as? NSError {
            var message = ""
            message += "Code=\(nsError.code) \n "
            message += "Domain=\(nsError.domain) \n "
            if let debugDescription = nsError.userInfo[NSDebugDescriptionErrorKey] as? String {
                message += "Message=\(debugDescription) \n "
            }
            else {
                message += "Message=\(nsError.debugDescription) \n "
            }
            if let uError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                message += "UnderlyingCode=\(uError.code) \n "
                message += "UnderlyingDomain=\(uError.domain) \n "
                if let uDebugDescription = uError.userInfo[NSDebugDescriptionErrorKey] as? String {
                    message += "UnderlyingMessage=[\(uDebugDescription)] \n "
                }
                else {
                    message += "UnderlyingMessage=[\(uError.debugDescription)] \n "
                }
            }
            return message
        }
        return self.localizedDescription
    }
}
