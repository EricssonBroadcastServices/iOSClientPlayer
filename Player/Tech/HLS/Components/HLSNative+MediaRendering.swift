//
//  HLSNative+MediaRendering.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-24.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

extension HLSNative: MediaRendering {
    /// Creates and configures the associated `CALayer` used to render the media output. This view will be added to the *user supplied* `playerView` as a sub view at `index: 0`. A strong reference to `playerView` is also established.
    ///
    /// - parameter playerView:  *User supplied* view to configure for playback rendering.
    public func configure(playerView: UIView) {
        configureRendering{
            let renderingView = PlayerView(frame: playerView.frame)
            
            renderingView.avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            renderingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            playerView.insertSubview(renderingView, at: 0)
            
            renderingView
                .leadingAnchor
                .constraint(equalTo: playerView.leadingAnchor)
                .isActive = true
            renderingView
                .topAnchor
                .constraint(equalTo: playerView.topAnchor)
                .isActive = true
            renderingView
                .rightAnchor
                .constraint(equalTo: playerView.rightAnchor)
                .isActive = true
            renderingView
                .bottomAnchor
                .constraint(equalTo: playerView.bottomAnchor)
                .isActive = true
            
            return renderingView.avPlayerLayer
        }
    }
    
    /// This method allows for advanced configuration of the playback rendering.
    ///
    /// The caller is responsible for creating, configuring and retaining the related constituents. End by returning an `AVPlayerLayer` in which the rendering should take place.
    ///
    /// - parameter callback: closure detailing the custom rendering. Must return an `AVPlayerLayer` in which the rendering will take place
    public func configureRendering(closure: () -> AVPlayerLayer) {
        let layer = closure()
        layer.player = avPlayer
    }
}
