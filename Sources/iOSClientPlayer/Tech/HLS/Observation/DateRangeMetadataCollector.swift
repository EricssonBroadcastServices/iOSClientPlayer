//
//  DateRangeMetadataCollector.swift
//  Player
//
//  Created by Udaya Sri Senarathne on 2022-08-22.
//

import Foundation
import AVFoundation


/// AVDateRangeMetadataGroup Requester
public protocol DateMetaDataRequester:  AVPlayerItemMetadataCollectorPushDelegate {
    func setDelegate(_ metadataCollector: AVPlayerItemMetadataCollector)
}

/// AVDateRangeMetadataGroup Parser
public protocol DateMetaDataParser {
    func dateMetaDataDidCollect(dateRangeMetadataGroups: [AVDateRangeMetadataGroup] )
}


class DateRangeMetadataCollector : NSObject, DateMetaDataRequester {
    
    weak var metadataCollector: AVPlayerItemMetadataCollector?
    var parserDelegate: DateMetaDataParser?
    
    /// Set the delegate for metadataCollector
    /// - Parameter metadataCollector: `metadataCollector` AVPlayerItemMetadataCollector
    public func setDelegate(_ metadataCollector: AVPlayerItemMetadataCollector) {
        self.metadataCollector = metadataCollector
        self.metadataCollector?.setDelegate(self, queue: .main)
    }
    
    
    /// Delegate method for collecting AVDateRangeMetadataGroups
    /// - Parameters:
    ///   - metadataCollector: AVPlayerItemMetadataCollector
    ///   - metadataGroups: AVDateRangeMetadataGroup
    ///   - indexesOfNewGroups: IndexSet
    ///   - indexesOfModifiedGroups: IndexSet
    internal func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector,
                                    didCollect metadataGroups: [AVDateRangeMetadataGroup],
                                    indexesOfNewGroups: IndexSet,
                                    indexesOfModifiedGroups: IndexSet) {
        
        guard let delegate = self.parserDelegate else { return }
        delegate.dateMetaDataDidCollect(dateRangeMetadataGroups: metadataGroups)
        
    }
}
