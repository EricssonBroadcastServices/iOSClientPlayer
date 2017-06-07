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
    static let customScheme = "skd"
    
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
        
         //FairplayRequester only should handle FPS Content Key requests.
        if url.scheme != FairplayRequester.customScheme {
            return false
        }
        
        resourceLoadingRequestQueue.async { [unowned self] in
            self.handle(resourceLoadingRequest: resourceLoadingRequest)
        }
        
        return true
    }
    
    
    fileprivate func handle(resourceLoadingRequest: AVAssetResourceLoadingRequest) {
        guard let url = resourceLoadingRequest.request.url, let assetIDString = entitlement.fairplay?.secondaryMediaLocator else {//url.host else {//entitlement.mediaLocator else {//
            print("Failed to get url or assetIDString for the request object of the resource.")
            return
        }
        
        print(url, " - ",assetIDString)
        
        guard let contentIdentifier = assetIDString.data(using: String.Encoding.utf8)?.base64EncodedData() else {
            resourceLoadingRequest.finishLoading(with: PlayerError.fairplay(reason: .invalidContentIdentifier))
            return
        }
        
        fetchApplicationCertificate{ [unowned self] certificate, certificateError in
            print("fetchApplicationCertificate")
            if let certificateError = certificateError {
                print("fetchApplicationCertificate ",certificateError.localizedDescription)
                resourceLoadingRequest.finishLoading(with: certificateError)
                return
            }
            
            
            let resourceLoadingRequestOptions: [String: Any]? = nil// [AVAssetResourceLoadingRequestStreamingContentKeyRequestRequiresPersistentKey: true as AnyObject]
            
            if let certificate = certificate {
                print("prepare SPC")
                do {
                    let spcData = try resourceLoadingRequest.streamingContentKeyRequestData(forApp: certificate, contentIdentifier: contentIdentifier, options: resourceLoadingRequestOptions)
                    self.fetchContentKeyContext(spc: spcData) { ckcData, ckcError in
                        print("fetchContentKeyContext")
                        if let ckcError = ckcError {
                            resourceLoadingRequest.finishLoading(with: ckcError)
                            return
                        }
                        
                        guard let ckcData = ckcData else {
                            resourceLoadingRequest.finishLoading(with: PlayerError.fairplay(reason: .missingContentKeyContext))
                            return
                        }
                        
                        let xml = SWXMLHash.parse(ckcData)
                        print(xml)
                        
//                        a CKC Blob Request Error Messages Error Message
//                        020 can’t get db connection, server is busy
//                        400 no media uid specified
//                        411 media uid does not exist
//                        500 invalid owner
//                        501 invalid user
//                        505 cannot reach 3rd party rights server
//                        507 invalid media rights
//                        510 cannot decrypt media key
//                        580 fairplay ask value not configured
//                        581 fairplay ask value is bad
//                        582 fairplay content key not found
//                        583 fairplay application private key is not enabled
//                        584 fairplay application private key not found
//                        585 can't read fairplay application private key
//                        586 bad fairplay spc payload
//                        587 bad private key for owner
//                        588 fairplay error
                        
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
//                    -42656 Lease duration has expired.
//                    -42668 The CKC passed in for processing is not valid.
//                    -42672 A certificate is not supplied when creating SPC.
//                    -42673 assetId is not supplied when creating an SPC.
//                    -42674 Version list is not supplied when creating an SPC.
//                    -42675 The assetID supplied to SPC creation is not valid.
//                    -42676 An error occurred during SPC creation.
//                    -42679 The certificate supplied for SPC creation is not valid.
//                    -42681 The version list supplied to SPC creation is not valid.
//                    -42783 The certificate supplied for SPC is not valid and is possibly revoked.
                    print("SPC - ",error.localizedDescription)
                    print("SPC - ",error)
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
            .responseData{ response in
                if let error = response.error {
                    callback(nil, .fairplay(reason: .applicationCertificateResponse(error: error)))
                    return
                }
                
                if let success = response.value {
                    let xml = SWXMLHash.parse(success)
                    /*
                     <fps>
                        <checksum>82033743d5c0...</checksum>
                        <version>4.3.4.0.44387</version>
                        <hostname>EMP-STAGE2-ACC01.ebsd.ericsson.net</hostname>
                        <cert>
                            MIIExzCCA6+gAwIBAgIIVRMcpsYSxcIwDQYJKoZIhvcNAQEFBQAwfzELMAkGA1UE..
                        </cert>
                     </fps>
                     */
                    
                    if let certString = xml["fps"]["cert"].element?.text {
                        let base64 = Data(base64Encoded: certString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
                        
                        // http://iosdevelopertips.com/core-services/encode-decode-using-base64.html
                        /* HTML5 player
                         https://github.com/EricssonBroadcastServices/html5-player/blob/f4b58bb5bdb5b85d2925271bc695822711e60371/sdk/src/js/tech/emp-hls.js
                         onCertificateLoadXml(event, { callback }) {
                         log('onCertificateLoadXml()');
                         var xml = event.target.responseXML;
                         var cert = xml.firstChild.lastElementChild.innerHTML;
                         certificate = base64DecodeUint8Array(cert);
                         callback();
                         }
                         */
                        print(certString)
                        print(base64)
                        callback(base64,nil)
                    }
                    else {
                        callback(nil, .fairplay(reason: .invalidCertificateData))
                    }
                    
                    
                    
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
