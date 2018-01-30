//
//  Warning.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2018-01-30.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

/// Generic *wrapper* for the underlying `PlaybackTech` and `MediaContext` errors.
public enum PlayerWarning<Tech: PlaybackTech, Context: MediaContext>: WarningMessage {
    /// The related Tech error
    public typealias TechWarning = Tech.TechWarning
    
    /// The related Media error
    public typealias ContextWarning = Context.ContextWarning
    
    /// Wrapped `PlaybackTech` error
    case tech(warning: TechWarning)
    
    /// Wrapped `MediaContext` error
    case context(warning: ContextWarning)
}

extension PlayerWarning {
    /// The localized warning message
    public var message: String {
        switch self {
        case .tech(warning: let warning): return warning.message
        case .context(warning: let warning): return warning.message
        }
    }
}

public protocol WarningMessage {
    var message: String { get }
}
