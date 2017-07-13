//
//  MediaAsset.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-06-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation


internal class MediaAsset {
    let mediaLocator: String
    fileprivate var urlAsset: AVURLAsset
    
    lazy internal var playerItem: AVPlayerItem = { [unowned self] in
        return AVPlayerItem(asset: self.urlAsset)
        }()
    
    let fairplayRequester: FairplayRequester
    
    init(mediaLocator: String, fairplayRequester: FairplayRequester) throws {
        self.mediaLocator = mediaLocator
        
        self.fairplayRequester = fairplayRequester
        
        guard let url = URL(string:mediaLocator) else {
            throw PlayerError.asset(reason: .missingMediaUrl)
        }
        
        urlAsset = AVURLAsset(url: url)
        print(urlAsset.url)
        urlAsset.resourceLoader.setDelegate(fairplayRequester,
                                            queue: DispatchQueue(label: mediaLocator + "-fairplayLoader"))
    }
    
    // MARK: Change Observation
    lazy internal var itemObserver: PlayerItemObserver = { [unowned self] in
        return PlayerItemObserver()
        }()
    
    deinit {
        itemObserver.stopObservingAll()
        itemObserver.unsubscribeAll()
    }
}

extension MediaAsset {
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
