//
//  FairplayRequester.swift
//  Player
//
//  Created by Fredrik Sjöberg on 2017-06-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import AVFoundation
import Exposure
import Alamofire

internal class FairplayRequester: NSObject, AVAssetResourceLoaderDelegate {
    let entitlement: PlaybackEntitlement
    
    init(entitlement: PlaybackEntitlement) {
        self.entitlement = entitlement
    }
    
    /// The DispatchQueue to use for AVAssetResourceLoaderDelegate callbacks.
    fileprivate let resourceLoadingRequestQueue = DispatchQueue(label: "com.emp.player.resourcerequests")
    /// The URL scheme for FPS content.
    static let customScheme = "emp"
    
    /// When iOS asks the app to provide a CK, the app invokes
    /// the AVAssetResourceLoader delegate’s implementation of
    /// its -resourceLoader:shouldWaitForLoadingOfRequestedResource:
    /// method. This method provides the delegate with an instance
    /// of AVAssetResourceLoadingRequest, which accesses the
    /// underlying NSURLRequest for the requested resource together
    /// with support for responding to the request.
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        return canHandle(resourceLoadingRequest: loadingRequest)
    }
    
    
    /// Delegates receive this message when assistance is required of the application
    /// to renew a resource previously loaded by
    /// resourceLoader:shouldWaitForLoadingOfRequestedResource:. For example, this
    /// method is invoked to renew decryption keys that require renewal, as indicated
    /// in a response to a prior invocation of
    /// resourceLoader:shouldWaitForLoadingOfRequestedResource:. If the result is
    /// YES, the resource loader expects invocation, either subsequently or
    /// immediately, of either -[AVAssetResourceRenewalRequest finishLoading] or
    /// -[AVAssetResourceRenewalRequest finishLoadingWithError:]. If you intend to
    /// finish loading the resource after your handling of this message returns, you
    /// must retain the instance of AVAssetResourceRenewalRequest until after loading
    /// is finished. If the result is NO, the resource loader treats the loading of
    /// the resource as having failed. Note that if the delegate's implementation of
    /// -resourceLoader:shouldWaitForRenewalOfRequestedResource: returns YES without
    /// finishing the loading request immediately, it may be invoked again with
    /// another loading request before the prior request is finished; therefore in
    /// such cases the delegate should be prepared to manage multiple loading
    /// requests.
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        return canHandle(resourceLoadingRequest: renewalRequest)
    }
    
    fileprivate func canHandle(resourceLoadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        guard let url = resourceLoadingRequest.request.url else {
            return false
        }
        
        // AssetLoaderDelegate only should handle FPS Content Key requests.
        //        if url.scheme != AssetLoaderDelegate.customScheme {
        //            return false
        //        }
        
        resourceLoadingRequestQueue.async { [unowned self] in
            self.handle(resourceLoadingRequest: resourceLoadingRequest)
        }
        
        return true
    }
    
    
    fileprivate func handle(resourceLoadingRequest: AVAssetResourceLoadingRequest) {
        
        guard let url = resourceLoadingRequest.request.url, let assetIDString = url.host else {
            print("Failed to get url or assetIDString for the request object of the resource.")
            return
        }
        
        
        guard let contentIdentifier = assetIDString.data(using: String.Encoding.utf8) else {
            resourceLoadingRequest.finishLoading(with: PlayerError.fairplay(reason: .invalidContentIdentifier))
            return
        }
        
        fetchApplicationCertificate{ [unowned self] certificate, certificateError in
            if let certificateError = certificateError {
                resourceLoadingRequest.finishLoading(with: certificateError)
                return
            }
            
            
            //let resourceLoadingRequestOptions = [AVAssetResourceLoadingRequestStreamingContentKeyRequestRequiresPersistentKey: true as AnyObject]
            
            if let certificate = certificate {
                do {
                    let spcData = try resourceLoadingRequest.streamingContentKeyRequestData(forApp: certificate, contentIdentifier: contentIdentifier, options: nil)
                    
                    self.fetchContentKeyContext(spc: spcData) { ckcData, ckcError in
                        if let ckcError = ckcError {
                            resourceLoadingRequest.finishLoading(with: ckcError)
                            return
                        }
                        
                        guard let ckcData = ckcData else {
                            resourceLoadingRequest.finishLoading(with: PlayerError.fairplay(reason: .missingContentKeyContext))
                            return
                        }
                        
                        guard let dataRequest = resourceLoadingRequest.dataRequest else {
                            resourceLoadingRequest.finishLoading(with: PlayerError.fairplay(reason: .missingDataRequest))
                            return
                        }
                        
                        // Provide data to the loading request.
                        dataRequest.respond(with: ckcData)
                        resourceLoadingRequest.finishLoading()  // Treat the processing of the request as complete.
                    }
                }
                catch {
                    resourceLoadingRequest.finishLoading(with: PlayerError.fairplay(reason: .serverPlaybackContext(error: error)))
                    return
                }
            }
        }
    }
    
    // MARK: Application Certificate
    fileprivate func fetchApplicationCertificate(callback: @escaping (Data?, PlayerError?) -> Void) {
        guard let url = certificateUrl else {
            callback(nil, .fairplay(reason: .missingApplicationCertificateUrl))
            return
        }
        
        Alamofire
            .request(url, method: .get)
            .validate()
            .responseData{ response in
                if let error = response.error {
                    callback(nil, .fairplay(reason: .invalidApplicationCertificateUrl(error: error)))
                    return
                }
                
                if let success = response.value {
                    callback(success,nil)
                }
        }
    }
    
    fileprivate var certificateUrl: URL? {
        guard let urlString = entitlement.fairplay?.certificateUrl else { return nil }
        return URL(string: urlString)
    }
    
    // MARK: Content Key Context
    fileprivate func fetchContentKeyContext(spc: Data, callback: @escaping (Data?, PlayerError?) -> Void) {
        guard let url = licenseUrl else {
            callback(nil, .fairplay(reason: .missingContentKeyContextUrl))
            return
        }
        
        Alamofire
            .upload(spc,
                    to: url,
                    method: .post)
            .validate()
            .responseData{ response in
                if let error = response.error {
                    callback(nil, .fairplay(reason:.contentKeyContext(error: error)))
                    return
                }
                
                if let success = response.value {
                    callback(success,nil)
                }
        }
    }
    
    fileprivate var licenseUrl: URL? {
        guard let urlString = entitlement.fairplay?.licenseAcquisitionUrl else { return nil }
        return URL(string: urlString)
    }
}
