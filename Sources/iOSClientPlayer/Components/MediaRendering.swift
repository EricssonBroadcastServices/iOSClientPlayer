//
//  MediaRendering.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-10.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

/// MediaRendering defines how the player configures a *user supplied* view for playback rendering.
public protocol MediaRendering {
    /// Configures `playerView` according to specifications supplied by the adopter.
    ///
    /// - parameter playerView: *User supplied* view to configure for playback rendering.
    func configure(playerView: UIView) -> AVPlayerLayer
    
    func configureWithDefaultSkin(avPlayerViewController: AVPlayerViewController) -> AVPlayerViewController
}

extension Player where Tech: MediaRendering {
    /// Configures `playerView` according to specifications supplied by the adopter.
    /// - Pparameter playerView: *User supplied* view to configure for playback rendering.
    /// - Returns: AVPlayerLayer
    public func configure(playerView: UIView) -> AVPlayerLayer {
        return tech.configure(playerView: playerView)
    }
}

extension Player where Tech: MediaRendering {
    /// Configures `player` with default skin
    /// - Parameter avPlayerViewController: avPlayerViewController
    /// - Returns: AVPlayerViewController
    public func configureWithDefaultSkin(avPlayerViewController: AVPlayerViewController) -> AVPlayerViewController {
        return tech.configureWithDefaultSkin(avPlayerViewController: avPlayerViewController)
    }
}

