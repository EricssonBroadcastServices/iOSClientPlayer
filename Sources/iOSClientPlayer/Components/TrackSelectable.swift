//
//  MediaTracks.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-07.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import AVFoundation

public protocol Track {
    /// Should return a human readable display name of the track
    var name: String { get }
    
    /// Should return the RFC 4646 language tag associated with the track or `nil` if unavailable
    var extendedLanguageTag: String? { get }
    
    /// Should return`NAME` tag value associated with the track or `nil` if unavailable
    var title: String? { get }
    
    /// Should returns the random generated id value for the track
    var mediaTrackId: Int? { get }
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

    /// Should fetch all associated `AVAssetVariant` s
    @available(iOS 15.0, tvOS 15.0, *)
    var variants: [AVAssetVariant]? { get }
    
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
    
    /// Should select the specified audio language if available or, if `allowsEmptyAudioSelection` == true, select no audio track
    ///
    /// - parameter mediaTrackId: unique id of the mediaTrack
    func selectAudio(mediaTrackId: Int?)
    
    /// Should select the specified audio language if available or, if `allowsEmptyAudioSelection` == true, select no audio track
    ///
    /// - parameter title: title of the track
    func selectAudio(title: String?)
    
    /// Should set the preferred audio language tag as defined by RFC 4646 standards
    var preferredAudioLanguage: String? { get set }
    
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
    
    /// Should select the specified text language if available or, if `allowsEmptyTextSelection` == true, select no text track
    ///
    /// - parameter mediaTrackId: unique id of the track
    func selectText(mediaTrackId: Int?)
    
    /// Should select the specified text language if available or, if `allowsEmptyTextSelection` == true, select no text track
    ///
    /// - parameter title: title of the track
    func selectText(title: String?)
    
    /// Should set the preferred text language tag as defined by RFC 4646 standards
    var preferredTextLanguage: String? { get set }
    
    /// Set  peakBitRate for the current Asset
    func setBitRate(selectedBitRate: Double ) 
}
