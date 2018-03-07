//
//  InvalidStartTimeSpec.swift
//  PlayerTests
//
//  Created by Fredrik Sjöberg on 2018-02-23.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

import Quick
import Nimble
import AVFoundation

@testable import Player

class InvalidStartTimeSpec: QuickSpec {
    
    override func spec() {
        super.spec()
        
        let currentDate = Date().millisecondsSince1970
        let hour: Int64 = 60 * 60 * 1000
        
        context("Invalid StartTime") {
            it("should return a warning if starttime is outside of seekable range") {
                let env = TestEnv()
                
                env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2))
                
                let source = Manifest(url: URL(fileURLWithPath: "file://play/.isml"))
                let conf = HLSNativeConfiguration()
                env.player.tech.startTime(atTime: currentDate - hour)
                
                var playerWarning: PlayerWarning<HLSNative<ManifestContext>,ManifestContext>? = nil
                env.player.onWarning{ player, source, warning in
                    playerWarning = warning
                }
                
                env.player.tech.load(source: source, configuration: conf)
                
                
                expect(playerWarning).toEventuallyNot(beNil(), timeout: 5)
                expect(playerWarning?.message).toEventually(contain("Invalid start time"), timeout: 5)
            }
        }
    }
}

