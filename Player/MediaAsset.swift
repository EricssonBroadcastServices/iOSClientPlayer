//
//  MediaAsset.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-06-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation

/// `MediaAsset` contains and handles all information used for loading and preparing an asset.
///
/// *Fairplay* protected media is processed by the supplied FairplayRequester.
internal class MediaAsset {
    
    /// Analytics delivery per media asset
    internal let analyticsProvider: AnalyticsProvider?
    
    /// Returns a token string uniquely identifying this playSession.
    /// Example: “E621E1F8-C36C-495A-93FC-0C247A3E6E5F”
    fileprivate(set) internal var playSessionId: String
    
    
    
    
}

