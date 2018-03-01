## Responding to Playback Events
Streaming media is an inherently asychronous process. Preparation and initialisation of a *playback session* is subject to a host of outside factors, such as network avaliability, content hosting and possibly `DRM` validation. An active session must respond to environmental changes, report on playback progress and optionally deliver event specific [analytics](#analytics-how-to) data. Additionally, user interaction must be handled in a reliable and responsive way.

Finally, [error handling](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/Documentation/error-handling.md) needs to be robust.

`Player` exposes functionality allowing an interested party to register callbacks that fire when the events occur.

#### Initialisation and Preparation of playback
During the preparation, loading and finalization of a `MediaContext`, the associated `PlaybackTech` is responsible for publishing events detailing the process.

```Swift
myPlayer
    .onPlaybackCreated{ player, source in
        // Fires once the associated MediaSource has been created.
        // Playback is not ready to start at this point.
    }
    .onPlaybackPrepared{ player, source in
        // Published when the associated MediaSource completed asynchronous loading of relevant properties.
        // Playback is not ready to start at this point.
    }
    .onPlaybackReady{ player, source in
        // When this event fires starting playback is possible
        player.play()
    }
```

#### Playback events
Once playback is in progress the `Player` continuously publishes *events* related media status and user interaction.

```Swift
myPlayer
    .onPlaybackStarted{ player, source in
        // Published once the playback starts for the first time.
        // This is a one-time event.
    }
    .onPlaybackPaused{ [weak self] player, source in
        // Fires when the playback pauses for some reason
        self?.pausePlayButton.toggle(paused: true)
    }
    .onPlaybackResumed{ [weak self] player, source in
        // Fires when the playback resumes from a paused state
        self?.pausePlayButton.toggle(paused: false)
    }
    .onPlaybackAborted{ player, source in
        // Published once the player.stop() method is called.
        // This is considered a user action
    }
    .onPlaybackCompleted{ player, source in
        // Published when playback reached the end of the current media.
    }
```
Besides playback control events `Player` also publishes several status related events.

```Swift
myPlayer
    .onBitrateChanged{ [weak self] player, source, bitrate in
        // Published whenever the current bitrate changes
        self?.updateQualityIndicator(with: bitrate)
    }
    .onBufferingStarted{ player, source in
        // Fires whenever the buffer is unable to keep up with playback
    }
    .onBufferingStopped{ player, source in
        // Fires when buffering is no longer needed
    }
    .onDurationChanged{ player, source in
        // Published when the active media received an update to its duration property
    }
```

#### Error forwarding
Errors encountered throughout the lifecycle of  `Player` are published through `onError(callback:)`. For more information, please see [Error Handling](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/Documentation/error-handling.md).
