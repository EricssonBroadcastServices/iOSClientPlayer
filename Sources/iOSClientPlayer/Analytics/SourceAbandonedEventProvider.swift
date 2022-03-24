//
//  SourceAbandonedEventProvider.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-08-06.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

public protocol SourceAbandonedEventProvider {
    /// This method is called whenever a `MediaSource` in preparation was abandoned before it completed loading all properties.
    ///
    /// Adopters should treat this callback as the last point of interaction with `mediaSource` and take appropriate finalization actions.
    ///
    /// - parameter mediaSource: The `MediaSource` which was set to load and prepare itself
    /// - parameter tech: The `Tech` loading the `mediaSource`
    func onSourcePreparationAbandoned<Tech, Source>(ofSource mediaSource: Source, byTech tech: Tech) where Source: MediaSource, Tech: PlaybackTech
}
