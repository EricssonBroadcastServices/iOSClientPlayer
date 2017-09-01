[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Player

* [Features](#features)
* [License]()
* [Requirements](#requirements)
* [Installation](#installation)
* Usage
    - [Getting Started](#getting-started)
    - [Responding to Playback Events](#responding-to-playback-events)
    - [Enabling Airplay]()
    - [Analytics How-To]()
    - [Custom Playback Controls]()
    - [Error Handling]()
* [Release Notes](#release-notes)
* [Upgrade Guides](#upgrade-guides)
* [Contributing]()
* [FAQ](#faq)


## Features
- [x] VoD, live and catchup streaming
- [x] FairPlay DRM protection
- [x] Playback event publishing
- [x] Pluggable analytics provider
- [x] Airplay
- [x] Custom playback controls
- [x] Multi-device session shift

## Requirements

* `iOS` 9.0+
* `Swift` 3.0+
* `Xcode` 8.2.1+

## Installation

#### Carthage
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
`Player` has been designed with a minimalistic but extendable approach in mind. It is a *stand-alone* player based on `AVFoundation` with an easy to use yet powerful `API`.

#### Getting Started
The `Player` class is self-contained and will handle setup and teardown of associated resources as you load media into it. This allows you to instantiate it inside your `viewController`.

```Swift
class PlayerViewController: UIViewController {
    fileprivate let player: Player = Player()
    
    ...
}
```

Media rendering is done by an `AVPlayerLayer` attached to a subview of a *user supplied* view. This means *customized overlay controls* are easy to implement.

```Swift
player.configure(playerView: customPlayerView)
```

Loading and preparation of a stream is as simple as calling

```Swift
player.stream(url: pathToMedia)
```

Please note that streaming *FairPlay* protected media assets will require the client application implements a `FairplayRequester` to manage the `DRM` vaidation. This protocol extends the *Apple* supplied `AVAssetResourceLoaderDelegate` protocol. **EMP** provides an out of the box implementation for *FairPlay* protection through the [Exposure module](https://github.com/EricssonBroadcastServices/iOSClientExposure) which integrates seamlessly with the rest of the platform.

#### Responding to Playback Events
Streaming media over *HLS* is an inherently asychronous process. Preparation and initialisation of a *playback session* is subject to a host of outside factors, such as network avaliability, content hosting and possibly `DRM` validation. An active session must respond to environmental changes, report on playback progress and optionally deliver event specific [analytics](#analytics-how-to) data. Additionally, user interaction must be handled in a reliable and responsive way.

Finally, [error handling](error-handling) needs to be robust.

`Player` exposes a number of *interfaces* to manage these complexities. Playback and lifecycle events are described by `PlayerEventPublisher` protocol which `Player` implements. The functionality allow an interested party to register callbacks to fire when the events occur.

* `onPlaybackCreated(callback:)` will fire once the associated `MediaAsset` has been created.
```Swift
player.onPlaybackCreated{ player in
    //
}
```
Playback is not ready to start at this point.

* `onPlaybackPrepared(callback:)` fires once `MediaAsset` has completed asynchronous loading of relevant `properties`.
```Swift
player.onPlaybackPrepared{ player in
// Published when the associated MediaAsset
}
```


## Release Notes

## Upgrade Guides

## Contributing

## FAQ
