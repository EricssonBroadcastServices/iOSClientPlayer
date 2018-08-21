//
//  HLSNativeMediaSource.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-08-21.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

/// Extends the standard `MediaSource` protocol with functionality to track the HTTP header `X-Playback-Session-Id` set by internal playback.
public protocol HLSNativeMediaSource: MediaSource {
    /// Corresponds to the `X-Playback-Session-Id` header as used when requesting segments and manifests for this source.
    var streamingRequestPlaybackSessionId: String? { get set }
}
