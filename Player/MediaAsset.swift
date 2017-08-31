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
    /// Media locator represents a path to where the media is located.
    ///
    /// - note: This will probably be removed
    internal let mediaLocator: String
    
    /// Specifies the asset which is about to be loaded.
    fileprivate var urlAsset: AVURLAsset
    
    /// AVPlayerItem models the timing and presentation state of an asset played by an AVPlayer object. It provides the interface to seek to various times in the media, determine its presentation size, identify its current time, and much more.
    lazy internal var playerItem: AVPlayerItem = { [unowned self] in
        return AVPlayerItem(asset: self.urlAsset)
        }()
    
    /// Loads, configures and validates *Fairplay* `DRM` protected assets.
    internal let fairplayRequester: FairplayRequester?
    
    /// Creates the media asset
    ///
    /// - parameter mediaLocator: *Path* to where the media is located
    /// - parameter fairplayRequester: Will handle *Fairplay* `DRM`
    /// - throws: `PlayerError` if configuration is faulty or incomplete.
    internal init(mediaLocator: String, fairplayRequester: FairplayRequester? = nil) throws {
        self.mediaLocator = mediaLocator
        
        self.fairplayRequester = fairplayRequester
        
        guard let url = URL(string:mediaLocator) else {
            throw PlayerError.asset(reason: .missingMediaUrl)
        }
        
        urlAsset = AVURLAsset(url: url)
        print(urlAsset.url)
        if fairplayRequester != nil {
            urlAsset.resourceLoader.setDelegate(fairplayRequester,
                                                queue: DispatchQueue(label: mediaLocator + "-fairplayLoader"))
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
