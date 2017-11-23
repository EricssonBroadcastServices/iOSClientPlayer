//
//  MediaSource.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public protocol MediaSource {
    var analyticsConnector: AnalyticsConnector { get set }
    
    /// Optional DRM agent used to validate the context
    var drmAgent: DrmAgent { get }
    
    /// Returns a token string uniquely identifying this playSession.
    /// Example: “E621E1F8-C36C-495A-93FC-0C247A3E6E5F”
    var playSessionId: String { get }
    
    /// The location for this media
    var url: URL { get }
}

extension MediaSource {
    /// Convenience property for extracting an externally defined `DRM` agent.
    var externalDrmAgent: ExternalDrm? {
        switch drmAgent {
        case .external(agent: let agent): return agent
        case .selfContained: return nil
        }
    }
}
