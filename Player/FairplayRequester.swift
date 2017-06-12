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
        
        guard let url = resourceLoadingRequest.request.url,
            let assetIDString = url.host,
            let contentIdentifier = assetIDString.data(using: String.Encoding.utf8) else {
            resourceLoadingRequest.finishLoading(with: PlayerError.fairplay(reason: .invalidContentIdentifier))
            return
        }
        
        print(url, " - ",assetIDString)
        
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
                    
                    // Content Key Context fetch from licenseUrl requires base64 encoded data
                    let spcBase64 = spcData.base64EncodedData(options: Data.Base64EncodingOptions.endLineWithLineFeed)
                    
                    self.fetchContentKeyContext(spc: spcBase64) { ckcBase64, ckcError in
                        print("fetchContentKeyContext")
                        if let ckcError = ckcError {
                            resourceLoadingRequest.finishLoading(with: ckcError)
                            return
                        }
                        
                        guard let dataRequest = resourceLoadingRequest.dataRequest else {
                            resourceLoadingRequest.finishLoading(with: PlayerError.fairplay(reason: .missingDataRequest))
                            return
                        }
                        
                        guard let ckcBase64 = ckcBase64 else {
                            resourceLoadingRequest.finishLoading(with: PlayerError.fairplay(reason: .missingContentKeyContext))
                            return
                        }
                        
                        // Provide data to the loading request.
                        dataRequest.respond(with: ckcBase64)
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
            .responseData{ [unowned self] response in
                if let error = response.error {
                    callback(nil, .fairplay(reason: .networking(error: error)))
                    return
                }
                
                if let success = response.value {
                    do {
                        let certificate = try self.parseApplicationCertificate(response: success)
                        callback(certificate, nil)
                    }
                    catch {
                        // parseApplicationCertificate will only throw PlayerError
                        callback(nil, error as? PlayerError)
                    }
                }
        }
    }
    
    fileprivate var certificateUrl: URL? {
        guard let urlString = entitlement.fairplay?.certificateUrl else { return nil }
        return URL(string: urlString)
    }
    
    /// MRR Application Certificate response format is XML
    /// 
    /// Success format
    /// <fps>
    ///    <checksum>82033743d5c0</checksum>
    ///    <version>1.2.3.400</version>
    ///    <hostname>host.example.com</hostname>
    ///    <cert>MIIExzCCA6+gAwIBAgIIVRMcpsYSxcIwDQYJKoZIhvcNAQEFBQAwfzELMAkGA1UE</cert>
    /// </fps>
    ///
    /// fps.cert: Contains the Application Certificate as base64 encoded string
    ///
    ///
    /// Error format
    /// <error>
    ///    <checksum>82033743d5c0</checksum>
    ///    <version>1.2.3.400</version>
    ///    <hostname>Some host</hostname>
    ///    <code>500</code>
    ///    <message>Error message</message>
    /// </error>
    fileprivate func parseApplicationCertificate(response data: Data) throws -> Data {
        let xml = SWXMLHash.parse(data)
        // MRR Certifica
        if let certString = xml["fps"]["cert"].element?.text {
            // http://iosdevelopertips.com/core-services/encode-decode-using-base64.html
            guard let base64 = Data(base64Encoded: certString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else {
                throw PlayerError.fairplay(reason: .applicationCertificateDataFormatInvalid)
            }
            return base64
        }
        else if let codeString = xml["error"]["code"].element?.text,
            let code = Int(codeString),
            let message = xml["error"]["message"].element?.text {
            
           throw PlayerError.fairplay(reason: .applicationCertificateServer(code: code, message: message))
        }
        throw PlayerError.fairplay(reason: .applicationCertificateParsing)
    }
    
    
    // MARK: Content Key Context
    fileprivate func fetchContentKeyContext(spc: Data, callback: @escaping (Data?, PlayerError?) -> Void) {
        guard let url = licenseUrl else {
            callback(nil, .fairplay(reason: .missingContentKeyContextUrl))
            return
        }
        
        guard let playToken = entitlement.playToken else {
            callback(nil, .fairplay(reason: .missingPlaytoken))
            return
        }
        
        let headers = ["AzukiApp": playToken, // May not be needed
                       "Content-type": "application/octet-stream"]
        
        Alamofire
            .upload(spc,
                    to: url,
                    method: .post,
                    headers: headers)
            .validate()
            .responseData{ response in
                if let error = response.error {
                    callback(nil, .fairplay(reason:.networking(error: error)))
                    return
                }
                
                if let success = response.value {
                    do {
                        let ckc = try self.parseContentKeyContext(response: success)
                        callback(ckc, nil)
                    }
                    catch {
                        // parseContentKeyContext will only throw PlayerError
                        callback(nil, error as? PlayerError)
                    }
                }
        }
    }
    
    fileprivate var licenseUrl: URL? {
        guard let urlString = entitlement.fairplay?.licenseAcquisitionUrl else { return nil }
        return URL(string: urlString)
    }
    
    /// MRR Content Key Context response format is XML
    ///
    /// Success format
    /// <fps>
    ///    <checksum>82033743d5c0</checksum>
    ///    <version>1.2.3.400</version>
    ///    <hostname>host.example.com</hostname>
    ///    <ckc>MIIExzCCA6+gAwIBAgIIVRMcpsYSxcIwDQYJKoZIhvcNAQEFBQAwfzELMAkGA1UE</cert>
    /// </fps>
    ///
    /// fps.ckc: Contains the Application Certificate as base64 encoded string
    ///
    ///
    /// Error format
    /// <error>
    ///    <checksum>82033743d5c0</checksum>
    ///    <version>1.2.3.400</version>
    ///    <hostname>Some host</hostname>
    ///    <code>500</code>
    ///    <message>Error message</message>
    /// </error>
    fileprivate func parseContentKeyContext(response data: Data) throws -> Data {
        let xml = SWXMLHash.parse(data)
        if let ckc = xml["fps"]["ckc"].element?.text {
            // http://iosdevelopertips.com/core-services/encode-decode-using-base64.html
            guard let base64 = Data(base64Encoded: ckc, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else {
                throw PlayerError.fairplay(reason: .contentKeyContextDataFormatInvalid)
            }
            return base64
        }
        else if let codeString = xml["error"]["code"].element?.text,
            let code = Int(codeString),
            let message = xml["error"]["message"].element?.text {
            
            throw PlayerError.fairplay(reason: .contentKeyContextServer(code: code, message: message))
        }
        throw PlayerError.fairplay(reason: .contentKeyContextParsing)
    }
}
