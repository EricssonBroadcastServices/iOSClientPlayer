//
//  FairplayRequester.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-06-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

/// Specialized *named* protocol extending `AVAssetResourceLoaderDelegate` intended to be used for *Fairplay* `DRM` management.
public protocol FairplayRequester: AVAssetResourceLoaderDelegate {
    /// Should expose errors encountered during the validation process.
    var keyValidationError: Error? { get }
}
