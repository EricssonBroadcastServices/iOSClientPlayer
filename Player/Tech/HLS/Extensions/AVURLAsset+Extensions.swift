//
//  AVURLAsset+Extensions.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-22.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import AVFoundation

extension AVURLAsset {
    internal static func options(from configuration: HLSNativeConfiguration) -> [String: Any]? {
        if #available(iOS 10.0, *) {
            return [AVURLAssetAllowsCellularAccessKey: configuration.allowCellularAccess]
        }
        else {
            return nil
        }
    }
}
