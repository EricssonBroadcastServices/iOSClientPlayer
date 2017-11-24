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
    public let fairplayRequester: FairplayRequester?
    public let playSessionId: String
    public let url: URL
    
    public init(url: URL, playSessionId: String = UUID().uuidString, fairplayRequester: FairplayRequester? = nil) {
        self.url = url
        self.playSessionId = playSessionId
        self.fairplayRequester = fairplayRequester
    }
}

extension Manifest: HLSNativeConfigurable {
    public var hlsNativeConfiguration: HLSNativeConfiguration {
        return HLSNativeConfiguration(url: url,
                                      playSessionId: playSessionId,
                                      drm: fairplayRequester)
    }
}

