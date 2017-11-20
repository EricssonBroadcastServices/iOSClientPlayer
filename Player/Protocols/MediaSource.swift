//
//  MediaSource.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public protocol MediaSource {
    associatedtype SourceError: MediaSourceError
    associatedtype Connector: AnalyticsConnector
    var analyticsConnector: Connector { get }
    
    /// Optional DRM agent used to validate the context
    var drmAgent: DrmAgent { get }
    
    /// A unique identifier for this playback session
    var playSessionId: String { get }
    
    /// The location for this media
    var url: URL { get }
    
    //    func load<Tech: Tech>(using tech: Tech, callback: @escaping (Tech.TechError?) -> Void)
}

extension MediaSource {
    func loadableBy(tech: Tech<Self>) -> Bool {
        return false
    }
}

extension MediaSource {
    var externalDrmAgent: ExternalDrm? {
        switch drmAgent {
        case .external(agent: let agent): return agent
        case .selfContained: return nil
        }
    }
}
