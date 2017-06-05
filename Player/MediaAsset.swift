//
//  MediaAsset.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-06-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation
import Exposure

internal class MediaAsset {
    let entitlement: PlaybackEntitlement
    fileprivate var urlAsset: AVURLAsset
    
    lazy internal var playerItem: AVPlayerItem = { [unowned self] in
        return AVPlayerItem(asset: self.urlAsset)
        }()
    
    let fairplayRequester: FairplayRequester
    
    init(entitlement: PlaybackEntitlement) throws {
        self.entitlement = entitlement
        
        fairplayRequester = FairplayRequester(entitlement: entitlement)
        
        guard let url = MediaAsset.assetUrl(from: entitlement) else {
            throw PlayerError.asset(reason: .missingMediaUrl)
        }
        
        urlAsset = AVURLAsset(url: url)
        print(urlAsset.url)
        urlAsset.resourceLoader.setDelegate(fairplayRequester,
                                            queue: DispatchQueue(label: (entitlement.playSessionId ?? "Asset") + "-fairplayLoader"))
    }
    
    
    fileprivate static func assetUrl(from entitlement: PlaybackEntitlement) -> URL? {
        // For HLS/FAIRPLAY, mediaLocator will contain the m3u8 path
        guard let m3u8 = entitlement.mediaLocator else { return nil }
        return URL(string: m3u8)
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
            DispatchQueue.main.async { [unowned self] in
                
                // Check for any issues preparing the loaded values
                let errors = keys.flatMap{ key -> Error? in
                    var error: NSError?
                    let t = self.urlAsset
                    
                    let k = keys
                    
                    guard self.urlAsset.statusOfValue(forKey: key.rawValue, error: &error) != .failed else {
                        return error!
                    }
                    return nil
                }
                
                guard errors.isEmpty else {
                    callback(.asset(reason: .failedToPrepare(errors: errors)))
                    return
                }
                
                guard self.urlAsset.isPlayable else {
                    callback(.asset(reason: .loadedButNotPlayable))
                    return
                }
                
                // Success
                callback(nil)
            }
        }
    }
}
