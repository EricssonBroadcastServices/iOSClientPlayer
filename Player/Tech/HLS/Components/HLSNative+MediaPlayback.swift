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
    
    /// Use this method to seek to a specified time in the media timeline. The seek request will fail if interrupted by another seek request or by any other operation.
    ///
    /// - Parameter timeInterval: in milliseconds
    public func seek(to timeInterval: Int64) {
        let seekTime = timeInterval > 0 ? timeInterval : 0
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
    
    /// Returns the current playback position of the player in *milliseconds*
    public var currentTime: Int64 {
        guard let cmTime = currentAsset?.playerItem.currentTime() else { return 0 }
        return Int64(cmTime.seconds*1000)
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
