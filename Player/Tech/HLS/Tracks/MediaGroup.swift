//
//  MediaGroup.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-20.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import AVFoundation

/// A set of available media for a specific group, such as:
///
/// * Subtitles
/// * Audio
public struct MediaGroup {
    internal let mediaGroup: AVMediaSelectionGroup
    internal let selectedMedia: AVMediaSelectionOption?
     
    /// The default audio track, or `nil` if unavailable
    public var defaultTrack: MediaTrack? {
        return mediaGroup.defaultTrack
    }
    
    /// Returns all available `MediaTrack`s for the group
    public var tracks: [MediaTrack] {
        return mediaGroup.tracks
    }
    
    /// Returns the selected `MediaTrack` or `nil` if no track has been selected in the group
    public var selectedTrack: MediaTrack? {
        guard let media = selectedMedia else { return nil }
        return mediaGroup.selectedTrack(media: media)
    }
    
    /// Returns true if the group allows no `MediaTrack` to be selected
    public var allowsEmptySelection: Bool {
        return mediaGroup.allowsEmptySelection
    }
    
    /// Filters the associated `AVMediaSelectionOption`s on the `extendedLanguageTag`
    internal func mediaSelectionOption(forLanguage language: String) -> AVMediaSelectionOption? {
        return mediaGroup.track(forLanguage: language)
    }
    
    /// Filters the associated `AVMediaSelectionOption`s on the `mediaTrackId`
    internal func mediaSelectionOption(forId mediaTrackId: Int) -> MediaTrack? {
        return mediaGroup.track(forId: mediaTrackId)
    }
    
    /// Filters the associated `AVMediaSelectionOption`s on the `title`
    internal func mediaSelectionOption(forTitle title: String) -> MediaTrack? {
        return mediaGroup.track(forTitle: title)
    }
}
