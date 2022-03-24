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
    internal let id: Int?
    
    init(mediaOption: AVMediaSelectionOption, id: Int? = nil ) {
        self.mediaOption = mediaOption
        self.id = id
    }
    
    /// Describes the `MediaTrack`, for example *audio* or *subtitle*
    public var type: String {
        return mediaOption.mediaType.rawValue
    }
    
    /// A string describing the `MediaTrack`, suitable for display.
    public var name: String {
        return mediaOption.displayName
    }
    
    /// Returns the`NAME` tag value associated with the track or `nil` if unavailable
    public var title: String? {
        return mediaOption.value(forKey: "title") as? String
    }
    
    /// Returns the id value for the track
    public var mediaTrackId: Int? {
        if let id = id {
            return id
        }
        return nil
    }
    
    /// Returns the RFC 4646 language tag associated with the track or `nil` if unavailable
    public var extendedLanguageTag: String? {
        return mediaOption.extendedLanguageTag
    }
    
    public static func == (lhs: MediaTrack, rhs: MediaTrack) -> Bool {
        return lhs.mediaOption == rhs.mediaOption
    }
    
    
}
