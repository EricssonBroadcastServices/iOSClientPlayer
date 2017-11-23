//
//  ManifestContext.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public final class ManifestContext: MediaContext {
    public typealias ContextError = Error
    public typealias Source = Manifest
    
    func manifest(from url: URL) -> Manifest {
        let source = Manifest(playSessionId: UUID().uuidString,
                              url: url)
        source.analyticsConnector.providers = analyticsGenerator(source)
        return source
    }
    
    public var analyticsGenerator: (Source) -> [AnalyticsProvider] = { _ in return [AnalyticsLogger()] }
    
    public enum Error: Swift.Error {
        case someError
    }
}
