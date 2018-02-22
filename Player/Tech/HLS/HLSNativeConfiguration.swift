//
//  HLSNativeConfiguration.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-22.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

/// Playback configuration specific for the `HLSNative` *tech*.
public struct HLSNativeConfiguration {
    /// DRM agent used to validate the context source
    public let drm: FairplayRequester?
    
    /// The desired limit, in bits per second, of network bandwidth consumption for this item.
    ///
    /// Setting a non-zero value will indicate the player should attempt to limit playback to that bitrate. If network bandwidth consumption cannot be lowered to meet the preferredPeakBitRate, it will be reduced as much as possible while continuing to play the item.
    ///
    /// `nil` will indicate no restrictions should be applied.
    public let preferredMaxBitrate: Int64?
    
    public init(drm: FairplayRequester? = nil, preferredMaxBitrate: Int64? = nil) {
        self.drm = drm
        self.preferredMaxBitrate = preferredMaxBitrate
    }
}
