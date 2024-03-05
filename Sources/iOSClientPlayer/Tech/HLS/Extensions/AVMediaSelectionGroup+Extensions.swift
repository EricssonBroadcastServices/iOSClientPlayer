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
    var tracks: [MediaTrack] {
        let tracks = options.enumerated().map( { (index, option) in
            return (MediaTrack.init(mediaOption: option, id: index))
        })
        
        return tracks
    }
    
    // Convenience property returning the default `AVMediaSelectionOption` for the group
    var defaultTrack: MediaTrack? {
        guard let option = defaultOption else { return nil }
        
        guard let index = options.firstIndex(where:  { $0 == option }) else { return nil }
        return MediaTrack(mediaOption: option, id: index)
    }
    
    /// Convenience method selecting a track in a group
    func track(
        forLanguage language: String,
        andType mediaType: AVMediaType?,
        shouldDescribeVideo: Bool?,
        shouldTranscribeDialog: Bool?
    ) -> AVMediaSelectionOption? {
        let filteredTracks = options.filter { $0.extendedLanguageTag == language }
        let bestTrack = filteredTracks.first { track in
            let isMediaTypeMatched = mediaType.map { $0 == track.mediaType } ?? true
            let isTrackDescribingVideo = track.hasMediaCharacteristic(.describesVideoForAccessibility)
            let isDescribeVideoMatched = shouldDescribeVideo.map { isTrackDescribingVideo == $0 } ?? true
            let isTrackTranscribingDialog = track.hasMediaCharacteristic(.transcribesSpokenDialogForAccessibility)
            let isTranscribeDialogMatched = shouldTranscribeDialog.map { isTrackTranscribingDialog == $0 } ?? true
            return isMediaTypeMatched && isDescribeVideoMatched && isTranscribeDialogMatched
        }
        return bestTrack ?? filteredTracks.first
    }
    
    /// Convenience method selecting a track using `mediaTrackId`
    func track(forId mediaTrackId: Int) -> MediaTrack? {
        if let foundTrack =  tracks.filter({ $0.mediaTrackId == mediaTrackId }).first {
            return foundTrack
        } else {
            return nil
        }
    }
    
    /// Convenience method selecting a track using `title`
    func track(forTitle title: String) -> MediaTrack? {
        return tracks.filter{ $0.title == title }.first
    }
    
    /// Convenience method returning the selectedTrack `AVMediaSelectionOption`
    func selectedTrack(media: AVMediaSelectionOption) -> MediaTrack? {
        guard let index = options.firstIndex(where:  { $0 == media }) else { return nil }
        return MediaTrack(mediaOption: media, id: index)
    }
}
