//
//  TimedMetadataProvider.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-10-02.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import AVFoundation

public protocol TimedMetadataProvider {
    /// This method is called whenever a new `AVMetadataItem`s are encountered
    ///
    /// - parameter mediaSource: The `MediaSource` which was set to load and prepare itself
    /// - parameter tech: The `Tech` loading the `mediaSource`
    /// - parameter metadata: The metadata encountered
    func onTimedMetadataChanged<Tech, Source>(source: Source?, tech: Tech, metadata: [AVMetadataItem]?) where Source: MediaSource, Tech: PlaybackTech
}
