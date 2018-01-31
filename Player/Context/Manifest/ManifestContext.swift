//
//  ManifestContext.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Basic `MediaContext` that allows playback of *unencrypted* media through a specified `URL`
public final class ManifestContext: MediaContext {
    /// Simple error
    public typealias ContextError = Error
    
    /// Simple warning message
    public typealias ContextWarning = Warning
    
    /// Source is defined as a `Manifest`
    public typealias Source = Manifest
    
    /// Creates a `Manifest` from the specified `URL`
    ///
    /// - parameter url: `URL` to the media source
    /// - returns: `Manifest` describing the media source
    func manifest(from url: URL, fairplayRequester: FairplayRequester? = nil) -> Manifest {
        let source = Manifest(url: url)
        source.analyticsConnector.providers = analyticsProviders(for: source)
        return source
    }
    
    /// Default analytics contains an `AnalyticsLogger`
    public var analyticsGenerators: [(Source?) -> AnalyticsProvider] = [{ _ in return AnalyticsLogger() }]
    
    public struct Error: ExpandedError {
        public let message: String
        public let code: Int
        
        public init(message: String, code: Int) {
            self.message = message
            self.code = code
        }
    }
    
    public struct Warning: WarningMessage {
        public let message: String
        
        public init(message: String) {
            self.message = message
        }
    }
}
