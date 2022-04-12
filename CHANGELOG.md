# CHANGELOG

* `3.0.10` Release - [3.0.100](#30100)
* `3.0.00` Release - [3.0.000](#30000)
* `2.6.10` Release - [2.6.100](#26100)
* `2.6.00` Release - [2.6.000](#26000)
* `2.5.00` Release - [2.5.000](#25000)
* `2.4.10` Release - [2.4.100](#24100)
* `2.4.00` Release - [2.4.000](#24000)
* `2.3.10` Release - [2.3.100](#23100)
* `2.3.00` Release - [2.3.000](#23000)
* `2.2.30` Release - [2.2.300](#22300)
* `2.2.20` Release - [2.2.200](#22200)
* `2.2.10` Release - [2.2.100](#22100)
* `2.2.00` Release - [2.2.000](#22000)
* `2.1.00` Release - [2.1.000](#21000)
* `2.0.93` Release - [2.0.930](#20930)
* `2.0.92` Release - [2.0.920](#20920)
* `2.0.91` Release - [2.0.910](#20910)
* `2.0.89` Release - [2.0.890](#20890)
* `2.0.86` Release - [2.0.860](#20860)
* `2.0.85` Release - [2.0.850](#20850)
* `2.0.81` Release - [2.0.810](#20810)
* `2.0.80` Release - [2.0.800](#20800)
* `2.0.79` Release - [2.0.790](#20790)
* `2.0.78` Release - [2.0.780](#20780)
* `0.77.x` Releases - [0.77.0](#07700)
* `0.73.x` Releases - [0.73.0](#07300)
* `0.72.x` Releases - [0.72.0](#07200)
* `0.2.x` Releases - [0.2.0](#020)
* `0.1.x` Releases - [0.1.0](#010) | [0.1.1](#011) | [0.1.2](#012) | [0.1.3](#013) | [0.1.4](#014) | [0.1.5](#015)

## 3.0.100
#### Bug Fixes
* `EMP-17988`  Bug fix : Wrong values for `seekableTimeRanges` for SSAI streams

## 3.0.000
#### Features
* `EMP-17893`  Add support to SPM & Cocoapods

## 2.6.100
#### Features
* `EMP-17850` Allow client developers to pass optional `mediaTrackId` when selecting audio / subtitles. 
* `EMP-17850` Bug fix for `id` missing on `selectedAudioTrack` & `selectedTextTrack` 

## 2.6.000
#### Features
* `EMP-17816` Allow client developers to select audio / subtitles using the `mediaTrackId` or track `title`

## 2.5.000
#### Features
* `EMP-17465` Allow client developers to to add / remove periodicTimeObserver

## 2.4.100
#### Features
* `EMP-17701` Allow client developers to set `preferredPeakBitRate`

## 2.4.000
#### Features
* `EMP-17693` Allow client developers to access `AVAssetVariant` s in the `currentAsset` 

## 2.3.100
#### Changes
* `EMP-17461` Open avplayer current player item for client developers to access

## 2.3.000
#### Changes
* Add support to use default skin when configuring the player

## 2.2.300
#### Changes
* `EMP-15210` When configuring the playerview , it will return in the `AVPlayerLayer` , developers can use this to add picture in picture mode.

## 2.2.200
#### Bug Fixes
* `EMP-15109` Fixed issue where playback did not work with iOS 12 or older devices. 

## 2.2.100
#### Changes
* `EMP-14806` Update version

## 2.2.000
#### Features
* `EMP-14376` Add support for downloads 

## 2.1.00
* Released 31 January 2020

## 2.0.122

#### Changes
* Updated the project to support Swift 4.2 and above

## 2.0.93

#### Bug Fixes
* `EMP-11909` Seeking to a unix timestamp does not work correctly when Airplay is active, the associated callbacks fail to ever return or report failure even when the seek was successful. As a workaround, the library now maps unix timestamp seek operations to zero-based stream start offsets internally.

#### Features
* `EMP-11838` Expose timed metadata for `HLSNative`

## 2.0.92

#### Changes
* Unit testing frameworks updated

## 2.0.91

#### Features
* `EMP-11766` Expanded and harmonized error reporting through analytics dispatch.

#### Changes
* Made a couple of methods related to manifest context public.
* `EMP-11747` Added ability to set `preferredMaxBitrate` on  `HLSNative` .

#### Bug Fixes
* Do not unload `MediaAsset` when playback ends at source duration to allow reuse of downloaded segments.

## 2.0.89

#### Bug Fixes
* `EMP-11603` Fixed an issue where the `onAirplayStatusChanged` callback fired multiple times for a single status update.
* `EMP-11587` Resolved an issue during *Airplay* where incoming calls caused a sound from the playback to play over the phone's ringtone.
* `EMP-11599` Bringing up the iOS Control Center no longer pauses local playback.
* `EMP-11337` Fixed an issue where repeated playback starts would fail to deliver all `events` related to that session resulting in missing or incomplete analytics sessions.
* `EMP-11623` Special treatment of subsequent playback starts during *Airplay mode* on `iOS 11.4+` due to a bug in `AVFoundation`.

#### Features
* `EMP-11667` Added functionality to trace `X-Playback-Session-Id` headers for segment and manifest requests.

#### Changes
* Extended access log data delivered on error events. 
* Updated `enabling-airplay.md` with detailing *Airplay* best practices.

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
* `EMP-10268` `HLSNative` now pauses playback on app backgrounding, except for during active *Airplay* sessions.

#### Features
* `EMP-11121` Introduced specialized logic, `AirplayHandler` to manage Airplay scenarios.

#### Changes
* `EMP-11156` Standardized error messages and introduced an `info` variable

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
