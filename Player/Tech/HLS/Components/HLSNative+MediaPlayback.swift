//
//  HLSNative+MediaPlayback.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

/// `HLSNative` adoption of `MediaPlayback`
extension HLSNative: MediaPlayback {
    /// Starts or resumes playback.
    public func play() {
        switch playbackState {
        case .notStarted:
            avPlayer.play()
        case .paused:
            avPlayer.play()
        default:
            return
        }
    }
    
    /// Pause playback if currently active
    public func pause() {
        guard isPlaying else { return }
        avPlayer.pause()
    }
    
    /// Stops playback and unloads the currently active `Source`. This will trigger `PlaybackAborted` callbacks and analytics publication.
    public func stop() {
        // TODO: End playback? Unload resources? Leave that to user?
        switch playbackState {
        case .stopped:
            return
        default:
            avPlayer.pause()
            if let source = currentAsset?.source {
                self.eventDispatcher.onPlaybackAborted(self, source)
                source.analyticsConnector.onAborted(tech: self, source: source)
            }
            unloadOnStop()
        }
    }
    
    internal func unloadOnStop() {
        playbackState = .stopped
        avPlayer.replaceCurrentItem(with: nil)
        
        currentAsset?.itemObserver.stopObservingAll()
        currentAsset?.itemObserver.unsubscribeAll()
        currentAsset = nil
    }
    
    /// Returns true if playback has been started and the current rate is not equal to 0
    public var isPlaying: Bool {
        guard isActive else { return false }
        // TODO: How does this relate to PlaybackState? NOT good practice with the currently uncoupled behavior.
        return avPlayer.rate != 0
    }
    
    /// Returns true if playback has been started, but makes no assumtions regarding the playback rate.
    private var isActive: Bool {
        switch playbackState {
        case .paused: return true
        case .playing: return true
        default: return false
        }
    }
    
    /// Use this method to seek to a specified buffer timestamp for the active media. The seek request will fail if interrupted by another seek request or by any other operation.
    ///
    /// - parameter position: in milliseconds
    public func seek(toPosition position: Int64) {
        let seekTime = position > 0 ? position : 0
        let cmTime = CMTime(value: seekTime, timescale: 1000)
        currentAsset?.playerItem.seek(to: cmTime) { [weak self] success in
            guard let `self` = self else { return }
            if success {
                if let source = `self`.currentAsset?.source {
                    `self`.eventDispatcher.onPlaybackScrubbed(`self`, source, seekTime)
                    source.analyticsConnector.onScrubbedTo(tech: `self`, source: source, offset: seekTime) }
            }
        }
    }
    
    /// Returns the time ranges within which it is possible to seek.
    public var seekableRanges: [CMTimeRange] {
        guard let ranges = currentAsset?.playerItem.seekableTimeRanges, !ranges.isEmpty else {
            process(warning: HLSNativeWarning.seekableRangesEmpty(source: currentSource))
            return []
        }
        return ranges.flatMap{ $0 as? CMTimeRange }
    }
    
    /// Returns time ranges in unix epoch time within which it is possible to seek.
    public var seekableTimeRanges: [CMTimeRange] {
        return seekableRanges.flatMap{ convert(timeRange: $0) }
    }
    
    /// Return the playhead position timestamp using the internal buffer time reference in milliseconds
    public var playheadPosition: Int64 {
        guard let cmTime = currentAsset?.playerItem.currentTime() else { return 0 }
        return Int64(cmTime.seconds*1000)
    }
    
    /// Returns the playhead position mapped to wallclock time, in unix epoch (milliseconds)
    ///
    /// Requires a stream expressing the `EXT-X-PROGRAM-DATE-TIME` tag.
    ///
    /// Will return `nil` if playback is not mapped to any date.
    public var playheadTime: Int64? {
        return currentAsset?.playerItem.currentDate()?.millisecondsSince1970
    }
    
    #if DEBUG
    private func dateString(date: Date?, format: String) -> String? {
        guard let date = date else { return nil }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = format
        return timeFormatter.string(from: date)
    }
    
    public func logStuff() {
        currentAsset?.playerItem.accessLog()?.events.forEach{
            print($0.playbackType,$0.uri,dateString(date: $0.playbackStartDate, format: "HH:mm:ss"),$0.playbackStartOffset)
        }
    }
    #endif
    
    /// For playback content that is associated with a range of dates, move the playhead to point within that range.
    ///
    /// Will fail if the supplied date is outside the range or if the content is not associated with a range of dates.
    ///
    /// - Parameter timeInterval: target timestamp in unix epoch time (milliseconds)
    public func seek(toTime timeInterval: Int64) {
        let date = Date(milliseconds: timeInterval)
        print("seeking to",timeInterval)
        currentAsset?.playerItem.seek(to: date) { [weak self] success in
            guard let `self` = self else { return }
            if success {
                if let source = self.currentAsset?.source {
                    self.eventDispatcher.onPlaybackScrubbed(self, source, timeInterval)
                    source.analyticsConnector.onScrubbedTo(tech: self, source: source, offset: timeInterval) }
            }
        }
    }
    
    /// Returns the time ranges of the item that have been loaded.
    public var bufferedRanges: [CMTimeRange] {
        return currentAsset?.playerItem.loadedTimeRanges.flatMap{ $0 as? CMTimeRange } ?? []
    }
    
    /// Returns time ranges in unix epoch time of the loaded item
    public var bufferedTimeRanges: [CMTimeRange] {
        return bufferedRanges.flatMap{ convert(timeRange: $0) }
    }
    
    /// Returns the current playback position of the player in *milliseconds*, or `nil` if duration is infinite (live streams for example).
    public var duration: Int64? {
        guard let cmTime = currentAsset?.playerItem.duration else { return nil }
        guard !cmTime.isIndefinite else { return nil }
        return Int64(cmTime.seconds*1000)
    }
    
    /// The throughput required to play the stream, as advertised by the server, in *bits per second*. Will return nil if no bitrate can be reported.
    public var currentBitrate: Double? {
        return currentAsset?
            .playerItem
            .accessLog()?
            .events
            .last?
            .indicatedBitrate
        
    }
}

extension HLSNative {
    fileprivate func convert(timeRange: CMTimeRange) -> CMTimeRange? {
        guard let start = relate(time: timeRange.start), let end = relate(time: timeRange.end) else { return nil }
        return CMTimeRange(start: start, end: end)
    }
    
    fileprivate func relate(time: CMTime) -> CMTime? {
        guard let currentTime = playheadTime else { return nil }
        let milliseconds = Int64(time.seconds*1000)
        return CMTime(value: currentTime - playheadPosition + milliseconds, timescale: 1000)
    }
}
