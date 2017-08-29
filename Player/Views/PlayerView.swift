//
//  PlayerView.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-10.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import AVFoundation

/// Manages rendering of media playback.
///
/// Exposes an ´AVPlayerLayer` as the view's `CALayer`. The related `Player` object performs the actual rendering through this layer.
public class PlayerView: UIView {
    /// Override the `layerClass` to expose it as an `AVPlayerLayer`
    override public class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    /// Conveniece property that provides a *typed* version of the underlying `CALayer`
    internal var avPlayerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
