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
        if let expandedError = self as? ExpandedError {
            return expandedError.domain + " \(expandedError.code): " + expandedError.message + " " + (expandedError.info ?? "")
        }
        if let nsError = self as? NSError {
            var message = ""
            message += "Code=\(nsError.code) \n "
            message += "Domain=\(nsError.domain) \n "
            if let value = nsError.userInfo[NSDebugDescriptionErrorKey] as? String {
                message += "Message=\(value) \n "
            }
            else {
                message += "Message=\(nsError.debugDescription) \n "
            }
            
            if let value = nsError.userInfo[NSURLErrorKey] as? URL {
                message += "URL=\(value.absoluteString) \n"
            }
            
            if let uError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                message += "UnderlyingCode=\(uError.code) \n "
                message += "UnderlyingDomain=\(uError.domain) \n "
                if let value = uError.userInfo[NSDebugDescriptionErrorKey] as? String {
                    message += "UnderlyingMessage=[\(value)] \n "
                }
                else {
                    message += "UnderlyingMessage=[\(uError.debugDescription)] \n "
                }
                
                if let value = uError.userInfo[NSURLErrorKey] as? URL {
                    message += "UnderlyingURL=\(value.absoluteString) \n"
                }
            }
            return message
        }
        return self.localizedDescription
    }
}
