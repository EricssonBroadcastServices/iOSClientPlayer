## Custom Playback Controls

*Client applications* using a `PlaybackTech` which features the `MediaRendering` *component* can build their own *view hierarchy* on top of a simple `UIView` allowing for extensive customization.

* PlayerViewController
    * View
        * PlayerView (supplied to player)
        * OverlayView

Configuring a rendering view using the build in `HLSNative` `PlaybackTech` is handled automatically by calling `configure(playerView:)`. This will insert a rendering layer as a subview to the supplied view while also setting up *Autolayout Constraints*.
