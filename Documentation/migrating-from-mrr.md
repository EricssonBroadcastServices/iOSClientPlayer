# Migration from MRR-MC based libEMP
*EMP's iOS client* has been re-architected from the ground up using modern tools and methodologies.

The entire project is available as *open source* under the `Apache 2.0` license.

## Modular Architecture
A main goal with the new architecture has been to promote a modular approach. Customers will be able to select components fitting their requirements.

Each module center around a *core* use case, such as playback or analytics.

* [`Player`](https://github.com/EricssonBroadcastServices/iOSClientPlayer)
* [`Exposure`](https://github.com/EricssonBroadcastServices/iOSClientExposure)
* [`Analytics`](https://github.com/EricssonBroadcastServices/iOSClientAnalytics)
* [`Download`](https://github.com/EricssonBroadcastServices/iOSClientDownload)
* [`Cast`](https://github.com/EricssonBroadcastServices/iOSClientCast)
* [`Utilities`](https://github.com/EricssonBroadcastServices/iOSClientUtilities)
* [Reference app](https://github.com/EricssonBroadcastServices/iOSClientRefApp)

#### Player
`Player` contains a fully fledged media player, based on the native `AVPlayer`. It exposes key functionality such as *Playback Control*, *Fairplay* `DRM` protection, *Event publishing*, *Pluggable analytics provider* and *Airplay*. Designed and built with stability, resilience and usability in mind.

#### Exposure
`Exposure` extends `Player` with functionality enabling seamless integration with the *EMP Platform*. It provides client applications quick access to functionality such as *authentication*, *entitlement requests* and *Epg*.

#### Analytics
`Analytics` module provides an out of the box *Analytics Dispatcher* which seamlessly integrates with the EMP platform. It delivers the full *EMP* analytics specification while at the same time offering customization where needed.

Dispatch is done in real time in self contained batches. In the event of network disturbances or other errors, *payload* is encrypted and stored on device for later delivery.

## Key Differences
A major difference between the legacy *MRR-MC* based architecture and the new, modern client lies in the modular approach. Application developers can now choose components required specifically for their solution.

Small, focused concepts respecting the single responsbility principle also leads to increased testability which in turn promotes product quality. Authentication is done through the `Authenticate` endpoint, entitlement requested through the `Entitlement` endpoint and so on. Large, unwieldy constructs have been avoided whenever possible. This will allow both client application developers and contributors a greater insight into the workflow and lifecycle of the system in action.

Finally, the new modular frameworks have been written primarily in `Swift` with the expressed intention employ the language's safety and resilience advantages. Whenever possible, immutable `structs` has been used instead of mutable `classes`. Error handling has also been greatly expanded with expressive and rich subtypes.

### Modular Playback Technology
One major goal has been to decouple the playback *api* from the underlying playback technology. A tech independent architecture allows *client applications* to select their playback environment of choice or develop their own.

Restrictions on `PlaybackTech` has been kept vague by design. The contract between `Player`, the `PlaybackTech`, the `MediaContext` and associated features should largely be defined by their interaction as a complete package. As such, *tech developers* are free to make choices that feel relevant to their platform.

The `PlaybackTech` protocol should be considered a *container* for features related to rendering the media on screen. `HLSNative` provides a baseline implementation which may serve as a guide for this approach.

### Context Sensitive Playback
A second cornerstone is a *Context Sensitive* playback. `MediaContext` should encapsulate everything related to the playback context in question, such as source url, content restrictions, `Drm Agent`s and related meta data. This kind of information is often very platform dependant and specialized.

Contexts should define a `MediaSource`, usually fetched from some content managed remote source. It typically includes a media locator, content restrictions and possibly meta data regarding the source in question.

### Features as Components
The final cornerstone is *Features as Components*. `PlaybackTech` and `MediaContext` tied together in a constrained fashion delivers a focused *api* definition in which certain functionality may only be available in a specific context using a specific tech.

Features may be anything the platform defines. For example, convenience methods for starting playback of specific assets by identifiers or contract restrictions by module injection.

`ExposureContext`, as defined in the [Exposure module](https://github.com/EricssonBroadcastServices/iOSClientExposure), has a rich set of *Features* specific for the *EMP Platform*. 

### Authentication
`SessionToken` management in the old *MRR-MC* based client is tightly coupled with `EmpClient` through a semi-opaque internal reference. This token, once either aquired through *login* or explicitly set, then permeates throughout the system.

```Objective-c
EmpClient *empClient = [[EmpClient alloc] initWithHost:@"https://path.to.host" customerGrop:@"CUSTOMER" businessUnit:@"BUSINESSUNIT"];

NSError *error = nil;
BOOL success = [empClient authenticate:@"username" password:@"password" error:&error];
if (error != nil) {
    // Handle error
}

if (success) {
    // Proceed, possibly storing the token for later use
    NSString *sessionToken = [empClient authenticationToken];
...
}
```

The new architecture implements a different approach. The `SessionToken` itself is represented as a `typed object` in the form of a `struct`. It is aquired through authentication related *endpoint* integration, `Authenticate`, which has this single responsbility.

```Swift
let environment = Environment(baseUrl: "https://path.to.host", customer: "CUSTOMER", businessUnit: "BUSINESSUNIT")

Authenticate(environment: environment)
    .login(username: "username", password: "password")
    .request()
    .response{
        if let error = $0.error {
            // Handle typed ExposureError
        }

        if let sessionToken = $0.value.sessionToken {
            // Proceed, possibly storing the token for later use
        }
    }
``` 

This separated workflow enables a less tightly coupled application architecture. Client developers are no longer required to pass around a *master object*, ie `EmpClient`, to handle completely different user experiences. Login is now decoupled from playback which in turn is decoupled from entitlement requests, content discovery and so on.

As a final note, client developers implementing their own scheme for authentication and `DRM` management may completely circumvent *EMP* and integrate directly with `Player`.

### Entitlement Requests
Entitlement requests using the *MRR-MC* based library passes through `EmpClient`. This process keeps an internal reference to the requested `ImcPlayBackArgumets` for media and session management purposes.

```Objective-c
NSError *error = nil;

ImcPlayBackArguments *entitlement = [empClient playVod:@"qwerty" error:&error];
if (error != nil) {
    // Handle error
}
```

The new modular solution differs in several aspects. First, each entitlement request is a self contained entity independant of system configuration. This means outside interference is eliminated. Once a request is configured, it can technically be stored and reused later. This is particulary useful for creating base requests that can be adapted during an application's lifecycle.

While the *MRR-MC* based library depends heavily on the *current state* of a system in constant flux, the new architecture encapsulates the users intent.

```Swift
let request = Entitlement(environment: environment
                         sessionToken: sessionToken)
    .vod(assetId: "qwerty")
    .request()
    .response{
        if let error = $0.error {
            // Handle typed ExposureError
        }
            
        if let entitlement = $0.value {
            // Proceed with playback using entitlement
        }
    }
```

### Playback Configuration
Since playback in the *MRR-MC* based library is tightly coupled with the request proceedure through a similar *semi opaque* scheme linking authentication and entitlements, client developers risk a a host of configuration issues when atempting to prepare and manage *playback*.

`EmpClient` references the *current* entitlement. Configuring the `EmpManager` for playback seemingly does not reqire this entitlement but this is actuly wrong. `EmpManager` expects a `ConfigData` object which in turn should be configured, normally through the *Exposure* returned entitlement. In addition, while this config object has been supplied setting up playback, several situations during the manager's lifecycle will retrieve data from the `ImcPlayBackArguments` related to `EmpClient`.

This duality in data dependence makes the entire structure unclear and prone to user error.

```Objective-c
ConfigData *configData = [[ConfigData alloc] init];

configData.userToken = entitlement.userToken;
configData.ownerUID = entitlement.ownerUid;
configData.requestURL = entitlement.requestUrl;
configData.mediaLocator = entitlement.mediaLocator;
configData.mediaUid = entitlement.assetOrChannelId;

EmpManager *empManager = [[EmpManager alloc] initWithDelegate:aDelegate client:client withConfig: configData];

[empManager initIMC];
```

Once the initialization process has completed and either of the `IMCDidInit` or `IMCDidRegister` delegate methods are called configuration may continue.

```Objective-c
[empManager createIMCPlayer: IMC_MODE_ADAPTIVE
               withMediaUId: entitlement.mediaLocator
               withFilePath: nil
               withAppToken: entitlement.userToken
   withParentViewController: parentController
                  withAdUid: adParams
       withFullScreenLayout: YES];
```

Finally, await the `IMCDidReady` callback.

At this moment, the underlying `AzukiIMC` instance has been configured with a `ConfigData` object but `EmpClient` (and as a result `EmpManager`) refers to the previously requested `ImcPlayBackArguments`.

The new architecture changes this approach by having out of the box integration between entitlement requests through the `Exposure` module and playback using `Player`. *Context sensitive* playback architecture allows for constrained extensions with functionality specific for certain `PlaybackTech` or `MediaContext`s. For example, starting playback using `ExposureContext` with `HLSNative` as the playback technology is as simple as:

```Swift
player.startPlayback(assetId: "someEMPAssetId")
```

Configuration, rights, `DRM` and everything related to creating and managing a playback session is included in the `PlaybackEntitlement` retrieved through *Exposure*.

### Player Lifecycle
Streaming media is an interently asynchronous process. Listening and responding to playback related events is central to a smooth user experience. This is an area where, while the implementation might differ, the two clients have a similair approach.

`EmpManager` requires an `AzukiIMCDelegate` for successful event handling, supplied at initialization.  `Player` allows client applications to register event listeners in the form of `closures` for published events (defined by `PlayerEventPublisher`), making dynamic adaptation during program execution possible.

| Type | `EmpManager` | `Player` |
|-------|-----------------------|-------------------------|
| Registration | `IMCDidRegister` | n/a |
| Playback Created | n/a | `onPlaybackCreated` |
| Media Loaded | `IMCDidInit` | `onPlaybackPrepared` |
| Playback Ready | `IMCDidReady` | `onPlaybackReady` |
| Playback Started | n/a | `onPlaybackStarted` |
| Playback Paused | `IMCPlaybackState_Paused` | `onPlaybackPaused` |
| Playback Resumed | n/a | `onPlaybackResumed` |
| Playback Completed | `IMCPlaybackState_Done` | `onPlaybackCompleted` |
| Playback Aborted | n/a | `onPlaybackAborted` |
| Buffering Started | `IMCPlaybackState_BufferingStarted` | `onBufferingStarted` |
| Buffering Stopped | `IMCPlaybackState_BufferingStopped` | `onBufferingStopped` |
| Ads started | `IMCPlaybackState_AdsStarted` | n/a |
| Ads stopped  | `IMCPlaybackState_AdsCompleted` | n/a |
| Bitrate Change | `IMCBitrateDidChange` | `onBitrateChanged` |
| Program Change | `IMC_INFO_TYPE_PROGRAM_CHANGED` | `onProgramChanged`
| Duration Change | n/a | `onDurationChanged` |
| Error | `IMCDidFail:withMessage` | `onError` |

### Error Handling
The *MRR-MC* based library throws `MRR` errors catchable through `IMCDidFail:withMessage`, in addition to *EMP* errors.

Each module in the new architecture defines their own typed `Error` struct. Error codes are local to the `.framework`.

## DRM
Removing the dependency on *MRR* also means the only supported `DRM` solution right now is *FairPlay*.

Streaming `DRM` protected media assets will require *client applications* to implement their own platform specific `DrmAgent`s. In the case of *FairPlay*, this most likely involves interaction with the *Apple* supplied `AVAssetResourceLoaderDelegate` protocol.

**EMP** provides an out of the box implementation for *FairPlay* protection through the [Exposure module](https://github.com/EricssonBroadcastServices/iOSClientExposure) which integrates seamlessly with the rest of the platform.
