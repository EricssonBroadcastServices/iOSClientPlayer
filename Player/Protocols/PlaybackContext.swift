//
//  PlaybackContext.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public protocol MediaContext: class {
    associatedtype ContextError: Error
    associatedtype Source: MediaSource
    
    /// TODO: Fetch/generate the playback context. This is optionaly an async process, contacting an external server.
    //    func fetch(callback: @escaping (Source?, ContextError?) -> Void)
    
    
    var analyticsGenerator: (Source) -> [AnalyticsProvider] { get set }
    
    //    /// Returns a string created from the UUID, such as "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
    //    ///
    //    /// A unique playSessionId should be generated for each new playSession.
    //    fileprivate static func generatePlaySessionId() -> String {
    //      return UUID().uuidString
    //    }
}
