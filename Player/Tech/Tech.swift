//
//  Tech.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

open class Tech<Context: PlaybackContext>: MediaRendering, MediaPlayback {
    public let name: String = "AbstractTech"
    
    public func configure(playerView: UIView) { }
    
    public func play() { }
    
    public func pause() { }
    
    public func stop() { }
    
    public var isPlaying: Bool { return false }
    
    public func seek(to timeInterval: Int64) { }
    
    public var currentTime: Int64 { return 0 }
    
    public var duration: Int64? { return nil }
    
    public var currentBitrate: Double? { return nil }
    
    public func load(source: Context.Source) { }
}
