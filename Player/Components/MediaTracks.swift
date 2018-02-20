//
//  MediaTracks.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-02-07.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

public protocol Track {
    var name: String { get }
    var extendedLanguageTag: String? { get }
}

public protocol MediaTracks {
    associatedtype AudioTrack: Track
    var defaultAudioTrack: AudioTrack? { get }
    var audioTracks: [AudioTrack] { get }
    var selectedAudioTrack: AudioTrack? { get }
    var allowsEmptyAudioSelection: Bool { get }
    func selectAudio(track: AudioTrack?)
    func selectAudio(language: String?)
    
    associatedtype TextTrack: Track
    var defaultTextTrack: TextTrack? { get }
    var textTracks: [TextTrack] { get }
    var selectedTextTrack: TextTrack? { get }
    var allowsEmptyTextSelection: Bool { get }
    func selectText(track: TextTrack?)
    func selectText(language: String?)
}
