## Error Handling

`PlayerError` is the error type returned by the *Player Framework*. It contains both `MediaContext` and `PlaybackTech` related errors.

This means effective error handling thus requires a deeper undestanding of the overall architecture, taking both *tech*, *context* and possibly *drm* errors in consideration.

*Client applications* should register to receive errors through the `Player` method `onError(callback:)`

```Swift
myPlayer.onError{ player, source, error in
    // Handle the error
}
```

Errors associated with `PlayerError` mandates 3 properties.

* `domain` The domain of errors this specific error belongs too, for example `HLSNativeErrorDomain`
* `code` An error code specific to the `domain`
* `message` Explain what the error entails
