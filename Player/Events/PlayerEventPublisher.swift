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
    
    
    // TODO: Not a player event but on Entitlement request
    //func onHandshakeStarted(callback: @escaping (Self) -> Void) -> Self
    
    // MARK: Lifecycle
    func onCreated(callback: @escaping (Self) -> Void) -> Self
    func onInitCompleted(callback: @escaping (Self) -> Void) -> Self
    
    func onPlaybackReady(callback: @escaping (Self) -> Void) -> Self
    func onPlaybackCompleted(callback: @escaping (Self) -> Void) -> Self
    
    func onError(callback: @escaping (Self, PlayerEventError) -> Void) -> Self
    //func onHeartbeat(callback: @escaping (Self) -> Void) -> Self
    
    
    // MARK: Configuration
    
    
    // BITRATE CHANGE
    func onBitrateChanged(callback: @escaping (BitrateChangedEvent) -> Void) -> Self
    /* 
     // https://forums.developer.apple.com/thread/16569
     // http://stackoverflow.com/questions/28964053/detect-when-avplayer-switch-bit-rate
     I have had a similar problem recently. The solution felt a bit hacky but it worked as far as I saw. First I set up an observer for new Access Log notifications:
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(handleAVPlayerAccess:)
     name:AVPlayerItemNewAccessLogEntryNotification
     object:nil];
     Which calls this function. It can probably be optimised but here is the basic idea:
     
     - (void)handleAVPlayerAccess:(NSNotification *)notif {
     AVPlayerItemAccessLog *accessLog = [((AVPlayerItem *)notif.object) accessLog];
     AVPlayerItemAccessLogEvent *lastEvent = accessLog.events.lastObject;
     float lastEventNumber = lastEvent.indicatedBitrate;
     if (lastEventNumber != self.lastBitRate) {
     //Here is where you can increment a variable to keep track of the number of times you switch your bit rate.
     NSLog(@"Switch indicatedBitrate from: %f to: %f", self.lastBitRate, lastEventNumber);
     self.lastBitRate = lastEventNumber;
     }
     }
     Every time there is a new entry to the access log, it checks the last indicated bitrate from the most recent entry (the lastObject in the access log for the player item). It compares this indicated bitrate with a property that stored the the bitrate from that last change.
     */
    
    /*
     // BUFFERING
     //http://stackoverflow.com/questions/38867190/how-can-i-check-if-my-avplayer-is-buffering
     func onBufferingStarted(callback: @escaping (Self) -> Void) -> Self
     func onBufferingStopped(callback: @escaping (Self) -> Void) -> Self
     You can observe the values of your player.currentItem:
     
     playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .New, context: nil)
     playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .New, context: nil)
     playerItem.addObserver(self, forKeyPath: "playbackBufferFull", options: .New, context: nil)
     then
     
     override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
     if object is AVPlayerItem {
     switch keyPath {
     case "playbackBufferEmpty":
     // Show loader
     case "playbackLikelyToKeepUp":
     // Hide loader
     case "playbackBufferFull":
     // Hide loader
     }
     }
     }
     
     */
     
     // MARK: User Actions
     func onPlaybackStarted(callback: @escaping (Self) -> Void) -> Self
     func onPlaybackAborted(callback: @escaping (Self) -> Void) -> Self
     func onPlaybackPaused(callback: @escaping (Self) -> Void) -> Self
     func onPlaybackResumed(callback: @escaping (Self) -> Void) -> Self
     
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
