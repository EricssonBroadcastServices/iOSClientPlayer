//
//  HLSNative+TrackSelectable.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-07.
//  Copyright © 2018 emp. All rights reserved.
//

import AVFoundation

extension HLSNative: TrackSelectable {
    // MARK: Audio
    /// Returns the audio related `MediaGroup`
    public var audioGroup: MediaGroup? {
        return currentAsset?
            .playerItem
            .audioGroup
    }
    
    
    @available(iOS 15.0,tvOS 15.0, *)
    /// Returns all the available `AVAssetVariant`
    public var variants: [AVAssetVariant]? {
        return currentAsset?.urlAsset.variants
    }

    
    
    /// Returns the default audio track, or `nil` if unavailable
    public var defaultAudioTrack: MediaTrack? {
        return audioGroup?.defaultTrack
    }
    
    /// Returns all associated audio tracks
    public var audioTracks: [MediaTrack] {
        return audioGroup?.tracks ?? []
    }
    
    /// Returns the selected audio track if available, otherwise `nil`
    public var selectedAudioTrack: MediaTrack? {
        return audioGroup?.selectedTrack
    }
    
    /// Indicated if it is possible to select no audio track
    public var allowsEmptyAudioSelection: Bool {
        return audioGroup?.mediaGroup.allowsEmptySelection ?? true
    }
    
    /// Selects the specified audio track or, if `allowsEmptyAudioSelection` == true, select no audio track
    ///
    /// - parameter track: The audio track to select
    public func selectAudio(track: MediaTrack?) {
        select(track: track, inGroup: audioGroup?.mediaGroup)
        UserDefaults.standard.set(track?.extendedLanguageTag, forKey: "lastSelectedAudioTrackLanguageTag")
    }
    
    /// Selects the specified audio language if available or, if `allowsEmptyAudioSelection` == true, select no audio track
    ///
    /// - parameter language: The RFC 4646 language tag identifying the track
    public func selectAudio(language: String?) {
        guard let language = language else {
            selectAudio(track: nil)
            return
        }
        guard let option = audioGroup?.mediaSelectionOption(forLanguage: language) else { return }
        selectAudio(track: MediaTrack(mediaOption: option))
    }
    
    
    /// Selects the specified audio language if available or, if `allowsEmptyAudioSelection` == true, select no audio track
    ///
    /// - parameter mediaTrackId: mediaTrackId of the track
    public func selectAudio(mediaTrackId: Int?) {
        guard let mediaTrackId = mediaTrackId else {
            selectAudio(track: nil)
            return
        }
        guard let option = audioGroup?.mediaSelectionOption(forId: mediaTrackId) else { return }
        selectAudio(track: option)
    }
    
    /// Selects the specified audio language if available or, if `allowsEmptyAudioSelection` == true, select no audio track
    ///
    /// - parameter title: title of the track
    public func selectAudio(title: String?) {
        guard let title = title else {
            selectAudio(track: nil)
            return
        }
        guard let track = textGroup?.mediaSelectionOption(forTitle: title) else { return }
        selectAudio(track: track)
    }
    
    
    // MARK: Text
    /// Returns the text related `MediaGroup`
    public var textGroup: MediaGroup? {
        return currentAsset?
            .playerItem
            .textGroup
    }
    
    /// Returns the default text track, or `nil` if unavailable
    public var defaultTextTrack: MediaTrack? {
        return textGroup?.defaultTrack
    }
    
    /// Returns all associated text tracks
    public var textTracks: [MediaTrack] {
        return textGroup?.tracks ?? []
    }
    
    /// Returns the selected text track if available, otherwise `nil`
    public var selectedTextTrack: MediaTrack? {
        return textGroup?.selectedTrack
    }
    
    /// Indicates if it is possible to select no text track
    public var allowsEmptyTextSelection: Bool {
        return textGroup?.mediaGroup.allowsEmptySelection ?? true
    }
    
    /// Selects the specified text track or, if `allowsEmptyTextSelection` == true, select no text track
    ///
    /// - parameter track: The text track to select
    public func selectText(track: MediaTrack?) {
        select(track: track, inGroup: textGroup?.mediaGroup)
        UserDefaults.standard.set(track?.extendedLanguageTag, forKey: "lastSelectedTextTrackLanguageTag")
    }
    
    /// Selects the specified text language if available or, if `allowsEmptyTextSelection` == true, select no text track
    ///
    /// - parameter language: The RFC 4646 language tag identifying the track
    public func selectText(language: String?) {
        guard let language = language else {
            selectText(track: nil)
            return
        }
        guard let option = textGroup?.mediaSelectionOption(forLanguage: language) else { return }
        selectText(track: MediaTrack(mediaOption: option))
    }
    
    /// Selects the specified text language if available or, if `allowsEmptyTextSelection` == true, select no text track
    ///
    /// - parameter mediaTrackId: mediaTrackId of the track
    public func selectText(mediaTrackId: Int?) {
        guard let mediaTrackId = mediaTrackId else {
            selectText(track: nil)
            return
        }
        guard let option = textGroup?.mediaSelectionOption(forId: mediaTrackId) else { return }
        selectText(track: option)
    }
    
    /// Selects the specified text language if available or, if `allowsEmptyTextSelection` == true, select no text track
    ///
    /// - parameter title: title of the track
    public func selectText(title: String?) {
        guard let title = title else {
            selectText(track: nil)
            return
        }
        guard let track = textGroup?.mediaSelectionOption(forTitle: title) else { return }
        selectText(track: track)
    }
    
    // MARK: Private
    /// Convenience method selecting a track in a group
    private func select(track: MediaTrack?, inGroup group: AVMediaSelectionGroup?) {
        guard let group = group else { return }
        currentAsset?.playerItem.select(track?.mediaOption, in: group)
        
        // Keep the selected subtitle in the userdefaults for downloaded assets
        // This is required for fast seeking as AVFoundation can loose the subtitle track sometimes.
        if let urlAsset = currentAsset?.urlAsset, let accetCache = urlAsset.assetCache {
            if accetCache.isPlayableOffline {
                // Add the current selected subtitle track to the userdefaults
                UserDefaults.standard.set(track?.extendedLanguageTag , forKey: "prefferedMediaSelection")
            } else {
               // do nothing
            }
        }
        
       
    }

    /// Convenience method for setting PeakBitRate in the currrentPlayerItem
    public func setBitRate(selectedBitRate: Double ) {
        currentAsset?.playerItem.preferredPeakBitRate = selectedBitRate
    }
}
