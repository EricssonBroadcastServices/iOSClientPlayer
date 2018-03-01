## Modular Playback Technology
One major goal when developing `Player` has been to decouple the playback *api* from the underlying playback technology and context. A tech independent architecture allows *client applications* to select their playback environment of choice or develop their own.

Restrictions on `PlaybackTech` has been kept vague by design. The contract between `Player`, the `PlaybackTech`, the `MediaContext` and associated features should largely be defined by their interaction as a complete package. As such, *tech developers* are free to make choices that feel relevant to their platform.

The `PlaybackTech` protocol should be considered a *container* for features related to rendering the media on screen. `HLSNative` provides a baseline implementation which may serve as a guide for this approach.

#### Context Sensitive Playback
A second cornerstone is a *Context Sensitive* playback. `MediaContext` should encapsulate everything related to the playback context in question, such as source url, content restrictions, `Drm Agent`s and related meta data. This kind of information is often very platform dependant and specialized.

Contexts should define a `MediaSource`, usually fetched from some content managed remote source. It typically includes a media locator, content restrictions and possibly meta data regarding the source in question.

#### Features as Components
The final cornerstone is *Features as Components*. `PlaybackTech` and `MediaContext` tied together in a constrained fashion delivers a focused *api* definition in which certain functionality may only be available in a specific context using a specific tech.

Features may be anything the platform defines. For example, convenience methods for starting playback of specific assets by identifiers or contract restrictions by module injection.

[ExposurePlayback module](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback) has a rich set of *Features* constrained to an `ExposureContext` related playback.

#### Drm Agents and FairPlay
Streaming `DRM` protected media assets will require *client applications* to implement their own platform specific `DrmAgent`s. In the case of *FairPlay*, this most likely involves interaction with the *Apple* supplied `AVAssetResourceLoaderDelegate` protocol.

**EMP** provides an out of the box implementation for *FairPlay* protection through the [ExposurePlayback module](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback) which integrates seamlessly with the rest of the platform.

### HLSNative Technology
`HLSNative` provides a base implementaiton for playback of media using the native `AVPlayer`.
The following features are supported out of the box. Please keep in mind that playback of *FairPlay* protected assets require a working fairplay server.

- [x] VoD, live and catchup streaming
- [x] FairPlay DRM protection as a plugin
- [x] Customizable playback overlay
- [x] Multi-device session shift

Under the hood, `HLSNative` is a wrapper around `KVO`, `notifications` and state management. It implements `MediaRendering`, `MediaPlayback` and `StartTime`.

#### Loading and Preparation
Loading and preparation of playback using `HLSNative` is n asynchronous process.

```Swift
avUrlAsset.loadValuesAsynchronously(forKeys: keys) {
    ...
    keys.forEach{
    let status = avUrlAsset.statusOfValue(forKey: $0, error: &error)
        // Handle status failed and/or errors
    }
}
```

For more information regarding the *async loading process* of `properties` on `AVURLAsset`s, please consult Apple's documentation on `AVAsynchronousKeyValueLoading`
Once the loading process has run its course, the asset is either ready for playback or a `HLSNativeError.failedToReady(error: underlyingError)` is thrown.
