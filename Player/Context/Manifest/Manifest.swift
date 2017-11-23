//
//  Manifest.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public class Manifest: MediaSource {
    public var analyticsConnector: AnalyticsConnector = PassThroughConnector()
    public let drmAgent = DrmAgent.selfContained
    public let playSessionId: String
    public let url: URL
    
    public init(playSessionId: String, url: URL) {
        self.playSessionId = playSessionId
        self.url = url
    }
}


extension Manifest: HLSNativeConfigurable {
    public var hlsNativeConfiguration: HLSNativeConfiguration {
        let agent = externalDrmAgent as? FairplayRequester
        return HLSNativeConfiguration(url: url,
                                      playSessionId: playSessionId,
                                      drm: agent)
    }
}
