//
//  PlayerView.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-10.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import AVFoundation

public class PlayerView: UIView {
    override public class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var avPlayerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
