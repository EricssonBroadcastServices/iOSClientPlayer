//
//  EventDispatcher.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public class EventDispatcher<Context: MediaContext, Tech: PlaybackTech> {
    internal(set) public var onPlaybackCreated: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackPrepared: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackReady: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackStarted: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackPaused: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackResumed: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackAborted: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackCompleted: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onError: (Tech?, Context.Source?, PlayerError<Tech, Context>) -> Void = { _,_,_  in }
    internal(set) public var onBitrateChanged: (Tech, Context.Source, Double) -> Void = { _,_,_ in }
    internal(set) public var onBufferingStarted: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onBufferingStopped: (Tech, Context.Source) -> Void = { _,_ in }
    internal(set) public var onPlaybackScrubbed: (Tech, Context.Source, Int64) -> Void = { _,_,_  in }
    internal(set) public var onDurationChanged: (Tech, Context.Source) -> Void = { _,_ in }
}
