//
//  HLSNativeTrackSelectableSpec.swift
//  PlayerTests
//
//  Created by Fredrik Sjöberg on 2018-02-20.
//  Copyright © 2018 emp. All rights reserved.
//

import Quick
import Nimble
import AVFoundation

@testable import Player

class HLSNativeTrackSelectableSpec: QuickSpec {
    
    override func spec() {
        super.spec()
        
        context("HLSNative TrackSelecable") {
            let currentDate = Date().millisecondsSince1970
            let hour: Int64 = 60 * 60 * 1000
            
            let options: (String) -> [MockedAVMediaSelectionOption] = {
                let en = MockedAVMediaSelectionOption()
                en.mockedDisplayName = "English"
                en.mockedExtendedLanguageTag = "en"
                en.mockedMediaType = $0
                
                let sv = MockedAVMediaSelectionOption()
                sv.mockedDisplayName = "Swedish"
                sv.mockedExtendedLanguageTag = "sv"
                sv.mockedMediaType = $0
                
                return [en, sv]
            }
            
            context("Audio") {
                it("should return audioGroup") {
                    let env = TestEnv()
                    
                    env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2) { urlAsset, playerItem in
                        let audibleGroup = MockedAVMediaSelectionGroup()
                        let audibleOptions = options("audio")
                        audibleGroup.mockedAllowsEmptySelection = false
                        audibleGroup.mockedOptions = audibleOptions
                        audibleGroup.mockedDefaultOption = audibleOptions.first
                        
                        urlAsset.mockedMediaSelectionGroup[AVMediaCharacteristic.audible] = audibleGroup
                        
                        playerItem.mockedSelectedMediaOption[audibleGroup] = audibleOptions.first
                    })
                    
                    env.player.stream(url: URL(fileURLWithPath: "http://www.example.com"))
                    
                    expect(env.player.tech.audioGroup).toEventuallyNot(beNil())
                    expect(env.player.tech.audioGroup?.allowsEmptySelection).toEventually(beFalse())
                    expect(env.player.tech.audioGroup?.defaultTrack?.name).toEventually(equal("English"))
                    expect(env.player.tech.audioGroup?.defaultTrack?.extendedLanguageTag).toEventually(equal("en"))
                    expect(env.player.tech.audioGroup?.defaultTrack?.type).toEventually(equal("audio"))
                    
                    expect(env.player.tech.audioGroup?.tracks.count).toEventually(equal(2))
                    
                    expect(env.player.tech.audioGroup?.selectedTrack?.name).toEventually(equal("English"))
                    expect(env.player.tech.audioGroup?.selectedTrack?.extendedLanguageTag).toEventually(equal("en"))
                    expect(env.player.tech.audioGroup?.selectedTrack?.type).toEventually(equal("audio"))

                    expect(env.player.tech.audioGroup?.tracks.last).toEventuallyNot(beNil())
                    expect(env.player.tech.audioGroup?.tracks.last?.name).toEventually(equal("Swedish"))
                    expect(env.player.tech.audioGroup?.tracks.last?.extendedLanguageTag).toEventually(equal("sv"))
                    expect(env.player.tech.audioGroup?.tracks.last?.type).toEventually(equal("audio"))
                }
                
                it("HLSNative should expose same functionality as MediaGroup") {
                    let env = TestEnv()
                    
                    env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2) { urlAsset, playerItem in
                        let audibleGroup = MockedAVMediaSelectionGroup()
                        let audibleOptions = options("audio")
                        audibleGroup.mockedAllowsEmptySelection = false
                        audibleGroup.mockedOptions = audibleOptions
                        audibleGroup.mockedDefaultOption = audibleOptions.first
                        
                        urlAsset.mockedMediaSelectionGroup[AVMediaCharacteristic.audible] = audibleGroup
                        
                        playerItem.mockedSelectedMediaOption[audibleGroup] = audibleOptions.first
                    })
                    
                    env.player.stream(url: URL(fileURLWithPath: "http://www.example.com"))
                    
                    expect(env.player.tech.allowsEmptyAudioSelection).toEventually(beFalse())
                    expect(env.player.tech.defaultAudioTrack?.name).toEventually(equal("English"))
                    expect(env.player.tech.defaultAudioTrack?.extendedLanguageTag).toEventually(equal("en"))
                    expect(env.player.tech.defaultAudioTrack?.type).toEventually(equal("audio"))
                    
                    expect(env.player.tech.audioGroup?.tracks.count).toEventually(equal(2))
                    
                    expect(env.player.tech.audioGroup?.selectedTrack?.name).toEventually(equal("English"))
                    expect(env.player.tech.audioGroup?.selectedTrack?.extendedLanguageTag).toEventually(equal("en"))
                    expect(env.player.tech.audioGroup?.selectedTrack?.type).toEventually(equal("audio"))
                    
                    expect(env.player.tech.audioGroup?.tracks.last).toEventuallyNot(beNil())
                    expect(env.player.tech.audioGroup?.tracks.last?.name).toEventually(equal("Swedish"))
                    expect(env.player.tech.audioGroup?.tracks.last?.extendedLanguageTag).toEventually(equal("sv"))
                    expect(env.player.tech.audioGroup?.tracks.last?.type).toEventually(equal("audio"))
                }
                
                it("should select by track") {
                    let env = TestEnv()
                    
                    env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2) { urlAsset, playerItem in
                        let audibleGroup = MockedAVMediaSelectionGroup()
                        let audibleOptions = options("audio")
                        audibleGroup.mockedAllowsEmptySelection = false
                        audibleGroup.mockedOptions = audibleOptions
                        audibleGroup.mockedDefaultOption = audibleOptions.first
                        
                        urlAsset.mockedMediaSelectionGroup[AVMediaCharacteristic.audible] = audibleGroup
                        
                        playerItem.mockedSelectedMediaOption[audibleGroup] = audibleOptions.first
                    })
                    
                    env.player.onPlaybackReady{ player, source in
                        
                        let media = MockedAVMediaSelectionOption()
                        media.mockedDisplayName = "Swedish"
                        media.mockedExtendedLanguageTag = "sv"
                        media.mockedMediaType = "audio"
                        
                        let track = MediaTrack(mediaOption: media)
                        
                        player.tech.selectAudio(track: track)
                    }
                    
                    env.player.stream(url: URL(fileURLWithPath: "http://www.example.com"))
                    
                    expect(env.player.tech.selectedAudioTrack?.name).toEventually(equal("Swedish"))
                    expect(env.player.tech.selectedAudioTrack?.extendedLanguageTag).toEventually(equal("sv"))
                    expect(env.player.tech.selectedAudioTrack?.type).toEventually(equal("audio"))
                }
                
                it("should select by language") {
                    let env = TestEnv()
                    
                    env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2) { urlAsset, playerItem in
                        let audibleGroup = MockedAVMediaSelectionGroup()
                        let audibleOptions = options("audio")
                        audibleGroup.mockedAllowsEmptySelection = false
                        audibleGroup.mockedOptions = audibleOptions
                        audibleGroup.mockedDefaultOption = audibleOptions.first
                        
                        urlAsset.mockedMediaSelectionGroup[AVMediaCharacteristic.audible] = audibleGroup
                        
                        playerItem.mockedSelectedMediaOption[audibleGroup] = audibleOptions.first
                    })
                    
                    env.player.onPlaybackReady{ player, source in
                        player.tech.selectAudio(language: "sv")
                    }
                    
                    env.player.stream(url: URL(fileURLWithPath: "http://www.example.com"))
                    
                    expect(env.player.tech.selectedAudioTrack?.name).toEventually(equal("Swedish"))
                    expect(env.player.tech.selectedAudioTrack?.extendedLanguageTag).toEventually(equal("sv"))
                    expect(env.player.tech.selectedAudioTrack?.type).toEventually(equal("audio"))
                }
                
                it("should remove selection by specifying nil language") {
                    let env = TestEnv()
                    
                    env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2) { urlAsset, playerItem in
                        let audibleGroup = MockedAVMediaSelectionGroup()
                        let audibleOptions = options("audio")
                        audibleGroup.mockedAllowsEmptySelection = false
                        audibleGroup.mockedOptions = audibleOptions
                        audibleGroup.mockedDefaultOption = audibleOptions.first
                        
                        urlAsset.mockedMediaSelectionGroup[AVMediaCharacteristic.audible] = audibleGroup
                        
                        playerItem.mockedSelectedMediaOption[audibleGroup] = audibleOptions.first
                    })
                    
                    env.player.onPlaybackReady{ player, source in
                        player.tech.selectAudio(language: nil)
                    }
                    
                    env.player.stream(url: URL(fileURLWithPath: "http://www.example.com"))
                    
                    expect(env.player.tech.selectedTextTrack?.name).toEventually(beNil())
                    expect(env.player.tech.selectedTextTrack?.extendedLanguageTag).toEventually(beNil())
                    expect(env.player.tech.selectedTextTrack?.type).toEventually(beNil())
                }
            }
            
            context("Text") {
                it("Should return textGroup") {
                    let env = TestEnv()
                    
                    env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2) { urlAsset, playerItem in
                        let legibleGroup = MockedAVMediaSelectionGroup()
                        let legibleOptions = options("subtitle")
                        legibleGroup.mockedAllowsEmptySelection = true
                        legibleGroup.mockedOptions = legibleOptions
                        legibleGroup.mockedDefaultOption = legibleOptions.last
                        
                        urlAsset.mockedMediaSelectionGroup[AVMediaCharacteristic.legible] = legibleGroup
                        
                        playerItem.mockedSelectedMediaOption[legibleGroup] = legibleOptions.first
                    })
                    
                    env.player.stream(url: URL(fileURLWithPath: "http://www.example.com"))
                    
                    expect(env.player.tech.textGroup).toEventuallyNot(beNil(), timeout: 4)
                    expect(env.player.tech.textGroup?.allowsEmptySelection).toEventually(beTrue())
                    expect(env.player.tech.textGroup?.defaultTrack?.name).toEventually(equal("Swedish"))
                    expect(env.player.tech.textGroup?.defaultTrack?.extendedLanguageTag).toEventually(equal("sv"))
                    expect(env.player.tech.textGroup?.defaultTrack?.type).toEventually(equal("subtitle"))
                    
                    expect(env.player.tech.textGroup?.tracks.count).toEventually(equal(2))
                    
                    expect(env.player.tech.textGroup?.selectedTrack?.name).toEventually(equal("English"))
                    expect(env.player.tech.textGroup?.selectedTrack?.extendedLanguageTag).toEventually(equal("en"))
                    expect(env.player.tech.textGroup?.selectedTrack?.type).toEventually(equal("subtitle"))

                    expect(env.player.tech.textGroup?.tracks.first).toEventuallyNot(beNil())
                    expect(env.player.tech.textGroup?.tracks.first?.name).toEventually(equal("English"))
                    expect(env.player.tech.textGroup?.tracks.first?.extendedLanguageTag).toEventually(equal("en"))
                    expect(env.player.tech.textGroup?.tracks.first?.type).toEventually(equal("subtitle"))
                }
                
                it("HLSNative should expose same functionality as MediaGroup") {
                    let env = TestEnv()
                    
                    env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2) { urlAsset, playerItem in
                        let legibleGroup = MockedAVMediaSelectionGroup()
                        let legibleOptions = options("subtitle")
                        legibleGroup.mockedAllowsEmptySelection = true
                        legibleGroup.mockedOptions = legibleOptions
                        legibleGroup.mockedDefaultOption = legibleOptions.last
                        
                        urlAsset.mockedMediaSelectionGroup[AVMediaCharacteristic.legible] = legibleGroup
                        
                        playerItem.mockedSelectedMediaOption[legibleGroup] = legibleOptions.first
                    })
                    
                    env.player.stream(url: URL(fileURLWithPath: "http://www.example.com"))
                    
                    expect(env.player.tech.textGroup).toEventuallyNot(beNil(), timeout: 4)
                    expect(env.player.tech.allowsEmptyTextSelection).toEventually(beTrue())
                    expect(env.player.tech.defaultTextTrack?.name).toEventually(equal("Swedish"))
                    expect(env.player.tech.defaultTextTrack?.extendedLanguageTag).toEventually(equal("sv"))
                    expect(env.player.tech.defaultTextTrack?.type).toEventually(equal("subtitle"))
                    
                    expect(env.player.tech.textTracks.count).toEventually(equal(2))
                    
                    expect(env.player.tech.selectedTextTrack?.name).toEventually(equal("English"))
                    expect(env.player.tech.selectedTextTrack?.extendedLanguageTag).toEventually(equal("en"))
                    expect(env.player.tech.selectedTextTrack?.type).toEventually(equal("subtitle"))
                    
                    expect(env.player.tech.textTracks.first).toEventuallyNot(beNil())
                    expect(env.player.tech.textTracks.first?.name).toEventually(equal("English"))
                    expect(env.player.tech.textTracks.first?.extendedLanguageTag).toEventually(equal("en"))
                    expect(env.player.tech.textTracks.first?.type).toEventually(equal("subtitle"))
                }
                
                
                it("should select by track") {
                    let env = TestEnv()
                    
                    env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2) { urlAsset, playerItem in
                        let audibleGroup = MockedAVMediaSelectionGroup()
                        let audibleOptions = options("subtitle")
                        audibleGroup.mockedAllowsEmptySelection = false
                        audibleGroup.mockedOptions = audibleOptions
                        audibleGroup.mockedDefaultOption = audibleOptions.first
                        
                        urlAsset.mockedMediaSelectionGroup[AVMediaCharacteristic.legible] = audibleGroup
                        
                        playerItem.mockedSelectedMediaOption[audibleGroup] = audibleOptions.first
                    })
                    
                    env.player.onPlaybackReady{ player, source in
                        
                        let media = MockedAVMediaSelectionOption()
                        media.mockedDisplayName = "Swedish"
                        media.mockedExtendedLanguageTag = "sv"
                        media.mockedMediaType = "subtitle"
                        
                        let track = MediaTrack(mediaOption: media)
                        
                        player.tech.selectText(track: track)
                    }
                    
                    env.player.stream(url: URL(fileURLWithPath: "http://www.example.com"))
                    
                    expect(env.player.tech.selectedTextTrack?.name).toEventually(equal("Swedish"))
                    expect(env.player.tech.selectedTextTrack?.extendedLanguageTag).toEventually(equal("sv"))
                    expect(env.player.tech.selectedTextTrack?.type).toEventually(equal("subtitle"))
                }
                
                it("should select by language") {
                    let env = TestEnv()
                    
                    env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2) { urlAsset, playerItem in
                        let audibleGroup = MockedAVMediaSelectionGroup()
                        let audibleOptions = options("subtitle")
                        audibleGroup.mockedAllowsEmptySelection = false
                        audibleGroup.mockedOptions = audibleOptions
                        audibleGroup.mockedDefaultOption = audibleOptions.first
                        
                        urlAsset.mockedMediaSelectionGroup[AVMediaCharacteristic.legible] = audibleGroup
                        
                        playerItem.mockedSelectedMediaOption[audibleGroup] = audibleOptions.first
                    })
                    
                    env.player.onPlaybackReady{ player, source in
                        player.tech.selectText(language: "sv")
                    }
                    
                    env.player.stream(url: URL(fileURLWithPath: "http://www.example.com"))
                    
                    expect(env.player.tech.selectedTextTrack?.name).toEventually(equal("Swedish"))
                    expect(env.player.tech.selectedTextTrack?.extendedLanguageTag).toEventually(equal("sv"))
                    expect(env.player.tech.selectedTextTrack?.type).toEventually(equal("subtitle"))
                }
                
                it("should remove selection by specifying nil language") {
                    let env = TestEnv()
                    
                    env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2) { urlAsset, playerItem in
                        let audibleGroup = MockedAVMediaSelectionGroup()
                        let audibleOptions = options("subtitle")
                        audibleGroup.mockedAllowsEmptySelection = false
                        audibleGroup.mockedOptions = audibleOptions
                        audibleGroup.mockedDefaultOption = audibleOptions.first
                        
                        urlAsset.mockedMediaSelectionGroup[AVMediaCharacteristic.legible] = audibleGroup
                        
                        playerItem.mockedSelectedMediaOption[audibleGroup] = audibleOptions.first
                    })
                    
                    env.player.onPlaybackReady{ player, source in
                        player.tech.selectText(language: nil)
                    }
                    
                    env.player.stream(url: URL(fileURLWithPath: "http://www.example.com"))
                    
                    expect(env.player.tech.selectedTextTrack?.name).toEventually(beNil())
                    expect(env.player.tech.selectedTextTrack?.extendedLanguageTag).toEventually(beNil())
                    expect(env.player.tech.selectedTextTrack?.type).toEventually(beNil())
                }
            }
        }
    }
}
