//
//  HLSNative+MediaTracks.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-07.
//  Copyright © 2018 emp. All rights reserved.
//

import AVFoundation

internal extension AVMediaSelectionGroup {
    internal var tracks: [MediaTrack] {
        return options.map(MediaTrack.init)
    }
    
    internal var defaultTrack: MediaTrack? {
        guard let option = defaultOption else { return nil }
        return MediaTrack(mediaOption: option)
    }
}

internal extension AVPlayerItem {
    internal var audioGroup: MediaGroup? {
        guard let group = asset.mediaSelectionGroup(forMediaCharacteristic: .audible) else { return nil }
        return MediaGroup(mediaGroup: group, selectedMedia: selectedMediaOption(in: group))
    }
    
    internal var textGroup: MediaGroup? {
        guard let group = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return nil }
        return MediaGroup(mediaGroup: group, selectedMedia: selectedMediaOption(in: group))
    }
}

public struct MediaGroup {
    internal let mediaGroup: AVMediaSelectionGroup
    internal let selectedMedia: AVMediaSelectionOption?
    
    public var defaultTrack: MediaTrack? {
        return mediaGroup.defaultTrack
    }
    
    public var tracks: [MediaTrack] {
        return mediaGroup.tracks
    }
    
    public var selectedTrack: MediaTrack? {
        guard let media = selectedMedia else { return nil }
        return MediaTrack(mediaOption: media)
    }
    
    internal func mediaSelection(forLanguage language: String) -> AVMediaSelectionOption? {
        return mediaGroup.options.filter{ $0.displayName == language }.first
    }
}
// MARK: Track
public struct MediaTrack: Track, Equatable {
    internal let mediaOption: AVMediaSelectionOption
    
    public var type: String {
        return mediaOption.mediaType
    }
    
    public var name: String {
        return mediaOption.displayName
    }
    
    public var extendedLanguageTag: String? {
        return mediaOption.extendedLanguageTag
    }
    
    public static func == (lhs: MediaTrack, rhs: MediaTrack) -> Bool {
        return lhs.mediaOption == rhs.mediaOption
    }
}

extension HLSNative: MediaTracks {
    
    
    // MARK: Audio
    public var audioGroup: MediaGroup? {
        return currentAsset?
            .playerItem
            .audioGroup
    }
    
    public var defaultAudioTrack: MediaTrack? {
        return audioGroup?.defaultTrack
    }
    
    public var audioTracks: [MediaTrack] {
        return audioGroup?.tracks ?? []
    }
    
    public var selectedAudioTrack: MediaTrack? {
        return audioGroup?.selectedTrack
    }
    
    public func selectAudio(track: MediaTrack?) {
        select(track: track, inGroup: audioGroup?.mediaGroup)
    }
    
    public func selectAudio(language: String?) {
        guard let language = language else {
            selectAudio(track: nil)
            return
        }
        guard let option = audioGroup?.mediaSelection(forLanguage: language) else { return }
        selectAudio(track: MediaTrack(mediaOption: option))
    }
    
    // MARK: Text
    private var textGroup: MediaGroup? {
        return currentAsset?
            .playerItem
            .textGroup
    }
    
    public var defaultTextTrack: MediaTrack? {
        return textGroup?.defaultTrack
    }
    
    public var textTracks: [MediaTrack] {
        return textGroup?.tracks ?? []
    }
    
    public var selectedTextTrack: MediaTrack? {
        return textGroup?.selectedTrack
    }
    
    public func selectText(track: MediaTrack?) {
        select(track: track, inGroup: textGroup?.mediaGroup)
    }
    
    public func selectText(language: String?) {
        guard let language = language else {
            selectText(track: nil)
            return
        }
        guard let option = textGroup?.mediaSelection(forLanguage: language) else { return }
        selectText(track: MediaTrack(mediaOption: option))
    }
    
    // MARK: Shared
    private func select(track: MediaTrack?, inGroup group: AVMediaSelectionGroup?) {
        guard let group = group else { return }
        currentAsset?.playerItem.select(track?.mediaOption, in: group)
    }
    
    private func track(forLanguage language: String, inGroup group: AVMediaSelectionGroup?) -> AVMediaSelectionOption? {
        return group?.options.filter{ $0.displayName == language }.first
    }
}
