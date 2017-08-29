//
//  AVAsset+LoadableKeys.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAsset {
    /// Convenience `enum` supplying *typed key paths* for loadable resources on `AVAsset`
    enum LoadableKeys: String {
        /// Duration
        case duration = "duration"
        
        
        /*
         // Preference
         case preferredRate = "preferredRate"
         case preferredVolume = "preferredVolume"
         case preferredTransform = "preferredTransform"
         
         
         case providesPreciseDurationAndTiming = "providesPreciseDurationAndTiming"
         
         // Reference Restrictions
         case referenceRestrictions = "referenceRestrictions"*/
        
        
        /// Tracks
        case tracks = "tracks"
        //case trackGroups = "trackGroups"
        
        
        /// Playable
        case playable = "playable"
        
        
    }
}
