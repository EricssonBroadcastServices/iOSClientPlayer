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
}
