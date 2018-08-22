//
//  HLSNativeMediaSource.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-08-21.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

/// Extends the standard `MediaSource` protocol with functionality to track the HTTP headers set by internal playback when requesting manifest and media segments.
public protocol MediaSourceRequestHeaders: MediaSource {
    /// Should store the HTTP headers used when requesting manifest and media segments
    var mediaSourceRequestHeaders: [String: String] { get set }
}
