//
//  HLSNative+NetworkBehavior.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-22.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

extension HLSNative: NetworkBehavior {
    
    /// The desired limit, in bits per second, of network bandwidth consumption for this item.
    ///
    /// Setting a non-zero value will indicate the player should attempt to limit playback to that bitrate. If network bandwidth consumption cannot be lowered to meet the preferredPeakBitRate, it will be reduced as much as possible while continuing to play the item.
    ///
    /// `nil` will indicate no restrictions should be applied.
    public var preferredMaxBitrate: Int64? {
        print("----",currentAsset?.playerItem)
        print("----",currentAsset?.playerItem.preferredPeakBitRate)
        guard let value = currentAsset?.playerItem.preferredPeakBitRate else { return nil }
        return Int64(value)
    }
}
