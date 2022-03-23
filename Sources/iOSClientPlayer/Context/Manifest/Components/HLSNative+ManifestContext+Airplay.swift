//
//  HLSNative+ManifestContext+Airplay.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-03-15.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

extension Player where Tech == HLSNative<ManifestContext> {
    public func onAirplayStatusChanged(callback: @escaping (Player<HLSNative<ManifestContext>>, Manifest?, Bool) -> Void) -> Self {
        tech.onAirplayStatusChanged = { [weak self] tech, source, airplaying in
            guard let `self` = self else { return }
            callback(self, source, airplaying)
        }
        return self
    }
}
