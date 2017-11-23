//
//  Tech.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-20.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

public protocol PlaybackTech: class {
    associatedtype TechError: Error
    associatedtype Configuration
    associatedtype Context: MediaContext
    
    var eventDispatcher: EventDispatcher<Context, Self> { get }
    
//    func prepare(callback: @escaping (TechError?) -> Void)
}

