//
//  MediaPlayback.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public protocol MediaPlayback {
    func play()
    func pause()
    func stop()
    
    var isPlaying: Bool { get }
    
    func seek(to timeInterval: Int64)
    
    var currentTime: Int64 { get }
    var duration: Int64 { get }
}
