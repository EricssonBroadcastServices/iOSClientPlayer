# Upgrade Guide

## 3.0.00
Project is now distributed via Swift package manager , Cocoapods & Carthage.
Unit tests have been moved to SPM tests.
Module name has been renamed from `Player` to `iOSClientPlayer`.


## 2.1.00
Project is updated to use Swift version 4.2 

## 2.0.86

### API Changes

#### HLSNative

| reason | api |
| -------- | --- |
| deprecated | `var continuouslyDispatchErrorLogEvents: Bool` |

## 2.0.81

Release `2.0.81` adds `tvOS` support by introducing a new *target*, `Player-tvOS`. Client application developers working with the *tvOS* platform should embedd the product of this target in their *tvOS* applications.

## 2.0.80

### API Changes

#### HLSNative

| reason | api |
| -------- | --- |
| deprecated | `func observeRateChanges(callback: @escaping (HLSNative<Context>, Context.Source?, Float) -> Void) -> RateObserver` |

#### RateObserver
| reason | api |
| -------- | --- |
| deprecated | `RateObserver` |


## 0.72.0 to 0.77.0

#### API changes
Several API changes where introduced to streamline with *Android* and *HTML5* platforms.

##### `MediaPlayback`
* `currentTime` renamed to `playheadPosition`


## 0.2.0 to 0.72.0
Major changes introduced to modularize *Tech* and *Playback Context*.

## Adopting 0.2.0
Please consult the [Installation](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/README.md#installation) and [Usage](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/README.md#getting-started) guides for information about this initial release.
