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
    /// Specifies the asset which is about to be loaded.
    fileprivate var urlAsset: AVURLAsset
    
    /// AVPlayerItem models the timing and presentation state of an asset played by an AVPlayer object. It provides the interface to seek to various times in the media, determine its presentation size, identify its current time, and much more.
    lazy internal var playerItem: AVPlayerItem = { [unowned self] in
        return AVPlayerItem(asset: self.urlAsset)
        }()
    
    /// Loads, configures and validates *Fairplay* `DRM` protected assets.
    internal let fairplayRequester: FairplayRequester?
    
    /// Analytics delivery per media asset
    internal let analyticsProvider: AnalyticsProvider?
    
    /// Returns a token string uniquely identifying this playSession.
    /// Example: “E621E1F8-C36C-495A-93FC-0C247A3E6E5F”
    fileprivate(set) internal var playSessionId: String
    
    
    /// Returns a string created from the UUID, such as "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
    ///
    /// A unique playSessionId should be generated for each new playSession.
    fileprivate static func generatePlaySessionId() -> String {
        return UUID().uuidString
    }
    
    /// Creates the media asset
    ///
    /// - parameter mediaLocator: *Path* to where the media is located
    /// - parameter fairplayRequester: Will handle *Fairplay* `DRM`
    /// - parameter analyticsProvider: Delivers analytics per media asset
    /// - throws: `PlayerError` if configuration is faulty or incomplete.
    internal init(mediaLocator: String, fairplayRequester: FairplayRequester? = nil, analyticsProvider: AnalyticsProvider? = nil, playSessionId: String? = nil) throws {
        self.fairplayRequester = fairplayRequester
        self.analyticsProvider = analyticsProvider
        self.playSessionId = playSessionId ?? MediaAsset.generatePlaySessionId()
        
        guard let url = URL(string:mediaLocator) else {
            throw PlayerError.asset(reason: .missingMediaUrl)
        }
        
        urlAsset = AVURLAsset(url: url)
        if fairplayRequester != nil {
            urlAsset.resourceLoader.setDelegate(fairplayRequester,
                                                queue: DispatchQueue(label: mediaLocator + "-fairplayLoader"))
        }
    }
    
    internal init(avUrlAsset: AVURLAsset, fairplayRequester: FairplayRequester? = nil, analyticsProvider: AnalyticsProvider? = nil, playSessionId: String? = nil) {
        self.fairplayRequester = fairplayRequester
        self.analyticsProvider = analyticsProvider
        self.playSessionId = playSessionId ?? MediaAsset.generatePlaySessionId()
        
        urlAsset = avUrlAsset
        if fairplayRequester != nil {
            urlAsset.resourceLoader.setDelegate(fairplayRequester,
                                                queue: DispatchQueue(label: avUrlAsset.url.relativePath + "-fairplayLoader"))
        }
    }
    
    // MARK: Change Observation
    /// Wrapper observing changes to the underlying `AVPlayerItem`
    lazy internal var itemObserver: PlayerItemObserver = { [unowned self] in
        return PlayerItemObserver()
        }()
    
    deinit {
        itemObserver.stopObservingAll()
        itemObserver.unsubscribeAll()
    }
}

extension MediaAsset {
    /// Prepares and loads media `properties` relevant to playback. This is an asynchronous process.
    ///
    /// There are several reasons why the loading process may fail. Failure to prepare `properties` of `AVURLAsset` is discussed in Apple's documentation detailing `AVAsynchronousKeyValueLoading`. 
    ///
    /// - parameter keys: *Property keys* to preload
    /// - parameter callback: Fires once the async loading is complete, or finishes with an error.
    internal func prepare(loading keys: [AVAsset.LoadableKeys], callback: @escaping (PlayerError?) -> Void) {
        urlAsset.loadValuesAsynchronously(forKeys: keys.rawValues) {
            DispatchQueue.main.async { [weak self] in
                
                // Check for any issues preparing the loaded values
                let errors = keys.flatMap{ key -> Error? in
                    var error: NSError?
                    guard self?.urlAsset.statusOfValue(forKey: key.rawValue, error: &error) != .failed else {
                        return error!
                    }
                    return nil
                }
                
                guard errors.isEmpty else {
                    callback(.asset(reason: .failedToPrepare(errors: errors)))
                    return
                }
                
                guard let isPlayable = self?.urlAsset.isPlayable, isPlayable else {
                    callback(.asset(reason: .loadedButNotPlayable))
                    return
                }
                
                // Success
                callback(nil)
            }
        }
    }
}
