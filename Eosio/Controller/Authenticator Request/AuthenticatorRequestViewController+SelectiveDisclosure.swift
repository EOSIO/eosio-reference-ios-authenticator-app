//
//  AuthenticatorRequestViewController+SelectiveDisclosure.swift
//  Eosio
//
//  Created by Todd Bowden on 11/13/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import EosioSwift
import EosioSwiftReferenceAuthenticatorSignatureProvider


extension AuthenticatorRequestViewController {


    func handleSelectiveDisclosureRequest(payload: EosioReferenceAuthenticatorSignatureProvider.RequestPayload,
                                          manifest: AppManifest,
                                          completion: @escaping (EosioReferenceAuthenticatorSignatureProvider.SelectiveDisclosureResponse?)->Void) {
        
        guard let selectiveDisclosureRequest = payload.request.selectiveDisclosure else { return completion(nil) }
        
        present(selectiveDisclosureRequest: selectiveDisclosureRequest, manifest: manifest) { [weak self] (didAllow) in
            guard let strongSelf = self else {
                return completion(EosioReferenceAuthenticatorSignatureProvider.SelectiveDisclosureResponse(error: EosioError(.unexpectedError, reason: "self not in scope")))
            }
            strongSelf.handleSelectiveDisclosureUserResponse(didAllow: didAllow, completion: completion)
        }
        
    }

    
    func present(selectiveDisclosureRequest: EosioReferenceAuthenticatorSignatureProvider.SelectiveDisclosureRequest, manifest: AppManifest, reply: @escaping (Bool)->Void) {
        let selectiveDisclosureViewController = UIStoryboard(name: "SelectiveDisclosure", bundle: nil).instantiateViewController(withIdentifier: "SelectiveDisclosureViewController") as! SelectiveDisclosureViewController
        print(manifest)
        
        selectiveDisclosureViewController.reply = reply
        selectiveDisclosureViewController.request = selectiveDisclosureRequest
        selectiveDisclosureViewController.appName = manifest.metadata.shortname
        selectiveDisclosureViewController.appDescription = manifest.metadata.description
        selectiveDisclosureViewController.appIcon = manifest.metadata.iconImage
        selectiveDisclosureViewController.appUrl = manifest.domain
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(selectiveDisclosureViewController, animated: false)
            
        }
        
    }
    
    
    func handleSelectiveDisclosureUserResponse(didAllow: Bool, completion: @escaping (EosioReferenceAuthenticatorSignatureProvider.SelectiveDisclosureResponse?)->Void) {
        var response = EosioReferenceAuthenticatorSignatureProvider.SelectiveDisclosureResponse()
        guard didAllow else {
            response.error = EosioError(EosioErrorCode.signatureProviderError, reason: "User Declined")
            return completion(response)
        }

        getAllDevices(completion: { (devices, error) in
            if let error = error  {
                response.error = error
                return completion(response)
            }
            var authorizers = [EosioReferenceAuthenticatorSignatureProvider.Authorizer]()
            if let devices = devices {
                for device in devices {
                    for key in device.keys {
                        if key.isEnabled {
                            var authorizer = EosioReferenceAuthenticatorSignatureProvider.Authorizer()
                            authorizer.publicKey = key.publicKey
                            authorizers.append(authorizer)
                        }
                    }
                }
            }
            response.authorizers = authorizers
            completion(response)
        })

    }

    private func getAllDevices(completion: ([Device]?, EosioError?)->Void ) {
        completion([Device.current],nil)
    }


}
