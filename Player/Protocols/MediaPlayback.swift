//
//  MediaPlayback.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public protocol MediaPlayback {
    /// Starts playback
    func play()
    
    /// Pauses playback
    func pause()
    
    /// Stops playback
    func stop()
    
    /// Should return `true` if the playback rate, forward or backwards, is *non-zero*. Ie: Has the player been instructed to proceed.
    ///
    /// - note: This should not return `false` if playback has stopped due to *buffering* or similair events.
    var isPlaying: Bool { get }
    
    /// Should seek the current playback to timestamp
    ///
    /// - Parameter timeInterval: target timestamp
    func seek(to timeInterval: Int64)
    
    /// Should return the current timestamp in the playback session
    var currentTime: Int64 { get }
    
    /// Playback duration.
    ///
    /// - note: If this is a live stream, duration should be `nil`
    var duration: Int64? { get }
    
    /// The throughput required to play the stream, as advertised by the server, in *bits per second*. Should return nil if no bitrate can be reported.
    var currentBitrate: Double? { get }
    
    /// When autoplay is enabled, playback will resume as soon as the stream is loaded and prepared.
    var autoplay: Bool { get set }
}
