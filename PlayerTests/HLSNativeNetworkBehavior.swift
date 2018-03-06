//
//  HLSNativeNetworkBehavior.swift
//  PlayerTests
//
//  Created by Fredrik Sjöberg on 2018-02-22.
//  Copyright © 2018 emp. All rights reserved.
//

import Quick
import Nimble
import AVFoundation

@testable import Player

class HLSNativeNetworkBehaviorSpec: QuickSpec {
    
    override func spec() {
        super.spec()
        
        context("HLSNative NetworkBehavior") {
            it("should apply preferredMaxBitrate") {
                let env = TestEnv()
                
                let preferredBitRate: Int64 = 300000
                env.mockAsset(callback: env.maxBitrateMock { _,_ in })
                
                let manifest = Manifest(url: URL(fileURLWithPath: "file://play/.isml"))
                let configuration = HLSNativeConfiguration(drm: nil, preferredMaxBitrate: preferredBitRate)
                
                env.player.tech.load(source: manifest, configuration: configuration)
                
                expect(env.player.tech.preferredMaxBitrate).toEventually(equal(preferredBitRate))
            }
        }
    }
}

