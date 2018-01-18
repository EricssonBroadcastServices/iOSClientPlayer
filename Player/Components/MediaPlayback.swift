//
//  MediaPlayback.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

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
    
    /// Should perform seeking to the specified `position` in the player's buffer.
    ///
    /// - parameter position: target buffer position in milliseconds
    func seek(toPosition position: Int64)
    
    /// Should return time ranges within which it is possible to seek.
    var seekableRange: [CMTimeRange] { get }
    
    /// Should return time ranges in unix epoch time within which it is possible to seek.
    var seekableTimeRange: [(Int64, Int64)] { get }
    
    /// Should return the playhead position timestamp using the internal buffer time reference in milliseconds
    var playheadPosition: Int64 { get }
    
    /// Should returns the playhead position mapped current time in unix epoch (milliseconds) or `nil` if playback is not mapped to any date.
    var playheadTime: Int64? { get }
    
    /// For streams where playback is associated with a series of dates, should perform seeking to `timeInterval` as specified in relation to the current `wallclock` time.
    ///
    /// - Parameter timeInterval: target timestamp in unix epoch time (milliseconds)
    func seek(toTime timeInterval: Int64)
    
    /// Should return time ranges of the loaded item.
    var bufferedRange: [CMTimeRange] { get }
    
    /// Should return time ranges in unix epoch time of the loaded item
    var bufferedTimeRange: [(Int64, Int64)] { get }
    
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
    
    /// Should return time ranges within which it is possible to seek.
    public var seekableRange: [CMTimeRange] {
        return tech.seekableRange
    }
    
    /// Should return time ranges in unix epoch time within which it is possible to seek.
    public var seekableTimeRange: [(Int64, Int64)] {
        return tech.seekableTimeRange
    }
    
    /// Should seek the specified `position` in the player's buffer.
    ///
    /// - Parameter timeInterval: target timestamp
    public func seek(toPosition position: Int64) {
        tech.seek(toPosition: position)
    }
    
    /// Should return the playhead position timestamp using the internal buffer time reference in milliseconds
    public var playheadPosition: Int64 {
        return tech.playheadPosition
    }
    
    /// Should returns the playhead position mapped to wallclock time in unix epoch (milliseconds) or `nil` if playback is not mapped to any date.
    public var playheadTime: Int64? {
        return tech.playheadTime
    }
    
    /// For streams where playback is associated with a series of dates, should perform seeking to `timeInterval` as specified in relation to the current `wallclock` time.
    ///
    /// - Parameter timeInterval: target timestamp in unix epoch time (milliseconds)
    public func seek(toTime timeInterval: Int64) {
        tech.seek(toTime: timeInterval)
    }
    
    /// Playback duration.
    ///
    /// - note: If this is a live stream, duration should be `nil`
    public var duration: Int64? {
        return tech.duration
    }
    
    /// Should return the time ranges of the item that have been loaded.
    public var bufferedRange: [CMTimeRange] {
        return tech.bufferedRange
    }
    
    /// Should return time ranges in unix epoch time of the loaded item
    public var bufferedTimeRange: [(Int64, Int64)] {
        return tech.bufferedTimeRange
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
