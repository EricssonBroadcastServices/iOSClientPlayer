//
//  MediaTrack.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-20.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import AVFoundation

/// MediaTrack describes a selectable track
public struct MediaTrack: Track, Equatable {
    internal let mediaOption: AVMediaSelectionOption
    
    /// Describes the `MediaTrack`, for example *audio* or *subtitle*
    public var type: String {
        return mediaOption.mediaType
    }
    
    /// A string describing the `MediaTrack`, suitable for display.
    public var name: String {
        return mediaOption.displayName
    }
    
    /// Returns the RFC 4646 language tag associated with the track or `nil` if unavailable
    public var extendedLanguageTag: String? {
        return mediaOption.extendedLanguageTag
    }
    
    public static func == (lhs: MediaTrack, rhs: MediaTrack) -> Bool {
        return lhs.mediaOption == rhs.mediaOption
    }
}
