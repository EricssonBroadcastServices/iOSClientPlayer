//
//  MockedAVPlayer.swift
//  PlayerTests
//
//  Created by Fredrik Sjöberg on 2018-02-20.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import AVFoundation

class MockedAVPlayer: AVPlayer {
    var mockedPause: () -> Void = { }
    override func pause() {
        mockedPause()
    }
    
    var mockedPlay: () -> Void = { }
    override func play() {
        mockedPlay()
    }
    
    var mockedReplaceCurrentItem: (AVPlayerItem?) -> Void = { _ in }
    override func replaceCurrentItem(with item: AVPlayerItem?) {
        mockedReplaceCurrentItem(item)
    }
    
    var mockedRate: () -> Float = { return 0 }
    var mockedApplyRate: (Float) -> Void = { _ in }
    override var rate: Float {
        get {
            return mockedRate()
        }
        set {
            mockedApplyRate(newValue)
        }
    }
}

class MockedAVPlayerItem: AVPlayerItem {
    weak var associatedWithPlayer: MockedAVPlayer?
    
    /// NOTE: Do not use a real url as this will force AVPlayerItem to init the loading procedure for the asset, including networking which will slow down the tests making them fail
    init(mockedAVAsset: MockedAVURLAsset) {
        super.init(asset: mockedAVAsset, automaticallyLoadedAssetKeys: nil)
    }
    
    var mockedSeekToTime: (CMTime, ((Bool) -> Void)?) -> Void = { _,_ in }
    override func seek(to time: CMTime, completionHandler: ((Bool) -> Swift.Void)? = nil) {
        mockedSeekToTime(time, completionHandler)
    }
    
    var mockedSeekToDate: (Date, ((Bool) -> Void)?) -> Bool = { _,_ in return false }
    override  func seek(to date: Date, completionHandler: ((Bool) -> Swift.Void)? = nil) -> Bool {
        return mockedSeekToDate(date, completionHandler)
    }
    
    var mockedSeekableTimeRanges: [NSValue] = []
    override var seekableTimeRanges: [NSValue] {
        return mockedSeekableTimeRanges
    }
    
    var mockedLoadedTimeRanges: [NSValue] = []
    override var loadedTimeRanges: [NSValue] {
        return mockedLoadedTimeRanges
    }
    
    var mockedCurrentTime: CMTime = CMTime(value: 0, timescale: 1000)
    override func currentTime() -> CMTime {
        return mockedCurrentTime
    }
    
    var mockedCurrentDate: Date? = nil
    override func currentDate() -> Date? {
        return mockedCurrentDate
    }
    
    var mockedDuration: CMTime = CMTime(value: 0, timescale: 1000)
    override var duration: CMTime {
        return mockedDuration
    }
    
    var mockedStatus: AVPlayerItem.Status = .unknown {
        willSet {
            self.willChangeValue(forKey: "status")
        }
        didSet {
            self.didChangeValue(forKey: "status")
        }
    }
    override var status: AVPlayerItem.Status {
        return mockedStatus
    }
    
    var mockedSelectedMediaOption: [AVMediaSelectionGroup: AVMediaSelectionOption] = [:]
    override func selectedMediaOption(in mediaSelectionGroup: AVMediaSelectionGroup) -> AVMediaSelectionOption? {
        return mockedSelectedMediaOption[mediaSelectionGroup]
    }
    
    override func select(_ mediaSelectionOption: AVMediaSelectionOption?, in mediaSelectionGroup: AVMediaSelectionGroup) {
        mockedSelectedMediaOption[mediaSelectionGroup] = mediaSelectionOption
    }
    
}

class MockedAVURLAsset: AVURLAsset {
    var mockedLoadValuesAsynchronously: ([String], (() -> Void)?) -> Void = { _,_ in }
    override func loadValuesAsynchronously(forKeys keys: [String], completionHandler handler: (() -> Void)? = nil) {
        DispatchQueue(label: "mockedLoadValuesAsynchronously", qos: DispatchQoS.utility, attributes: DispatchQueue.Attributes.concurrent).async { [weak self] in
            self?.mockedLoadValuesAsynchronously(keys, handler)
        }
    }
    
    var mockedStatusOfValue: (String, NSErrorPointer) -> AVKeyValueStatus = { _,_ in return AVKeyValueStatus.unknown }
    override func statusOfValue(forKey key: String, error outError: NSErrorPointer) -> AVKeyValueStatus {
        return mockedStatusOfValue(key, outError)
    }
    
    var mockedIsPlayable: () -> Bool = { return true }
    override var isPlayable: Bool {
        return mockedIsPlayable()
    }
    
    var mockedMediaSelectionGroup: [AVMediaCharacteristic: AVMediaSelectionGroup] = [:]
    override func mediaSelectionGroup(forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristic) -> AVMediaSelectionGroup? {
        return mockedMediaSelectionGroup[mediaCharacteristic]
    }
}

class MockedAVMediaSelectionGroup: AVMediaSelectionGroup {
    var mockedOptions: [AVMediaSelectionOption] = []
    override var options: [AVMediaSelectionOption] {
        return mockedOptions
    }
    
    var mockedDefaultOption: AVMediaSelectionOption? = nil
    override var defaultOption: AVMediaSelectionOption? {
        return mockedDefaultOption
    }
    
    var mockedAllowsEmptySelection: Bool = false
    override var allowsEmptySelection: Bool {
        print("allowsEmptySelection",mockedAllowsEmptySelection)
        return mockedAllowsEmptySelection
    }
}

class MockedAVMediaSelectionOption: AVMediaSelectionOption {
    var mockedMediaType: String = "mediaType"
    
    override var mediaType: AVMediaType {
        return AVMediaType(rawValue: mockedMediaType)
    }
    
    var mockedDisplayName: String = "Display Name"
    override var displayName: String {
        return mockedDisplayName
    }
    
    var mockedExtendedLanguageTag: String = "extendedLanguageTag"
    override var extendedLanguageTag: String {
        return mockedExtendedLanguageTag
    }
    
    var mockedTitle: String = "title"
    var title: String {
        return mockedTitle
    }
    
    var mockedMediaTrackId: Int = 0
    var mediaTrackId: Int {
        return mockedMediaTrackId
    }
}
