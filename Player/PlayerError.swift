//
//  PlayerError.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-11-27.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Generic *wrapper* for the underlying `PlaybackTech` and `MediaContext` errors.
public enum PlayerError<Tech: PlaybackTech, Context: MediaContext>: ExpandedError {
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
    /// Returns a unique message describing the error
    public var message: String {
        switch self {
        case .tech(error: let error): return error.message
        case .context(error: let error): return error.message
        }
    }
}

extension PlayerError {
    /// Returns detailed information about the error
    public var info: String? {
        switch self {
        case .tech(error: let error): return error.info
        case .context(error: let error): return error.info
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

extension PlayerError {
    /// The domain the error belongs to
    public var domain: String {
        switch self {
        case .context(error: let error): return error.domain
        case .tech(error: let error): return error.domain
        }
    }
}

/// Extension on the basic `Swift.Error` protocol adding an error code.
public protocol ExpandedError: Error {
    /// Should return the error code
    var code: Int { get }
    
    /// Should return a message describing the error
    var message: String { get }
    
    /// Should specify a domain the error belongs to
    var domain: String { get }
    
    /// Should optionally return detailed information describing the error
    var info: String? { get }
}
