//
//  HLSNative+MediaRendering.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-24.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

/// `HLSNative` adoption of `MediaRendering`
extension HLSNative: MediaRendering {
    /// Creates and configures the associated `CALayer` used to render the media output. This view will be added to the *user supplied* `playerView` as a sub view at `index: 0`. A strong reference to `playerView` is also established.
    /// - parameter playerView:  *User supplied* view to configure for playback rendering.
    /// - Returns: AVPlayerLayer
    public func configure(playerView: UIView) -> AVPlayerLayer {
       configureRendering {
            let renderingView = PlayerView(frame: playerView.frame)

            renderingView.avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            renderingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            renderingView.translatesAutoresizingMaskIntoConstraints = false
            playerView.insertSubview(renderingView, at: 0)
            
            let leading = renderingView
                .leadingAnchor
                .constraint(equalTo: playerView.leadingAnchor)
            leading.isActive = true
            leading.identifier = "PlayerView-RenderingView-Leading"
            
            let top = renderingView
                .topAnchor
                .constraint(equalTo: playerView.topAnchor)
            top.isActive = true
            top.identifier = "PlayerView-RenderingView-Top"
            
            let trailing = renderingView
                .trailingAnchor
                .constraint(equalTo: playerView.trailingAnchor)
            trailing.isActive = true
            trailing.identifier = "PlayerView-RenderingView-Trailing"
            
            let bottom = renderingView
                .bottomAnchor
                .constraint(equalTo: playerView.bottomAnchor)
            bottom.isActive = true
            bottom.identifier = "PlayerView-RenderingView-Bottom"

            return renderingView.avPlayerLayer
        }
    }
    
    /// This method allows for advanced configuration of the playback rendering.
    ///
    /// The caller is responsible for creating, configuring and retaining the related constituents. End by returning an `AVPlayerLayer` in which the rendering should take place.
    ///
    /// - parameter callback: closure detailing the custom rendering. Must return an `AVPlayerLayer` in which the rendering will take place
    
    /// - Returns: AVPlayerLayer
    public func configureRendering(closure: () -> AVPlayerLayer) -> AVPlayerLayer {
        let layer = closure()
        layer.player = avPlayer
        return layer
    }
    
    
    /// Assign the player to avPlayerViewController.player object
    /// - Parameter avPlayerViewController: avPlayerViewController
    /// - Returns: avPlayerViewController
    public func configureWithDefaultSkin(avPlayerViewController: AVPlayerViewController) -> AVPlayerViewController {
        avPlayerViewController.player = avPlayer
        return avPlayerViewController
    }
}
