//
//  PlayerErrorSpec.swift
//  PlayerTests
//
//  Created by Fredrik Sjöberg on 2018-03-01.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

import Quick
import Nimble
import AVFoundation

@testable import iOSClientPlayer

class PlayerErrorSpec: QuickSpec {
    
    override func spec() {
        super.spec()
        context("Error Domain") {
            it("tech error should have tech specific domain") {
                let error = PlayerError<HLSNative<ManifestContext>,ManifestContext>.tech(error: HLSNativeError.missingMediaUrl)
                expect(error.domain).to(equal(String(describing: HLSNativeError.self)+"Domain"))
            }
            
            it("context error should have context specific domain") {
                let error = PlayerError<HLSNative<ManifestContext>,ManifestContext>.context(error: ManifestContext.Error(message: "ERROR", code: 10))
                expect(error.domain).to(equal("ManifestContextErrorDomain"))
            }
        }
    }
}
