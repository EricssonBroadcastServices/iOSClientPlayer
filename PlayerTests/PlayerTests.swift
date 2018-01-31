//
//  PlayerTests.swift
//  PlayerTests
//
//  Created by Fredrik Sjöberg on 2017-04-19.
//  Copyright © 2017 emp. All rights reserved.
//

import Quick
import Nimble

@testable import Player

class TestAnalyticsProvider: AnalyticsProvider {
    
    var created = false
    var prepared = false
    var ready = false
    var started = false
    var paused = false
    var resumed = false
    var aborted = false
    var completed = false
    var errorReceived = false
    var bitrateChange: Double? = nil
    var bufferingStarted = false
    var bufferingStopped = false
    var scrubbedTo: Int64? = nil
    var durationChanged = false
    var warningReceived = false
    
    public init() { }
    
    public func onCreated<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        created = true
    }
    
    public func onPrepared<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        prepared = true
    }
    
    public func onReady<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        ready = true
    }
    
    public func onStarted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        started = true
    }
    
    public func onPaused<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        paused = true
    }
    
    public func onResumed<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        resumed = true
    }
    
    public func onAborted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        aborted = true
    }
    
    public func onCompleted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        completed = true
    }
    
    public func onError<Tech, Source, Context>(tech: Tech, source: Source?, error: PlayerError<Tech, Context>) where Tech : PlaybackTech, Source : MediaSource, Context : MediaContext {
        errorReceived = true
    }
    
    public func onBitrateChanged<Tech, Source>(tech: Tech, source: Source, bitrate: Double) where Tech : PlaybackTech, Source : MediaSource {
        bitrateChange = bitrate
    }
    
    public func onBufferingStarted<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        bufferingStarted = true
    }
    
    public func onBufferingStopped<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        bufferingStopped = true
    }
    
    public func onScrubbedTo<Tech, Source>(tech: Tech, source: Source, offset: Int64) where Tech : PlaybackTech, Source : MediaSource {
        scrubbedTo = offset
    }
    
    public func onDurationChanged<Tech, Source>(tech: Tech, source: Source) where Tech : PlaybackTech, Source : MediaSource {
        durationChanged = true
    }
    
    func onWarning<Tech, Source, Context>(tech: Tech, source: Source?, warning: PlayerWarning<Tech, Context>) where Tech : PlaybackTech, Source : MediaSource, Context : MediaContext {
        warningReceived = true
    }
}

class NativeHLSSpec: QuickSpec {
    let tech = HLSNative<ManifestContext>()
    let context = ManifestContext()
    var player: Player<HLSNative<ManifestContext>>!
    var provider: TestAnalyticsProvider!
    
    let invalidUrl = URL(fileURLWithPath: "NotFoundURL")
    
    override func spec() {
        super.spec()
        
        player = Player(tech: tech, context: context)
        player.context.analyticsGenerators.append{
            [weak self] _ in
            let prv = TestAnalyticsProvider()
            self?.provider = prv
            return prv
        }
        
        describe("Event Propagation") {
            it("Should deliver events for invalid URL") {
                var created = false
                var prepared = false
                var ready = false
                var error: PlayerError<HLSNative<ManifestContext>, ManifestContext>? = nil
                
                self.player
                    .onPlaybackCreated { tech, source in
                        created = true
                    }
                    .onPlaybackPrepared { tech, source in
                        prepared = true
                    }
                    .onPlaybackReady { tech, source in
                        ready = true
                    }
                    .onError { tech, source, readyError in
                        error = readyError
                }
                
                self.player.stream(url: self.invalidUrl)
                
                expect(created).toEventually(beTrue())
                expect(prepared).toEventually(beFalse())
                expect(ready).toEventually(beFalse())
                expect(error).toEventuallyNot(beNil())
            }
            
            it("Should forward events") {
                var prepared = false
                var ready = false
                var started = false
                var paused = false
                var resumed = false
                var aborted = false
                var completed = false
                var bitrateChange: Double? = nil
                var bufferingStarted = false
                var bufferingStopped = false
                var scrubbedTo: Int64? = nil
                var durationChanged = false
                var warningReceived = false
                
                self.player
                    .onPlaybackPrepared { tech, source in
                        prepared = true
                    }
                    .onPlaybackReady { tech, source in
                        ready = true
                    }
                    .onPlaybackStarted { tech, source in
                        started = true
                    }
                    .onPlaybackPaused { tech, source in
                        paused = true
                    }
                    .onPlaybackResumed { tech, source in
                        resumed = true
                    }
                    .onPlaybackAborted { tech, source in
                        aborted = true
                    }
                    .onPlaybackCompleted { tech, source in
                        completed = true
                    }
                    .onBitrateChanged { tech, source, bitrate in
                        bitrateChange = bitrate
                    }
                    .onBufferingStarted { tech, source in
                        bufferingStarted = true
                    }
                    .onBufferingStopped { tech, source in
                        bufferingStopped = true
                    }
                    .onPlaybackScrubbed { tech, source, offset in
                        scrubbedTo = offset
                    }
                    .onDurationChanged { tech, source in
                        durationChanged = true
                    }
                    .onWarning { player, source, warning in
                        warningReceived = true
                }
                
                
                
                let mockedManifest = Manifest(url: self.invalidUrl)
                
                self.player.tech.eventDispatcher.onPlaybackPrepared(self.player.tech, mockedManifest)
                self.player.tech.eventDispatcher.onPlaybackReady(self.player.tech, mockedManifest)
                self.player.tech.eventDispatcher.onPlaybackStarted(self.player.tech, mockedManifest)
                self.player.tech.eventDispatcher.onPlaybackPaused(self.player.tech, mockedManifest)
                self.player.tech.eventDispatcher.onPlaybackResumed(self.player.tech, mockedManifest)
                self.player.tech.eventDispatcher.onPlaybackAborted(self.player.tech, mockedManifest)
                self.player.tech.eventDispatcher.onPlaybackCompleted(self.player.tech, mockedManifest)
                self.player.tech.eventDispatcher.onBitrateChanged(self.player.tech, mockedManifest,100)
                self.player.tech.eventDispatcher.onBufferingStarted(self.player.tech, mockedManifest)
                self.player.tech.eventDispatcher.onBufferingStopped(self.player.tech, mockedManifest)
                self.player.tech.eventDispatcher.onPlaybackScrubbed(self.player.tech, mockedManifest,100)
                self.player.tech.eventDispatcher.onDurationChanged(self.player.tech, mockedManifest)
                self.player.tech.eventDispatcher.onWarning(self.player.tech, mockedManifest, PlayerWarning<HLSNative<ManifestContext>,ManifestContext>.context(warning: ManifestContext.ContextWarning(message: "warning")))
                
                expect(prepared).toEventually(beTrue())
                expect(ready).toEventually(beTrue())
                expect(started).toEventually(beTrue())
                expect(paused).toEventually(beTrue())
                expect(resumed).toEventually(beTrue())
                expect(aborted).toEventually(beTrue())
                expect(completed).toEventually(beTrue())
                expect(bitrateChange).toEventuallyNot(beNil())
                expect(bufferingStarted).toEventually(beTrue())
                expect(bufferingStopped).toEventually(beTrue())
                expect(scrubbedTo).toEventuallyNot(beNil())
                expect(durationChanged).toEventually(beTrue())
                expect(warningReceived).toEventually(beTrue())
            }
        }
        
        describe("Analytics Propagation") {
            it("Should deliver events for invalid URL") {
                self.player.stream(url: self.invalidUrl)
                
                expect(self.provider.created).toEventually(beTrue())
                expect(self.provider.prepared).toEventually(beFalse())
                expect(self.provider.ready).toEventually(beFalse())
                expect(self.provider.errorReceived).toEventuallyNot(beFalse())
            }
            
            it("Should forward events") {
                let mockedManifest = Manifest(url: self.invalidUrl)
                let provider = TestAnalyticsProvider()
                mockedManifest.analyticsConnector.providers.append(provider)
                
                mockedManifest.analyticsConnector.onCreated(tech: self.player.tech, source: mockedManifest)
                mockedManifest.analyticsConnector.onPrepared(tech: self.player.tech, source: mockedManifest)
                mockedManifest.analyticsConnector.onReady(tech: self.player.tech, source: mockedManifest)
                mockedManifest.analyticsConnector.onStarted(tech: self.player.tech, source: mockedManifest)
                mockedManifest.analyticsConnector.onPaused(tech: self.player.tech, source: mockedManifest)
                mockedManifest.analyticsConnector.onResumed(tech: self.player.tech, source: mockedManifest)
                mockedManifest.analyticsConnector.onAborted(tech: self.player.tech, source: mockedManifest)
                mockedManifest.analyticsConnector.onCompleted(tech: self.player.tech, source: mockedManifest)
                mockedManifest.analyticsConnector.onBitrateChanged(tech: self.player.tech, source: mockedManifest, bitrate: 100)
                mockedManifest.analyticsConnector.onBufferingStarted(tech: self.player.tech, source: mockedManifest)
                mockedManifest.analyticsConnector.onBufferingStopped(tech: self.player.tech, source: mockedManifest)
                mockedManifest.analyticsConnector.onScrubbedTo(tech: self.player.tech, source: mockedManifest, offset: 100)
                mockedManifest.analyticsConnector.onDurationChanged(tech: self.player.tech, source: mockedManifest)
                
                
                expect(provider.prepared).toEventually(beTrue())
                expect(provider.ready).toEventually(beTrue())
                expect(provider.started).toEventually(beTrue())
                expect(provider.paused).toEventually(beTrue())
                expect(provider.resumed).toEventually(beTrue())
                expect(provider.aborted).toEventually(beTrue())
                expect(provider.completed).toEventually(beTrue())
                expect(provider.bitrateChange).toEventuallyNot(beNil())
                expect(provider.bufferingStarted).toEventually(beTrue())
                expect(provider.bufferingStopped).toEventually(beTrue())
                expect(provider.scrubbedTo).toEventuallyNot(beNil())
                expect(provider.durationChanged).toEventually(beTrue())
            }
        }
        
        describe("StartTime") {
            it("Should adhere to default settings") {
                let startTime = self.player.startTime
                expect(startTime).to(beNil())
                
                let startPosition = self.player.startPosition
                expect(startPosition).to(beNil())
            }
            
            it("Should set startTime") {
                let specifiedOffset:Int64 = 10
                self.player.startOffset(atTime: specifiedOffset)
                expect(self.player.startTime).to(equal(specifiedOffset))
                expect(self.player.startPosition).to(beNil())
            }
            
            it("Should remove startTime") {
                let specifiedOffset:Int64 = 10
                self.player.startOffset(atTime: specifiedOffset)
                expect(self.player.startTime).to(equal(specifiedOffset))
                expect(self.player.startPosition).to(beNil())
                
                self.player.startOffset(atTime: nil)
                
                expect(self.player.startPosition).to(beNil())
                expect(self.player.startTime).to(beNil())
            }
            
            it("Should set startPosition") {
                let specifiedOffset:Int64 = 10
                self.player.startOffset(atPosition: specifiedOffset)
                expect(self.player.startPosition).to(equal(specifiedOffset))
                expect(self.player.startTime).to(beNil())
            }
            
            it("Should remove startPosition") {
                let specifiedOffset:Int64 = 10
                self.player.startOffset(atPosition: specifiedOffset)
                expect(self.player.startPosition).to(equal(specifiedOffset))
                expect(self.player.startTime).to(beNil())
                
                self.player.startOffset(atPosition: nil)
                
                expect(self.player.startPosition).to(beNil())
                expect(self.player.startTime).to(beNil())
            }
        }
    }
}
