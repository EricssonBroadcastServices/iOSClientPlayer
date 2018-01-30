//
//  HLSNativeWarning.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-01-30.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

public enum HLSNativeWarning: WarningMessage {
    case seekableRangesEmpty(source: MediaSource?)
}

extension HLSNativeWarning {
    public var message: String {
        switch self {
        case .seekableRangesEmpty(source: let source): return "Seekable ranges empty for sourceId \(source?.playSessionId)"
        }
    }
}
