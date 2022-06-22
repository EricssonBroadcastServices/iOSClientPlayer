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
        case .preparing:
            avPlayer.play()
        case .paused:
            avPlayer.play()
        case .stopped:
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
        switch playbackState {
        case .stopped:
            unloadOnStop()
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
        if #available(iOS 10.0, *) {
            if let urlAsset = currentAsset?.urlAsset, let accetCache = urlAsset.assetCache {
                if accetCache.isPlayableOffline {
                    offlineSeek(position)
                } else {
                    seek(toPosition: position) { _ in }
                }
            } else {
                seek(toPosition: position) { _ in }
            }
            
        } else {
            // Fallback on earlier versions
            seek(toPosition: position) { _ in }
        }
    }

    /// Customised seek for offline playback to avoid video frame freeze
    /// - Parameter position: position
    fileprivate func offlineSeek(_ position: Int64) {
        avPlayer.pause()
        
        /// : NOTE : Hack : When doing fast seeking video Track seems to get lost in the avplayer item. Then either video frame freezes while audio / subtitle tracks keep playing or video become black
        /// : This seems to be an issue in AVFoundation
        ///
        // Find the currently assigned text track & remove it temporary until the seek ends
        if let playerItem = currentAsset?.playerItem,
           let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            
            mediaSelectionGroup = group
            selectedOption = playerItem.currentMediaSelection.selectedMediaOption(in: group)
            playerItem.select(nil, in: group)
        }
        
        let seekTime = position > 0 ? position : 0
        let cmTime = CMTime(value: seekTime, timescale: 1000)
        
        let item = currentAsset?.playerItem
        
        // Check if there is any previosly assigned chaseTime available
        if CMTimeCompare(cmTime, chaseTime) != 0 {
            chaseTime = cmTime;
            if !isSeekInProgress {
                if let playerStatus = item?.status {
                    trySeekToChaseTime(playerStatus)
                }
                
            }
        }
    }
    


    /// Try to do the seek
    /// - Parameter playerCurrentItemStatus: AVPlayerItem.Status
    func trySeekToChaseTime( _ playerCurrentItemStatus: AVPlayerItem.Status) {
        if playerCurrentItemStatus == .unknown {
            // wait until item becomes ready (KVO player.currentItem.status)
            print("! wait until item becomes ready! ")
            print("\n")
        }
        else if playerCurrentItemStatus == .readyToPlay {
            actuallySeekToTime() { _ in }
        }
    }
    
    
    /// Seek to Time in the player & assigned the text track back
    /// - Parameter callback: callback
    private func actuallySeekToTime(callback: @escaping (Bool) -> Void = { _ in }) {
        
        self.isSeekInProgress = true
        let seekTimeInProgress = self.chaseTime
        
        avPlayer.seek(to: self.chaseTime, toleranceBefore: .zero, toleranceAfter: .zero) {  [weak self] success in
            guard let `self` = self else {
                callback(success)
                return }
            
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if self.avPlayer.currentItem?.status == .readyToPlay {
                        
                        if let group = self.mediaSelectionGroup {
                            self.avPlayer.currentItem?.select(self.selectedOption, in: group)
                        }
                        self.avPlayer.play()
                    } else {
                        print(" Attention : player item is not ready ")
                    }
                }
                self.isSeekInProgress = false
            }
            else {
                if let playerStatus = self.currentAsset?.playerItem.status {
                    self.trySeekToChaseTime(playerStatus)
                }
            }
            
            callback(success)
        }
        
        
    }
    
    /// Use this method to seek to a specified buffer timestamp for the active media. The seek request will fail if interrupted by another seek request or by any other operation.
    ///
    /// - parameter position: in milliseconds
    /// - parameter callback: `true` if seek was successful, `false` if it was cancelled
    public func seek(toPosition position: Int64, callback: @escaping (Bool) -> Void = { _ in }) {
        let seekTime = position > 0 ? position : 0
        let cmTime = CMTime(value: seekTime, timescale: 1000)
        currentAsset?.playerItem.seek(to: cmTime) { [weak self] success in
            guard let `self` = self else { return }
            if success {
                if let source = `self`.currentAsset?.source {
                    `self`.eventDispatcher.onPlaybackScrubbed(`self`, source, seekTime)
                    source.analyticsConnector.onScrubbedTo(tech: `self`, source: source, offset: seekTime) }
            }
            callback(success)
        }
    }
    
    /// Returns the time ranges within which it is possible to seek.
    public var seekableRanges: [CMTimeRange] {
        return currentAsset?.playerItem.seekableTimeRanges.compactMap{ $0 as? CMTimeRange } ?? []
    }
    
    /// Returns time ranges in unix epoch time within which it is possible to seek.
    public var seekableTimeRanges: [CMTimeRange] {
        
        // Check for the duration as SSAI streams seems to have nil playheadTime but a valid duration
        if( playheadTime == nil && duration == nil ) {
            return seekableRanges.compactMap{ convert(timeRange: $0) }
        } else {
            return currentAsset?.playerItem.seekableTimeRanges.compactMap{ $0 as? CMTimeRange } ?? []
        }
        
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
    
    /// For playback content that is associated with a range of dates, move the playhead to point within that range.
    ///
    /// Will fail if the supplied date is outside the range or if the content is not associated with a range of dates.
    ///
    /// - parameter timeInterval: target timestamp in unix epoch time (milliseconds)
    public func seek(toTime timeInterval: Int64) {
        seek(toTime: timeInterval) { _ in }
    }
    
    fileprivate func seekToTimeWhenExternalPlayback(_ cmTime: CMTime, _ timeInterval: Int64,  callback: @escaping(Bool) -> Void) {
        currentAsset?.playerItem.seek(to: cmTime) { [weak self] success in
            guard let `self` = self else { return }
            if success {
                /// Since the seek was triggered by seeking to a unix timestamp, ie `timeInterval`, but the workaround was to use zero-based offset when seeking, trigger the callbacks with the correct value of `timeInterval` instead of the *transformed value* we used, ie `position
                if let source = self.currentAsset?.source {
                    self.eventDispatcher.onPlaybackScrubbed(self, source, timeInterval)
                    source.analyticsConnector.onScrubbedTo(tech: self, source: source, offset: timeInterval) }
            }
            callback(success)
        }
    }
    
    fileprivate func seekToTimeWhenNoExternalPlayback(_ date: Date, _ timeInterval: Int64, callback: @escaping(Bool) -> Void) {
        currentAsset?.playerItem.seek(to: date) { [weak self] success in
            guard let `self` = self else { return }
            if success {
                if let source = self.currentAsset?.source {
                    self.eventDispatcher.onPlaybackScrubbed(self, source, timeInterval)
                    source.analyticsConnector.onScrubbedTo(tech: self, source: source, offset: timeInterval) }
            }
            callback(success)
        }
    }
    
    /// For playback content that is associated with a range of dates, move the playhead to point within that range.
    ///
    /// Will fail if the supplied date is outside the range or if the content is not associated with a range of dates.
    ///
    /// - parameter timeInterval: target timestamp in unix epoch time (milliseconds)
    /// - parameter callback: `true` if seek was successful, `false` if it was cancelled
    public func seek(toTime timeInterval: Int64, callback: @escaping (Bool) -> Void) {
        /// BUGFIX: EMP-11909: Seeking to a unix timestamp does not work correctly when Airplaying, the associated callbacks which tracks success fails to fire or fire with incorrect status returned. This forces us to seek using `playheadPosition` by mapping the unix timestamp to a buffer position
        if isExternalPlaybackActive {
            /// TODO: EMP-11647: If this is an Airplay session, return `AVAudioSessionPortAirPlay`
            /// let connectedAirplayPorts = AVAudioSession.sharedInstance().currentRoute.outputs.filter{ $0.portType == AVAudioSessionPortAirPlay }
            /// return !connectedAirplayPorts.isEmpty ? AVAudioSessionPortAirPlay : nil
            
            guard let position = timeInterval.positionFrom(referenceTime: self.playheadTime, referencePosition: playheadPosition) else {
                /// When playheadTime is unavailable, the seek is considered failed.
                callback(false)
                return
            }
            let seekTime = position > 0 ? position : 0
            let cmTime = CMTime(value: seekTime, timescale: 1000)
            
            // Offline seek HACK :
            if #available(iOS 10.0, *) {
                if let urlAsset = currentAsset?.urlAsset, let accetCache = urlAsset.assetCache {
                    if accetCache.isPlayableOffline {
                        offlineSeek(position)
                    } else {
                        seekToTimeWhenExternalPlayback(cmTime, timeInterval, callback: callback)
                    }
                } else {
                    seekToTimeWhenExternalPlayback(cmTime, timeInterval, callback: callback)
                }
                
            } else {
                // Fallback on earlier versions
                seekToTimeWhenExternalPlayback(cmTime, timeInterval, callback: callback)
            }
            
            
        }
        else {
            let date = Date(milliseconds: timeInterval)
            
            // Offline seek HACK :
            if #available(iOS 10.0, *) {
                if let urlAsset = currentAsset?.urlAsset, let accetCache = urlAsset.assetCache {
                    if accetCache.isPlayableOffline {
                        
                        guard let position = timeInterval.positionFrom(referenceTime: self.playheadTime, referencePosition: playheadPosition) else {
                            /// When playheadTime is unavailable, the seek is considered failed.
                            callback(false)
                            return
                        }
                        
                        offlineSeek(position)
                        
                    } else {
                        seekToTimeWhenNoExternalPlayback(date, timeInterval, callback: callback)
                    }
                } else {
                    seekToTimeWhenNoExternalPlayback(date, timeInterval, callback: callback)
                }
                
            } else {
                // Fallback on earlier versions
                seekToTimeWhenNoExternalPlayback(date, timeInterval, callback: callback)
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
    
    
    /// Playback volume
    public var volume: Float {
        get {
            return avPlayer.volume
        }
        set {
            avPlayer.volume = newValue
        }
    }
    
    /// If the playback is muted or not
    public var isMuted: Bool {
        get {
            return avPlayer.isMuted
        }
        set {
            avPlayer.isMuted = newValue
        }
    }
    
    public var playerItem: AVPlayerItem? {
        get {
            return avPlayer.currentItem
        }
    }
}

extension HLSNative {
    /// Set the rate of playback.
    public var rate: Float {
        get {
            return avPlayer.rate
        }
        set {
            avPlayer.rate = newValue
        }
    }
}

extension HLSNative {
    fileprivate func convert(timeRange: CMTimeRange) -> CMTimeRange? {
        guard let start = relate(time: timeRange.start), let end = relate(time: timeRange.end) else { return nil }
        return CMTimeRange(start: start, end: end)
    }
    
    fileprivate func relate(time: CMTime) -> CMTime? {
        guard let currentTime = playheadTime else { return nil }
        guard time.isValid && !time.isIndefinite && !time.isNegativeInfinity && !time.isPositiveInfinity else { return nil }
        let milliseconds = Int64(time.seconds*1000)
        return CMTime(value: currentTime - playheadPosition + milliseconds, timescale: 1000)
    }
}
