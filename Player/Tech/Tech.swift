//
//  Tech.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

open class Tech<Context: PlaybackContext>: MediaRendering, MediaPlayback {
    public required init(eventDispatcher: EventDispatcher<Context>? = nil) {
        self.eventDispatcher = eventDispatcher
    }
    
    public static var name: String {
        return String(describing: self)
    }
    
    public var name: String {
        return String(describing: type(of: self))
    }
    
    public weak var eventDispatcher: EventDispatcher<Context>?
    
    // MARK: - Tech Related
    public func load(source: Context.Source) { }
    public func prepare(callback: @escaping (Context.ContextError?) -> Void) { }
    
    // MARK: - MediaRendering
    public func configure(playerView: UIView) { }
    
    // MARK: - MediaPlayback
    public func play() { }
    public func pause() { }
    public func stop() { }
    public var isPlaying: Bool { return false }
    public func seek(to timeInterval: Int64) { }
    public var currentTime: Int64 { return 0 }
    public var duration: Int64? { return nil }
    public var currentBitrate: Double? { return nil }
    
}
