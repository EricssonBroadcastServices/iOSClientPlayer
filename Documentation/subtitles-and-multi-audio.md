## Subtitles and Multi-Audio

Client applications using a `Tech` which adopts the `TrackSelectable` *api*, such as `HLSNative`, have access to a set of methods and properties enabling selection of *subtitles* and *audio tracks*.

The *api* allows for easy selection of tracks by supplying a *RFC 4646* compliant language tag

```Swift
player.selectText(language: "fr")
player.selectAudio(language: "en")
```

or developers can pass the `mediaTrackId` or the `title` of the track to select subtitles or audios. 

```Swift
// Selecting Audio 
let availableAudioTracks = player.audioTracks
let firstAudioTrack = availableAudioTracks.first

if let mediaTrackId = firstAudioTrack.mediaTrackId {
    self.player.selectAudio(mediaTrackId: mediaTrackId )
}

self.player.selectAudio(title: firstAudioTrack.title)

// Selecting Subtitles 
let availableSubtitleTracks = player.textTracks
let firstSubTrack = availableSubtitleTracks.first

if let mediaTrackId = firstSubTrack.mediaTrackId {
    self.player.selectText(mediaTrackId: mediaTrackId )
}

self.player.selectText(title: firstSubTrack.title)

```

In addition, the protocol defines a set of inspection properties through which client applications can gain insight into the available, selected and default tracks.

`HLSNative` expresses this through the `MediaGroup` and `MediaTrack` `struct`s.

`MediaGroup` encapsulates a certain aspect of track selection, such as *audio* or *subtitles*. Each group can be queried for information regarding the following properties:

* default track
* all available tracks
* currently selected track
* and if the group allows empty selection

What constitutes a default track is normally encoded in the stream manifest.

`MediaTrack`s themselves contains a `name` which is a string suitable for display purposes, a `type` such as *subtitle* , `title` which is equivalent to the *NAME* tag for the track in the hls playlist, `mediaTrackId` which is a unique id to differentiate the tracks & finally the `extendedLanguageTag` which is a *RFC 4646* compliant language tag.

```Swift
let availableAudioTracks = player.audioTracks
let selectedAudioTrack = player.selectedAudioTrack

let title =  selectedAudioTrack.title 
let trackId = selectedAudioTrack.mediaTrackId

```

Turning off a track is as simple as specifying a `nil` selection

```Swift
player.selectText(track: nil)
```
