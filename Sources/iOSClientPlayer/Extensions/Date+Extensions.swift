//
//  Date+Extensions.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-01-30.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

extension Date {
    /// Date formatter for utc.
    internal static func utcFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }
    
    /// Unix epoch time in milliseconds
    internal var millisecondsSince1970: Int64 {
        return Int64((timeIntervalSince1970 * 1000.0).rounded())
    }
    
    /// Create a Date from unix epoch time in milliseconds
    internal init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
