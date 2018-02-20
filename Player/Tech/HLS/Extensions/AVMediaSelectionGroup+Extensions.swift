//
//  AVMediaSelectionGroup+Extensions.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-20.
//  Copyright © 2018 emp. All rights reserved.
//

import AVFoundation

internal extension AVMediaSelectionGroup {
    
    // Convenience property returning the all `AVMediaSelectionOption`s for the group
    internal var tracks: [MediaTrack] {
        return options.map(MediaTrack.init)
    }
    
    // Convenience property returning the default `AVMediaSelectionOption` for the group
    internal var defaultTrack: MediaTrack? {
        guard let option = defaultOption else { return nil }
        return MediaTrack(mediaOption: option)
    }
    
    /// Convenience method selecting a track in a group
    internal func track(forLanguage language: String) -> AVMediaSelectionOption? {
        return options.filter{ $0.extendedLanguageTag == language }.first
    }
}
