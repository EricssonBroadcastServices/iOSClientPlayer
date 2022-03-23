//
//  TechDeallocationEventProvider.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-05-24.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

public protocol TechDeallocationEventProvider {
    /// This method is called whenever preparation of a `MediaSource` finishes after the initiating `Tech` has been deallocated.
    ///
    /// Adopters should treat this callback as the last point of interaction with `mediaSource` and take appropriate finalization actions.
    ///
    /// - parameter mediaSource: The `MediaSource` which was set to load and prepare itself
    func onTechDeallocated<Source>(beforeMediaPreparationFinalizedOf mediaSource: Source) where Source: MediaSource
}
