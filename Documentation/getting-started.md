## Getting Started

`Player` has been designed with a minimalistic but extendable approach in mind. It is a *stand-alone* playback protocol designed to use modular playback technologies and context sensitive playback sources. *Features as components* allow `PlaybackTech` or `MediaContext` specific functionality when so desired. This flexible yet powerful model allows targeted behavior tailored for client specific needs.
The framework also contains a  `PlaybackTech` implementation, `HLSNative`, supporting playback using the built in `AVPlayer`.

The `Player` class acts as an *api provider* granting *client applications* access to tailored, self-contained playback experience. Instantiation is done by defining the `PlaybackTech` and `MediaContext` to use. The following examples will use `HLSNative<ManifestContext>` to demonstrate the proceedure

```Swift
class PlayerViewController: UIViewController {
    fileprivate let context = ManifestContext()
    fileprivate let tech = HLSNative<ManifestContext>()
    fileprivate var player: Player<HLSNative<ManifestContext>>!

    override func viewDidLoad() {
        player = Player(tech: player, context: context)
    }
}
```

Media rendering can be done using `UIView` as defined by a *Component* called `MediaRendering`. It allows *client applications* to supply a `view` in which the media will be rendered under custom overlay controls.

```Swift
player.configure(playerView: customPlayerView)
```

Loading and preparation of a stream using the built in `HLSNative` `Tech` takes place in a multi-step process.
First, the `ManifestContext` supplied to `Player` on initialisation defines the context in which source media exists. This `MediaContext` is responsible for producing a `MediaSource` when asked to do so. Our example case only relies on a valid media `URL` but more complex contexts likely involve fetching assets from a remote location or processing data on device.

```Swift
let manifest = context.manifest(from: someUrl)
```

The next step involves *loading* this context generated `MediaSource` into the selected `PlaybackTech`. In general, the `Tech` in question is completely agnostic when it comes to the media source loaded. This means the source is responsible for producing the `Tech`-specific `Configuration` type that encapsulate the information required for configuration.

```Swift
extension Player where Tech == HLSNative<ManifestContext> {
    func stream(url: URL) {
        let manifest = context.manifest(from: url)
        let configuration = HLSNativeConfiguration(drm: manifest.fairplayRequester)
        tech.load(source: manifest, configuration: configuration)
    }
}
```
