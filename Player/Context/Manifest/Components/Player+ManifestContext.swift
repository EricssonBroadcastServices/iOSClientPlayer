//
//  Player+ManifestContext.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

extension Player where Tech == HLSNative<ManifestContext> {
    /// Streaming extension to load and play `Manifest` sources defined by `ManifestContext`.
    ///
    /// - parameter url: the location of the media to play
    func stream(url: URL) {
        let manifest = context.manifest(from: url)
        tech.load(source: manifest)
    }
}
