## Analytics How-To

Each `PlaybackTech` is responsible for continuously broadcasting a set of analytics related events throughout an active playback session. These events are processed per session by an associated `AnalyticsConnector` which can modulate, filter and modify this data before delivery to a set of `AnalyticsProvider`s.  *Client applications* are encouraged to implement their own  `AnalyticsProvider`s suitable to their infrastructure.

*EMP* provides a complete, out of the box Analytics module through [ExposurePlayback](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback) which integrates seamlessly with the rest of the platform.

```Swift
class PlayerViewController: UIViewController {
    fileprivate let player: Player<HLSNative<ManifestContext>>!

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var overlayView: UIView!
    ...

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.configure(playerView: playerView)
    }
}
```
