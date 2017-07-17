//
//  PlayerEventPublisher.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public protocol PlayerEventPublisher {
    associatedtype PlayerEventError: Error
    
    // MARK: Lifecycle
    func onPlaybackCreated(callback: @escaping (Player) -> Void) -> Self
    func onPlaybackPrepared(callback: @escaping (Player) -> Void) -> Self
    func onError(callback: @escaping (Player, PlayerError) -> Void) -> Self
    
    // MARK: Configuration
    func onBitrateChanged(callback: @escaping (BitrateChangedEvent) -> Void) -> Self
    func onBufferingStarted(callback: @escaping (Player) -> Void) -> Self
    func onBufferingStopped(callback: @escaping (Player) -> Void) -> Self
    func onDurationChanged(callback: @escaping (Player) -> Void) -> Self
    
    // MARK: Playback
    func onPlaybackReady(callback: @escaping (Player) -> Void) -> Self
    func onPlaybackCompleted(callback: @escaping (Player) -> Void) -> Self
    func onPlaybackStarted(callback: @escaping (Player) -> Void) -> Self
    func onPlaybackAborted(callback: @escaping (Player) -> Void) -> Self
    func onPlaybackPaused(callback: @escaping (Player) -> Void) -> Self
    func onPlaybackResumed(callback: @escaping (Player) -> Void) -> Self
    
    
     /*func onScrubbedTo(callback: @escaping (Self) -> Void) -> Self
     func onSubtitlesEnabled(callback: @escaping (Self) -> Void) -> Self
     
     
     // MARK: Ads
     func onAdStarted(callback: @escaping (Self) -> Void)
     func onAdCompleted(callback: @escaping (Self) -> Void)
     
     
     // MARK: Program
     func onProgramChanged(callback: @escaping (Self) -> Void)
     */
    //func onDownloadStarted(callback: @escaping (Self) -> Void)
    //func onDownloadStopped(callback: @escaping (Self) -> Void)
    //func onDownloadCompleted(callback: @escaping (Self) -> Void)
    
    
    //func onDeviceInfo(callback: @escaping (Self) -> Void)
}
