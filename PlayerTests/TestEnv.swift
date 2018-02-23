//
//  TestEnv.swift
//  PlayerTests
//
//  Created by Fredrik Sjöberg on 2018-02-20.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import AVFoundation

@testable import Player

class TestEnv {
    enum MockedError: Error {
        case generalError
    }
    
    let player: Player<HLSNative<ManifestContext>>
    init() {
        let tech = HLSNative<ManifestContext>()
        let context = ManifestContext()
        self.player = Player<HLSNative<ManifestContext>>(tech: tech, context: context)
        
        // Mock the AVPlayer
        let mockedPlayer = MockedAVPlayer()
        mockedPlayer.mockedReplaceCurrentItem = { [weak mockedPlayer] item in
            if let mockedItem = item as? MockedAVPlayerItem {
                // We try to fake the loading scheme by dispatching KVO notifications when replace is called. This should trigger .readyToPlay
                mockedItem.associatedWithPlayer = mockedPlayer
                mockedItem.mockedStatus = .readyToPlay
            }
        }
        player.tech.avPlayer = mockedPlayer
    }

    func mockAsset(callback: @escaping (Manifest, HLSNativeConfiguration) -> HLSNative<ManifestContext>.MediaAsset<Manifest>) {
        player.tech.assetGenerator = callback
    }

    func defaultAssetMock(currentDate: Int64, bufferDuration: Int64, callback: @escaping (MockedAVURLAsset, MockedAVPlayerItem) -> Void) -> (Manifest, HLSNativeConfiguration) -> HLSNative<ManifestContext>.MediaAsset<Manifest> {
        return { source, configuration in
            // MediaAsset
            let media = HLSNative<ManifestContext>.MediaAsset<Manifest>(source: source, configuration: configuration)
            
            // AVPlayerItem
            let item = MockedAVPlayerItem(mockedAVAsset: urlAsset)
            item.mockedCurrentTime = CMTime(value: 0, timescale: 1000)
            item.mockedCurrentDate = Date(milliseconds: currentDate)
            let start = CMTime(value: 0, timescale: 1000)
            let end = CMTime(value: bufferDuration, timescale: 1000)
            item.mockedSeekableTimeRanges = [NSValue(timeRange: CMTimeRange(start: start, duration: end))]
            item.mockedSeekToDate = { [unowned item] date, callback in
                if let current = item.mockedCurrentDate {
                    let diff = date.millisecondsSince1970 - current.millisecondsSince1970
                    item.mockedCurrentTime = CMTime(value: Int64(item.mockedCurrentTime.seconds*1000) + diff, timescale: 1000)
                    item.mockedCurrentDate = date
                    callback?(true)
                    return true
                }
                else {
                    callback?(false)
                    return false
                }
            }
            item.mockedSeekToTime = { _, callback in
                callback?(true)
            }
            // Transfer the bitrate settings from the real object to the mocked object
            let realPlayerItem = media.playerItem
            item.preferredPeakBitRate = realPlayerItem.preferredPeakBitRate
            media.playerItem = item
            
            // AVURLAsset
            let urlAsset = MockedAVURLAsset(url: source.url)
            urlAsset.mockedLoadValuesAsynchronously = { keys, handler in
                handler?()
            }
            urlAsset.mockedStatusOfValue = { key, outError in
                return .loaded
            }
            media.urlAsset = urlAsset
            
            callback(urlAsset, item)
            
            return media
        }
    }
    func maxBitrateMock(callback: @escaping (MockedAVURLAsset, MockedAVPlayerItem) -> Void) -> (Manifest, HLSNativeConfiguration) -> HLSNative<ManifestContext>.MediaAsset<Manifest> {
        return { source, configuration in
            // MediaAsset
            let media = HLSNative<ManifestContext>.MediaAsset<Manifest>(source: source, configuration: configuration)
            
            // AVURLAsset
            let urlAsset = MockedAVURLAsset(url: source.url)
            urlAsset.mockedLoadValuesAsynchronously = { keys, handler in
                handler?()
            }
            urlAsset.mockedStatusOfValue = { key, outError in
                return .loaded
            }
            media.urlAsset = urlAsset
            
            // AVPlayerItem
            let item = MockedAVPlayerItem(mockedAVAsset: urlAsset)
            item.mockedStatus = { [unowned item] in
                if item.associatedWithPlayer == nil {
                    return .unknown
                }
                else {
                    return .readyToPlay
                }
            }
            
            // Transfer the bitrate settings from the real object to the mocked object
            let realPlayerItem = media.playerItem
            item.preferredPeakBitRate = realPlayerItem.preferredPeakBitRate
            media.playerItem = item
            
            callback(urlAsset, item)
            
            return media
        }
    }
}
