//
//  MediaPlayback.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Specifies the basic interface for user control of playback.
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
    
    /// 
    func seek(to timeInterval: Int64)
    
    var currentTime: Int64 { get }
    var duration: Int64? { get }
}
