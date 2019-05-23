//
//  AppManifestProvider.swift
//  Eosio
//
//  Created by Todd Bowden on 12/6/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import EosioSwift
import EosioSwiftReferenceAuthenticatorSignatureProvider


class AppManifestProvider {
    
    private let errorPrefix = "App manifest error. "
    
    var securityExclusionAppMetadataIntegrity = false
    var securityExclusionIconIntegrity = false
    var securityExclusionDomainMatch = false
    
    // get the app manifest from a request payload
    func getAppManifest(payload: EosioReferenceAuthenticatorSignatureProvider.RequestPayload,
                        requireChainId: Bool = true,
                        requireHashIntegrity: Bool = true,
                        completion: @escaping (AppManifest?, AppError?)-> Void,
                        progress: ((DataFetcher, DataFetcherState) -> Void)? = nil) {
        
        guard let domain = payload.declaredDomain else {
            return completion(nil, AppError(AppErrorCode.domainError, reason: errorPrefix + "No declared domain.", isReturnable: false))
        }
        if requireChainId {
            print("REQUIRE CHAIN ID")
            guard let chainId = payload.request.transactionSignature?.chainId else {
                return completion(nil, AppError(AppErrorCode.manifestError, reason: errorPrefix + "No chain id in signature request.", isReturnable: false))
            }
            getAppManifest(domain: domain,
                           chainId: chainId,
                           requireHashIntegrity: requireHashIntegrity,
                           completion: completion,
                           progress: progress)
        } else {
            getAppManifest(domain: domain,
                           chainId: nil,
                           requireHashIntegrity: requireHashIntegrity,
                           completion: completion,
                           progress: progress)
        }
    }
    
    // get app manifest from the domain and chain id
    func getAppManifest(domain: String, chainId: String?, requireHashIntegrity: Bool = true,
                        completion: @escaping (AppManifest?, AppError?) -> Void,
                        progress: ((DataFetcher, DataFetcherState) -> Void)? = nil) {
        guard var domainUrlComponents = URLComponents(string: domain) else {
            return completion(nil, AppError(AppErrorCode.domainError, reason:  errorPrefix + "Invalid declared domain (\(domain)).", isReturnable: false))
        }
        if domainUrlComponents.scheme == nil {
            domainUrlComponents.scheme = "https"
        }
        guard domainUrlComponents.scheme == "https" || domainUrlComponents.host == "localhost" else {
            return completion(nil, AppError(AppErrorCode.domainError, reason: "Cannot fetch manifest from non-secure address \(domain)", isReturnable: false))
        }
        
        guard let domainUrl = domainUrlComponents.url else {
            return completion(nil, AppError(AppErrorCode.domainError, reason:  errorPrefix + "Invalid declared domain (\(domain)).", isReturnable: false))
        }
        
        let chainManifestsUrl = domainUrl.appendingPathComponent("/chain-manifests.json")
        // uncomment to test various error conditions
        //let chainManifestsUrl = domainUrl.appendingPathComponent("/chain-manifests-bad-domain.json")
        //let chainManifestsUrl = domainUrl.appendingPathComponent("/chain-manifests-bad-account.json")
        //let chainManifestsUrl = domainUrl.appendingPathComponent("/chain-manifests-bad-appmeta-hash.json")
        //let chainManifestsUrl = domainUrl.appendingPathComponent("/chain-manifests-bad-chain-id.json")
        //let chainManifestsUrl = domainUrl.appendingPathComponent("/chain-manifests-bad-app-id.json")
        //let chainManifestsUrl = domainUrl.appendingPathComponent("/chain-manifests-insecure-appmeta.json")
        //let chainManifestsUrl = domainUrl.appendingPathComponent("/chain-manifests-bad-whitelist.json")
        //let chainManifestsUrl = domainUrl.appendingPathComponent("/chain-manifests-bad-icon-hash.json")
        
        let cache = VerifiedDataCache()
        // do not have a hash for chainManifests, so don't require hash integrity. (manifest hash is computed using abieos and asserted on in the assert::require action)
        cache.getData(url: chainManifestsUrl.absoluteString, hash: nil, maxBytes: 100000, requireHashIntegrity: false,
            completion: { (data, error) in
            guard let data = data else {
                error?.isReturnable = false
                return completion(nil, error)
            }
            
            // decode the chain-manifests file
            let jsonDecoder = JSONDecoder()
            guard let chainManifests = try? jsonDecoder.decode(ChainManifests.self, from: data) else {
                return completion(nil, AppError(AppErrorCode.manifestError, reason:  self.errorPrefix + "Unable to decode chain-manifests.", isReturnable: false))
            }
            
            // validate the chain manifests array
            if let chainManifestsError = self.validateChainManifests(chainManifests.manifests) {
                return completion(nil, chainManifestsError)
            }
            
            // get the manifest for the specifed chain (or the first maninfest if the chainId is nil)
            guard let chainManifest = self.getChainManifest(chainId: chainId, chainManifests: chainManifests.manifests) else {
                var errorReason = self.errorPrefix + "No manifest provided."
                if let chainId = chainId {
                    errorReason = self.errorPrefix + "No manifest provided for chain id \(chainId)."
                }
                return completion(nil, AppError(AppErrorCode.manifestError, reason:  errorReason, isReturnable: false))
            }
                
            // set appManifest
            var appManifest = chainManifest.manifest

            // check that the domain in the manifest matches the declared domain (same origin policy)
            if !self.securityExclusionDomainMatch {
                guard let appManifestDomain = appManifest.domain.urlDomain else {
                    return completion(nil, AppError(AppErrorCode.manifestError, reason:  self.errorPrefix + "Manifest domain \(appManifest.domain) is not valid.", isReturnable: false))
                }
                guard appManifestDomain == domain.urlDomain else {
                    return completion(nil, AppError(AppErrorCode.domainError, reason:  self.errorPrefix + "Declared domain \(domain) does not match manifest domain \(appManifest.domain).", isReturnable: false))
                }
            }

            // get the metadata (and assocated icons)
            let appMetadataProvider = AppMetadataProvider()
            appMetadataProvider.securityExclusionAppMetadataIntegrity = self.securityExclusionAppMetadataIntegrity
            appMetadataProvider.securityExclusionIconIntegrity = self.securityExclusionIconIntegrity
            
            appMetadataProvider.getAppMetadata(chainId: chainId, appManifest: appManifest, requireHashIntegrity: requireHashIntegrity,
                completion: { (appMetadata, error) in
                    guard let appMetadata = appMetadata else {
                        return completion(nil, error)
                    }
                    appManifest.metadata = appMetadata
                    completion(appManifest, nil)
                },
                progress: progress)
            },
            progress: progress)
    }
    
    // get the manifest for the specifed chain (or the first maninfest if the chainId is nil)
    func getChainManifest(chainId: String?, chainManifests: [ChainManifest]) -> ChainManifest? {
        if let chainId = chainId {
            for chainManifest in chainManifests {
                if chainId == chainManifest.chainId {
                    return chainManifest
                }
            }
            return nil
        } else {
            return chainManifests.first
        }

    }
    
    // validate that the domain and appmeta are the same for all manifests
    func validateChainManifests(_ chainManifests: [ChainManifest]) -> AppError? {
        print("VALIDATE CHAIN MANIFESTS \(chainManifests.count)")
        guard let firstManifest = chainManifests.first?.manifest else {
            return AppError(AppErrorCode.manifestError, reason:  self.errorPrefix + "No manifest provided.", isReturnable: false)
        }
        for chainManifest in chainManifests {
            print("\(firstManifest.domain) ?= \(chainManifest.manifest.domain)")
            guard firstManifest.domain == chainManifest.manifest.domain else {
                return AppError(AppErrorCode.manifestError, reason:  self.errorPrefix + "All manifest domains do not match. \(firstManifest.domain) != \(chainManifest.manifest.domain)", isReturnable: false)
            }
            guard firstManifest.appmeta == chainManifest.manifest.appmeta else {
                return AppError(AppErrorCode.manifestError, reason:  self.errorPrefix + "All manifest appmeta do not match. \(firstManifest.appmeta) != \(chainManifest.manifest.appmeta)", isReturnable: false)
            }
        }
        return nil
    }
    
}
