//
//  MediaPlayback.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public protocol MediaPlayback: class {
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
    
    /// Should return the playhead position timestamp using the internal buffer time reference in milliseconds
    var playheadPosition: Int64 { get }
    
    /// Playback duration.
    ///
    /// - note: If this is a live stream, duration should be `nil`
    var duration: Int64? { get }
    
    /// The throughput required to play the stream, as advertised by the server, in *bits per second*. Should return nil if no bitrate can be reported.
    var currentBitrate: Double? { get }
    
    /// When autoplay is enabled, playback will resume as soon as the stream is loaded and prepared.
    var autoplay: Bool { get set }
}

extension Player where Tech: MediaPlayback {
    /// Starts playback
    public func play() {
        tech.play()
    }
    
    /// Pauses playback
    public func pause() {
        tech.pause()
    }
    
    /// Stops playback
    public func stop() {
        tech.stop()
    }
    
    /// Should return `true` if the playback rate, forward or backwards, is *non-zero*. Ie: Has the player been instructed to proceed.
    ///
    /// - note: This should not return `false` if playback has stopped due to *buffering* or similair events.
    public var isPlaying: Bool {
        return tech.isPlaying
    }
    
    /// Should seek the current playback to timestamp
    ///
    /// - Parameter timeInterval: target timestamp
    public func seek(to timeInterval: Int64) {
        tech.seek(to: timeInterval)
    }
    
    /// Should return the playhead position timestamp using the internal buffer time reference in milliseconds
    public var playheadPosition: Int64 {
        return tech.playheadPosition
    }
    
    /// Playback duration.
    ///
    /// - note: If this is a live stream, duration should be `nil`
    public var duration: Int64? {
        return tech.duration
    }
    
    /// The throughput required to play the stream, as advertised by the server, in *bits per second*. Should return nil if no bitrate can be reported.
    public var currentBitrate: Double? {
        return tech.currentBitrate
    }
    
    /// When autoplay is enabled, playback will resume as soon as the stream is loaded and prepared.
    public var autoplayEnabled: Bool {
        return tech.autoplay
    }
    
    /// When autoplay is enabled, playback will resume as soon as the stream is loaded and prepared.
    ///
    /// - parameter enabled: `true` if enabled, `false` otherwise
    /// - returns: `Self`
    @discardableResult
    public func autoplay(enabled: Bool) -> Self {
        tech.autoplay = enabled
        return self
    }
}
