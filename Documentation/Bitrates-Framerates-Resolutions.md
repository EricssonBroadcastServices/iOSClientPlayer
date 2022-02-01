## Bitrates / Framerates & Resolutions 

Client applications using a `Tech` which adopts the `TrackSelectable` *api*, such as `HLSNative`, have access to `AVAssetVariant` s in the current Player Item using below *api* .

```Swift
let availableVariants  = player.variants
```

The *api* will return the array of `AVAssetVariant`s . This is available from **iOS 15.xx , tvOS 15.xx** and above only.

```Swift
if #available(iOS 15.0, *) {
   let _ = self.player.variants?.compactMap { variant in
   print(variant.peakBitRate)
   print(variant.videoAttributes?.nominalFrameRate)
   print(variant.videoAttributes?.presentationSize)
}
} else {
    // Fallback on earlier versions
}
```
