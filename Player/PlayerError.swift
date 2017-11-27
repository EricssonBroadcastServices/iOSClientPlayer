//
//  PlayerError.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-27.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Generic *wrapper* for the underlying `PlaybackTech` and `MediaContext` errors.
public enum PlayerError<Tech: PlaybackTech, Context: MediaContext> {
    /// The related Tech error
    public typealias TechError = Tech.TechError
    
    /// The related Media error
    public typealias ContextError = Context.ContextError
    
    /// Wrapped `PlaybackTech` error
    case tech(error: TechError)
    
    /// Wrapped `MediaContext` error
    case context(error: ContextError)
}

extension PlayerError {
    /// The localized error description
    public var localizedDescription: String {
        switch self {
        case .tech(error: let error): return error.localizedDescription
        case .context(error: let error): return error.localizedDescription
        }
    }
}

extension PlayerError {
    /// The error code as defined in the error domain represented by the underlying error
    public var code: Int {
        switch self {
        case .tech(error: let error): return error.code
        case .context(error: let error): return error.code
        }
    }
}

/// Extension on the basic `Swift.Error` protocol adding an error code.
public protocol ErrorCode: Error {
    var code: Int { get }
}
