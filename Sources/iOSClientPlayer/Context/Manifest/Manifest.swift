//
//  Manifest.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Basic `MediaSource` that can do simple playback of *unencrypted* media sources.
///
/// It has an optional drm agent in the form of a `FairplayRequester` that, if implemented, can be used to play *FairPlay* protected media using the `HLSNative` tech.
public class Manifest: MediaSource {
    /// Basic connector
    public var analyticsConnector: AnalyticsConnector = PassThroughConnector()
    
    /// Drm agent to play *FairPlay* using the `HLSNative` tech.
    public let fairplayRequester: FairplayRequester?
    
    /// Unique playsession id
    public let playSessionId: String
    
    /// Media locator for the media source.
    public let url: URL
    
    public init(url: URL, playSessionId: String = UUID().uuidString, fairplayRequester: FairplayRequester? = nil) {
        self.url = url
        self.playSessionId = playSessionId
        self.fairplayRequester = fairplayRequester
    }
}