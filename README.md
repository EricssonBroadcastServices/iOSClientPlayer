[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Player

* [Features](#features)
* [License](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/LICENSE)
* [Requirements](#requirements)
* [Installation](#installation)
* Usage
    - [Getting Started](#getting-started)
    - [Modular Playback Technology](#modular-playback-technology)
    - [Context Sensitive Playback](#context-sensitive-playback)
    - [Features as Components](#features-as-components)
    - [Drm Agents and FairPlay](#drm-agents-and-fairplay)
    - [Responding to Playback Events](#responding-to-playback-events)
    - [Enabling Airplay](#enabling-airplay)
    - [Analytics How-To](#analytics-how-to)
    - [Custom Playback Controls](#custom-playback-controls)
    - [Error Handling](#error-handling)
* [Release Notes](#release-notes)
* [Upgrade Guides](#upgrade-guides)
* [Roadmap](#roadmap)
* [Contributing](#contributing)


## Features

- [x] Modular `PlaybackTech`
- [x] Context sensitive playback
- [x] Features as components
- [x] Customizable `DrmAgent`s
- [x] Pluggable analytics
- [x] Playback event publishing
- [x] Custom playback controls
- [x] Airplay


## Requirements

* `iOS` 9.0+
* `Swift` 4.0+
* `Xcode` 9.0+

## Installation

### Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependency graph without interfering with your `Xcode` project setup. `CI` integration through [fastlane](https://github.com/fastlane/fastlane) is also available.

Install *Carthage* through [Homebrew](https://brew.sh) by performing the following commands:

```sh
$ brew update
$ brew install carthage
```

Once *Carthage* has been installed, you need to create a `Cartfile` which specifies your dependencies. Please consult the [artifacts](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md) documentation for in-depth information about `Cartfile`s and the other artifacts created by *Carthage*.

```sh
github "EricssonBroadcastServices/iOSClientPlayer"
```

Running `carthage update` will fetch your dependencies and place them in `/Carthage/Checkouts`. You either build the `.framework`s and drag them in your `Xcode` or attach the fetched projects to your `Xcode workspace`.

Finaly, make sure you add the `.framework`s to your targets *General -> Embedded Binaries* section. 

## Usage
`Player` has been designed with a minimalistic but extendable approach in mind. It is a *stand-alone* playback protocol designed to use modular playback technologies and context sensitive playback sources. *Features as components* allow `PlaybackTech` or `MediaContext` specific functionality when so desired. This flexible yet powerful model allows targeted behavior tailored for client specific needs.
The framework also contains a  `PlaybackTech` implementation, `HLSNative`, supporting playback using the built in `AVPlayer`.

### Getting Started
The `Player` class acts as an *api provider* granting *client applications* access to tailored, self-contained playback experience. Instantiation is done by defining the `PlaybackTech` and `MediaContext` to use. The following examples will use `HLSNative<ManifestContext>` to demonstrate the proceedure

```Swift
class PlayerViewController: UIViewController {
    fileprivate let context = ManifestContext()
    fileprivate let tech = HLSNative<ManifestContext>()
    fileprivate var player: Player<HLSNative<ManifestContext>>!
    
    override func viewDidLoad() {
        player = Player(tech: tech, context: context)
    }
}
```

Media rendering can be done using `UIView` as defined by a *Component* called `MediaRendering`. It allows *client applications* to supply a `view` in which the media will be rendered under custom overlay controls.

```Swift
player.configure(playerView: customPlayerView)
```

Loading and preparation of a stream using the built in `HLSNative` `Tech` takes place in a multi-step process.
First, the `ManifestContext` supplied to `Player` on initialisation defines the context in which source media exists. This `MediaContext` is responsible for producing a `MediaSource` when asked to do so. Our example case only relies on a valid media `URL` but more complex contexts likely involve fetching assets from a remote location or processing data on device.

```Swift
let manifest = context.manifest(from: someUrl)
```

The next step involves *loading* this context generated `MediaSource` into the selected `PlaybackTech`. In general, the `Tech` in question is completely agnostic when it comes to the media source loaded. This means the source is responsible for producing the `Tech`-specific `Configuration` type that encapsulate the information required for configuration.

In the example case with  `ManifestContext`, `Manifest` adopts `HLSNativeConfigurable`. This allows us to define a set of *constrained extensions* on `Player` in accordance with the *Features as components* approach.

```Swift
extension Player where Tech == HLSNative<ManifestContext> {
    func stream(url: URL) {
        let manifest = context.manifest(from: url)
        tech.load(source: manifest)
    }
}
```

### Modular Playback Technology
`HLSNative`
- [x] VoD, live and catchup streaming
- [x] FairPlay DRM protection
- [x] Multi-device session shift

### Context Sensitive Playback

### Features as Components

### Drm Agents and FairPlay

Please note that streaming *FairPlay* protected media assets will require the client application implements a `FairplayRequester` to manage the `DRM` vaidation. This protocol extends the *Apple* supplied `AVAssetResourceLoaderDelegate` protocol. **EMP** provides an out of the box implementation for *FairPlay* protection through the [Exposure module](https://github.com/EricssonBroadcastServices/iOSClientExposure) which integrates seamlessly with the rest of the platform.

### Responding to Playback Events
Streaming media is an inherently asychronous process. Preparation and initialisation of a *playback session* is subject to a host of outside factors, such as network avaliability, content hosting and possibly `DRM` validation. An active session must respond to environmental changes, report on playback progress and optionally deliver event specific [analytics](#analytics-how-to) data. Additionally, user interaction must be handled in a reliable and responsive way.

Finally, [error handling](#error-handling) needs to be robust.

`Player` exposes a number of *interfaces* to manage these complexities. Playback and lifecycle events are described by `PlayerEventPublisher` protocol which `Player` implements. The functionality allow an interested party to register callbacks to fire when the events occur.

#### Initialisation and Preparation of playback
During the initialisation process `Player` creates and configures a `MediaAsset` to manage the media. If the asset is protected by *FairPlay* `DRM` the associated `FairplayRequester` is also attached.

Subsequent steps load and prepare the *stream*.

```Swift
myPlayer
    .onPlaybackCreated{ tech, source in
        // Fires once the associated MediaAsset has been created.
        // Playback is not ready to start at this point.
    }
    .onPlaybackPrepared{ tech, source in
        // Published when the associated MediaAsset completed asynchronous loading of relevant properties.
        // Internally, no KVO or Notifications have been registered yet at this point.
        // Playback is not ready to start at this point.
    }
    .onPlaybackReady{ tech, source in
        // When this event fires starting playback is possible
        player.play()
    }
```

#### Playback events
Once playback is in progress the `Player` continuously publishes *events* related media status and user interaction.

```Swift
myPlayer
    .onPlaybackStarted{ tech, source in
        // Published once the playback starts for the first time.
        // This is a one-time event.
    }
    .onPlaybackPaused{ [weak self] tech, source in
        // Fires when the playback pauses for some reason
        self?.pausePlayButton.toggle(paused: true)
    }
    .onPlaybackResumed{ [weak self] tech, source in
        // Fires when the playback resumes from a paused state
        self?.pausePlayButton.toggle(paused: false)
    }
    .onPlaybackAborted{ tech, source in
        // Published once the player.stop() method is called.
        // This is considered a user action
    }
    .onPlaybackCompleted{ tech, source in
        // Published when playback reached the end of the current media.
    }
```
Besides playback control events `Player` also publishes several status related events.

```Swift
myPlayer
    .onBitrateChanged{ [weak self] tech, source, bitrate in
        // Published whenever the current bitrate changes
        self?.updateQualityIndicator(with: bitrate)
    }
    .onBufferingStarted{ tech, source in
        // Fires whenever the buffer is unable to keep up with playback
    }
    .onBufferingStopped{ tech, source in
        // Fires when buffering is no longer needed
    }
    .onDurationChanged{ tech, source in
        // Published when the active media received an update to its duration property
    }
```

#### Error forwarding
Errors encountered throughout the lifecycle of  `Player` are published through `onError(callback:)`. For more information, please see [Error Handling](#error-handling).

### Enabling Airplay
To enable airplay the client application needs to add an *Airplay* button to the playback controls (pause, play, etc). This is done by adding an `MPVolumeView` with `setShowsVolumeSlider` to `NO`.

```Swift
let airplayButton = MPVolumeView()
airplayButton.showsVolumeSlider = false
view.addSubview(airplayButton)
```

#### Background Modes
Client applications who wish to continue *Airplay* once a user locks their screen or navigates from the app need to set the relevant `Capabilities` in their *Xcode* project.

1. Select the relevant `Target` for your app in your *Xcode* project
2. Under `Capabilities`, locate `Background Modes`
3. Make sure `Audio, AirPlay, and Picture in Picture` is selected

### Analytics How-To
`Player` continuously broadcasts a set of analytics related events throughout a playback session. In order to respond to these, client applications should implement the  `AnalyticsProvider` protocol.

*EMP* provides a complete, out of the box [Analytics module](https://github.com/EricssonBroadcastServices/iOSClientAnalytics) which integrates seamlessly with the rest of the platform.

### Custom Playback Controls
Rendering is performed in an `AVPlayerLayer` attached to a specialized `PlayerView`. Client applications may attach this view in a *view hierarchy* of their choice, allowing for extensive customization.

* PlayerViewController
    * View
        * PlayerView  (with `AVPlayerLayer`)
        * OverlayView

Configuring a rendering view can be handled automatically by calling `configure(playerView:)`. This will insert a rendering layer as a subview to the supplied view while also setting up *Autolayout Constraints*.

```Swift
class PlayerViewController: UIViewController {
    fileprivate let player: Player = Player()
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var overlayView: UIView!
    ...
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.configure(playerView: playerView)
    }
}
```

An increased control over configuration and management of the rendering view can be achived by using  `configureRendering(closure: () -> AVPlayerLayer)`. This method allows client applications full control and responsbility over the associated `AVPlayerLayer`.

### Error Handling
`PlayerError` is the error type returned by the *Player Framework*. It can manifest both as errors *native* to the framework and *nested errors* specific to underlying frameworks.  Effective error handling thus requires a deeper undestanding of the overall architecture, for example how to deal with `AVFoundation` errors when loading and preparing `AVPlayerItem`s.

Client applications should register to receive errors through the `Player` method `onError(callback:)`, as defined by the `PlayerEventPublisher` protocol.

```Swift
myPlayer.onError{ tech, source, error in
    // Handle the error
}
```

#### Asset Errors
`AssetError`s related to media asset preparation may be caused by loading or configuration issues. Several culprits exist. The most common cause is failure to complete the *asynchronous loading* of media related `properties`  on the underlying `AVURLAsset`.

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

Once the loading process has run its course, the asset is either ready for playback or a `AssetError.failedToReady(error: underlyingError)` is thrown.

## Release Notes
Release specific changes can be found in the [CHANGELOG](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/CHANGELOG.md).

## Upgrade Guides
The procedure to apply when upgrading from one version to another depends on what solution your client application has chosen to integrate `Player`.

Major changes between releases will be documented with special [Upgrade Guides](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/UPGRADE_GUIDE.md).

### Carthage
Updating your dependencies is done by running  `carthage update` with the relevant *options*, such as `--use-submodules`, depending on your project setup. For more information regarding dependency management with `Carthage` please consult their [documentation](https://github.com/Carthage/Carthage/blob/master/README.md) or run `carthage help`.

## Roadmap
No formalised roadmap has yet been established but an extensive backlog of possible items exist. The following represent an unordered *wish list* and is subject to change.

- [ ] Contract Restrictions
- [ ] Expanded Event Publishing
- [ ] tvOS Support
- [ ] Comprehensive Unit testing

## Contributing
