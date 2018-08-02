# CHANGELOG

* `2.0.87` Release - [2.0.87](#2087)
* `2.0.86` Release - [2.0.86](#2086)
* `2.0.85` Release - [2.0.85](#2085)
* `2.0.81` Release - [2.0.81](#2081)
* `2.0.80` Release - [2.0.80](#2080)
* `2.0.79` Release - [2.0.79](#2079)
* `2.0.78` Release - [2.0.78](#2078)
* `0.77.x` Releases - [0.77.0](#0770)
* `0.73.x` Releases - [0.73.0](#0730)
* `0.72.x` Releases - [0.72.0](#0720)
* `0.2.x` Releases - [0.2.0](#020)
* `0.1.x` Releases - [0.1.0](#010) | [0.1.1](#011) | [0.1.2](#012) | [0.1.3](#013) | [0.1.4](#014) | [0.1.5](#015)

## 2.0.87

#### Bug Fixes
* `EMP-11603` Fixed an issue where the `onAirplayStatusChanged` callback fired multiple times for a single status update.
* `EMP-11587` Resolved an issue during *Airplay* where incoming calls caused a sound from the playback to play over the phone's ringtone. 

## 2.0.86

#### Changes
* Added a `DEBUG` feature to continuously print access and error log entries.

## 2.0.85

#### Features
* `EMP-11335` Support for delivering `Trace` events to analytics through `TraceProvider` protocol. `HLSNative` also dispatches trace events when encountering an error.
* `EMP-11356` Deallocating an `HLSNative` player which is currently preparing an asset will no longer generate an *error message*. Instead, the analytics dispatcher will send a `Trace` event in combination with an `Aborted` event.

## 2.0.81

#### Features
* `EMP-11171` `Player` now supports *tvOS*.

## 2.0.80

#### Bug Fixes
* Made sure expanded error information is forwarded when an error occurs

#### Features
* `EMP-11121` Introduced specialized logic, `AirplayHandler` to manage Airplay scenarios.

#### Changes
* `EMP-11156` Standardized error messages and introduced an `info` variable

#### Bug Fixes
* `EMP-10268` `HLSNative` now pauses playback on app backgrounding, except for during active *Airplay* sessions.

## 2.0.79

#### Bug Fixes
* `stop()` is now called when an error is thrown after playback fails to complete

## 2.0.78

#### Features
* Track selection for subtitles and audio
* Preferred track option added to `TrackSelectable`. HLSNative now tries to set a prefered language on startup
* Added seek methods taking a callback
* Preferred bitrate limit
* Additional error handling and propagation
* `EMP-11047` `ExtendedError` now exposes an error `Domain`

#### Changes
* Improved handling of bitrate and buffering events
* `EMP-11058` Refactor `StartTime` api to make it clearer

#### Bug Fixes
* `EMP-11029` Forced locale to en_GB for framework dependant date calculations
* `EMP-11035` Workaround for exposing *FairPlay* errors encountered during the validation process.
* `EMP-11045` Analytics error event delivered even if tech was deallocated
* `EMP-11071` Fixed a bug when specifying a *unix timestamp* as *startTime* on `iOS 10`.

## 0.77.0

#### Features
* `EMP-10646` `ExposureContext` exposes cached server time
* Added support for `onWarning` events
* Exposed `isMuted` and `volumne` apis

#### Changes
* `EMP-10852` API changes to `MediaPlayback.currentTime`. Property renamed to `MediaPlayback.playheadPosition` which better reflects the actual position of the playback.
* `SessionShift` protocol has been reamed to `StartTime` as that better reflects its purpose on `Tech` level.
* Improvements in how `HLSNative` handles `StartTime`.
* Event callbacks now return `Player` instead of `Tech` directly.
* Seekable and buffered timeranges now return `[CMTimeRange]`
* Several improvements to the startup and loading process for `HLSNative`

## 0.73.0

#### Changes
* `HLSNative` unloads current asset when stopped, either by user or by completing playback.
* Exposed `currentSource` property on tech

#### Bug fixes
* Fixed an issue where `onPlaybackReady` was sent twice per session.
* Make sure all observers are unregistered before clearing the current `MediaAsset`

## 0.72.0

#### Features
* `EMP-10650` Context sensitive playback introduced.
* `EMP-10649` Modular `Tech` introduced.

#### Changes
* `EMP-10334` onPlaybackScrubbed event publishing.
* Moved `FairplayError` from `Player` to `Exposure`.
* Requirements for `Xcode` set to `9.0+` and `Swift` to `4.0+`
* `EMP-10445` Streaming may now be stared with an `AVURLAsset`
* Removed internal reference to `mediaLocator`
*`EMP-10242` `AnalyticsProvider` and `playSessionId` associated with `MediaAsset` instead of `Player`

## 0.2.0
Released 5 Sep 2017

#### Features
* `EMP-9386` Playback event publishing.
* `EMP-9974` Duration, timestamp and seeking.
* `EMP-10051` Analytics provider protocol.
* `EMP-10057` Bitrate reporting, autoplay functionality and unique playsession ids.
* `EMP-10095` Multi Device Session Shift.
* `EMP-10210` API documentation finalized.
* `EMP-10212` General documentation finalized.

#### Changes
* `EMP-9951` Restructured dependency graph.
* `EMP-10066` `PlayerError` documentation improved.
* `EMP-10250` `FairplayRequester` is now optional to accomodate unencrypted streams.

#### Bug fixes
* `EMP-10061` Minor fixes to analytics publishing.

## 0.1.5
Released 12 Jun 2017

#### Features
* `EMP-9388` *Fairplay* integration for *Vod* playback.

## 0.1.4
Released 30 May 2017

No major changes

## 0.1.3
Released 12 May 2017

#### Features
* `EMP-9554` Fastlane integration for *build pipeline*.
* `EMP-9334` Basic unit testing solution.

## 0.1.2
Released 20 Apr 2017

No major changes

## 0.1.1
Released 20 Apr 2017

No major changes

## 0.1.0
Released 19 Jun 2017

#### Features
* `EMP-9391` Separation of `PoC` into module based repositories.
