//
//  MediaTracks.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-07.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

public protocol Track {
    /// Should return a human readable display name of the track
    var name: String { get }
    
    /// Should return the RFC 4646 language tag associated with the track or `nil` if unavailable
    var extendedLanguageTag: String? { get }
}

/// Describes selectable and inspectable tracks
public protocol TrackSelectable {
    
    // MARK: Audio
    /// Should fetch the default text track, or `nil` if unavailable
    associatedtype AudioTrack: Track
    
    /// Should fetch the default audio track, or `nil` if unavailable
    var defaultAudioTrack: AudioTrack? { get }
    
    /// Should fetch all associated audio tracks
    var audioTracks: [AudioTrack] { get }
    
    /// Should fetch the selected audio track if available, otherwise `nil`
    var selectedAudioTrack: AudioTrack? { get }
    
    /// Should indicate if it is possible to select no audio track
    var allowsEmptyAudioSelection: Bool { get }
    
    /// Should select the specified audio track or, if `allowsEmptyAudioSelection` == true, select no audio track
    ///
    /// - parameter track: The audio track to select
    func selectAudio(track: AudioTrack?)
    
    /// Should select the specified audio language if available or, if `allowsEmptyAudioSelection` == true, select no audio track
    ///
    /// - parameter language: The RFC 4646 language tag identifying the track
    func selectAudio(language: String?)
    
    
    // MARK: Text
    /// Should fetch the default text track, or `nil` if unavailable
    associatedtype TextTrack: Track
    
    /// Should fetch the default text track, or `nil` if unavailable
    var defaultTextTrack: TextTrack? { get }
    
    /// Should fetch all associated text tracks
    var textTracks: [TextTrack] { get }
    
    /// Should fetch the selected text track if available, otherwise `nil`
    var selectedTextTrack: TextTrack? { get }
    
    /// Should indicate if it is possible to select no text track
    var allowsEmptyTextSelection: Bool { get }
    
    /// Should select the specified text track or, if `allowsEmptyTextSelection` == true, select no text track
    ///
    /// - parameter track: The text track to select
    func selectText(track: TextTrack?)
    
    /// Should select the specified text language if available or, if `allowsEmptyTextSelection` == true, select no text track
    ///
    /// - parameter language: The RFC 4646 language tag identifying the track
    func selectText(language: String?)
}
