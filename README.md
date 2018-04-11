[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Player

* [Features](#features)
* [License](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/LICENSE)
* [Requirements](#requirements)
* [Installation](#installation)
* Documentation
    - [Getting Started](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/Documentation/getting-started.md)
    - [Modular Playback Technology](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/Documentation/modular-playback-technology.md)
    - [Responding to Playback Events](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/Documentation/responding-to-playback-events.md)
    - [Enabling Airplay](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/Documentation/enabling-airplay.md)
    - [Analytics How-To](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/Documentation/analytics-how-to.md)
    - [Custom Playback Controls](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/Documentation/custom-playback-controls.md)
    - [Error Handling](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/Documentation/error-handling.md)
    - [Subtitles and Multi-Audio](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/Documentation/subtitles-and-multi-audio.md)
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
- [x] Track selection
- [x] Preferred bitrate limitation


## Requirements

* `iOS` 9.0+
* `tvOS` 9.0+
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

## Release Notes
Release specific changes can be found in the [CHANGELOG](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/CHANGELOG.md).

## Upgrade Guides
The procedure to apply when upgrading from one version to another depends on what solution your client application has chosen to integrate `Player`.

Major changes between releases will be documented with special [Upgrade Guides](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/UPGRADE_GUIDE.md).

### Carthage
Updating your dependencies is done by running  `carthage update` with the relevant *options*, such as `--use-submodules`, depending on your project setup. For more information regarding dependency management with `Carthage` please consult their [documentation](https://github.com/Carthage/Carthage/blob/master/README.md) or run `carthage help`.

## Roadmap
No formalised roadmap has yet been established but an extensive backlog of possible items exist. The following represent an unordered *wish list* and is subject to change.

- [ ] tvOS Support

## Contributing
