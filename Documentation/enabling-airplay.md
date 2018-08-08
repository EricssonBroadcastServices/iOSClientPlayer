## Enabling Airplay
Airplay controls are built into the iOS *Control Center*. Client applications may optionally add an *Airplay button* to their UI by creating a `MPVolumeView` with `setShowsVolumeSlider` to `NO`.

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
4. Set the relevant `Categories` on the shared `AVAudioSession` object and make sure the session is active before playback starts

```Swift
if #available(iOS 11.0, *) {
    try audioSession.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeMoviePlayback, routeSharingPolicy: .longForm)
}
else if #available(iOS 10.0, *) {
    try audioSession.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeMoviePlayback)
}
else {
    try audioSession.setCategory(AVAudioSessionCategoryPlayback)
}
```

#### Airplay Best Practices
For the best possible user experience, client applications should reuse the `Player` object between playback calls instead of recreating it each time. This is especially important when using *Airplay mode*.

An application that supports content browsing in *Airplay mode* may experience rendering discontinuities on the external screen (Airplay screen) if a new `Player` object is created for each subsequent play request. This scenario while airplaying to an *appleTV* manifests itself by the *tvOS springboard* briefly becoming visible between the two playback sessions. Client applications are recommended to keep the `Player` object alive during content switching. New `Source` objects are easily loaded into the existing player with the current playback is still underway.

#### Known Limitations
Continuous playback in the event of an incomming phone call is only supported when using `.longForm` `Route Sharing Policy`.  For more information about adopting *Airplay 2* please see [Getting Airplay 2 Into Your App](https://developer.apple.com/documentation/avfoundation/airplay_2/getting_airplay_2_into_your_app).
