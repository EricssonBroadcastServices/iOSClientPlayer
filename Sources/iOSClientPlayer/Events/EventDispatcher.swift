//
//  EventDispatcher.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

/// Dispatch class used by the player to trigger registered event callbacks.
///
/// `Tech` implementations should trigger the related events where appropriate.
public class EventDispatcher<Context: MediaContext, Tech: PlaybackTech> {
    
    /// Should be triggered when the requested media is created, but not yet loaded
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onPlaybackCreated: (Tech, Context.Source) -> Void = { _,_ in }
    
    /// Should be triggered once the requested media is loaded
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onPlaybackPrepared: (Tech, Context.Source) -> Void = { _,_ in }
    
    /// Should be triggered when playback is ready to start
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onPlaybackReady: (Tech, Context.Source) -> Void = { _,_ in }
    
    /// Should be triggered once the playback starts for the first time
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onPlaybackStarted: (Tech, Context.Source) -> Void = { _,_ in }
    
    /// Should be triggered by the user pausing playback
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onPlaybackPaused: (Tech, Context.Source) -> Void = { _,_ in }
    
    /// Should be triggered by the user resuming playback
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onPlaybackResumed: (Tech, Context.Source) -> Void = { _,_ in }
    
    /// Should be triggered by the user aborting playback
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onPlaybackAborted: (Tech, Context.Source) -> Void = { _,_ in }
    
    /// Should be triggered once playback reaches end of stream
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onPlaybackCompleted: (Tech, Context.Source) -> Void = { _,_ in }
    
    /// Should be triggered if an error during its lifetime
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    /// - parameter error: `Error` encountered
    internal(set) public var onError: (Tech?, Context.Source?, PlayerError<Tech, Context>) -> Void = { _,_,_  in }
    
    /// Should be triggered when the bitrate changes
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    /// - parameter bitrate: New bitrate
    internal(set) public var onBitrateChanged: (Tech, Context.Source, Double) -> Void = { _,_,_ in }
    
    /// Should be triggered when buffering is required
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onBufferingStarted: (Tech, Context.Source) -> Void = { _,_ in }
    
    /// Should be triggered when buffering finished
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onBufferingStopped: (Tech, Context.Source) -> Void = { _,_ in }
    
    /// Should be triggered by the user seeking to time
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    /// - parameter offset: New offset
    internal(set) public var onPlaybackScrubbed: (Tech, Context.Source, Int64) -> Void = { _,_,_  in }
    
    /// Should be triggered when the duration of `source` changes
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onDurationChanged: (Tech, Context.Source) -> Void = { _,_ in }
    
    /// Should be triggered when a *warning* for either the `Tech` or the `Context` occurs.
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    /// - parameter warning: `Warning` encountered
    internal(set) public var onWarning: (Tech, Context.Source?, PlayerWarning<Tech, Context>) -> Void = { _,_,_ in }
    
    /// Should be triggered when a *DateRangeMetadataChanged*.
    internal(set) public var onDateRangeMetadataChanged: (_ metaDataGroup: [AVDateRangeMetadataGroup], _ indexesOfNewGroups: IndexSet, _ indexesOfModifiedGroups: IndexSet ) -> Void = { _, _, _  in }
    
    /// Should be triggered when the *GracePeriodStarted*.
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onGracePeriodStarted: (Tech, Context.Source?) -> Void = { _,_ in }

    /// Should be triggered when the *GracePeriodEnded*.
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onGracePeriodEnded: (Tech, Context.Source?) -> Void = { _,_ in }
    
    
    /// Should be triggered when the *AppDidEnterBackground*.
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onAppDidEnterBackground: (Tech, Context.Source?) -> Void = { _,_ in }
    
    
    /// Should be triggered when the *AppDidEnterForeground*.
    ///
    /// - parameter tech: `Tech` broadcasting the event
    /// - parameter source: `MediaSource` causing the event
    internal(set) public var onAppDidEnterForeground: (Tech, Context.Source?) -> Void = { _,_ in }
}
