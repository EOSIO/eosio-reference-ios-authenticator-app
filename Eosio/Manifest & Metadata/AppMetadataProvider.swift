//
//  AppMetadataProvider.swift
//  Eosio
//
//  Created by Todd Bowden on 12/6/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit

class AppMetadataProvider {
    
    private let errorPrefix = "App metadata error. "
    
    var securityExclusionAppMetadataIntegrity = false
    var securityExclusionIconIntegrity = false
    
    func getAppMetadata(chainId: String?, appManifest: AppManifest, requireHashIntegrity: Bool = true,
                        completion: @escaping (AppMetadata?, AppError?) -> Void,
                        progress: ((DataFetcher, DataFetcherState) -> Void)? = nil) {
        getAppMetadata(chainId: chainId, url: appManifest.appmeta, completion: completion, progress: progress)
    }
    
    
    func getAppMetadata(chainId: String?, url: String,  requireHashIntegrity: Bool = true,
                        completion: @escaping (AppMetadata?, AppError?) -> Void,
                        progress: ((DataFetcher, DataFetcherState) -> Void)? = nil) {
        guard let resourceHash = ResourceHash(url) else {
            return completion(nil, AppError(.metadataError, reason: errorPrefix + "Invalid url#Hash (\(url))."))
        }
        getAppMetadata(chainId: chainId, resourceHash: resourceHash, completion: completion, progress: progress)
    }
    
    
    func getAppMetadata(
        chainId: String?,
        resourceHash: ResourceHash,
        requireHashIntegrity: Bool = true,
        completion: @escaping (AppMetadata?, AppError?) -> Void,
        progress: ((DataFetcher, DataFetcherState) -> Void)? = nil
    ) {
        guard resourceHash.isHttps || resourceHash.isLocalhost else {
            return completion(nil, AppError(.metadataError, reason: self.errorPrefix + "Cannot fetch metadata from non-secure address \(resourceHash.resource)", isReturnable: false))
        }
        
        let dataCache = VerifiedDataCache()
        dataCache.clearCache()
        
        let requireResourceHashIntegrity = !self.securityExclusionAppMetadataIntegrity
        dataCache.getData(url: resourceHash.resource, hash: resourceHash.hash, maxBytes: 100000, requireHashIntegrity: requireResourceHashIntegrity, completion: { (data, error) in
            guard let data = data else {
                return completion(nil, error)
            }
            
            // decode the data to an AppMetadata struct
            let jsonDecoder = JSONDecoder()
            guard var appMetadata = try? jsonDecoder.decode(AppMetadata.self, from: data) else {
                return completion(nil, AppError(.metadataError, reason: self.errorPrefix + "Unable to decode app metadata.", isReturnable: false))
            }
            
            // get the appIcon ResourceHash
            guard let appIconResourceHash = self.getResourceHash(url: appMetadata.icon, baseUrl: resourceHash.baseUrl) else {
                return completion(nil, AppError(AppErrorCode.metadataError, reason: self.errorPrefix + "Invalid app icon."))
            }
            
            // check the appIcon ResourceHash is https
            guard appIconResourceHash.isHttps || appIconResourceHash.isLocalhost else {
                return completion(nil, AppError(.metadataError, reason: self.errorPrefix + "Cannot fetch app icon from non-secure address \(appIconResourceHash.resource)"))
            }

            // get the appIcon, possibly require hash integrity
            let requireIconHashIntegrity = !self.securityExclusionIconIntegrity
            dataCache.getData(url: appIconResourceHash.resource, hash: appIconResourceHash.hash, maxBytes: 100000, requireHashIntegrity: requireIconHashIntegrity, completion: { (appIconData, error) in
                guard let appIconData = appIconData else {
                    return completion(nil, error)
                }
                guard let appIcon = UIImage(data: appIconData) else {
                    return completion(nil, AppError(.metadataError, reason: self.errorPrefix + "App icon at \(appIconResourceHash.resource) is not an image."))
                }
                appMetadata.iconImage = appIcon
                
                // if chainId is nil, return metadata with no chain info
                guard let chainId = chainId else {
                    appMetadata.chains.removeAll()
                    return completion(appMetadata, nil)
                }
                
                // get the chain
                guard var chain = appMetadata.chain(id: chainId) else {
                    return completion(nil, AppError(.metadataError, reason: self.errorPrefix + "No metadata for chain \(chainId)."))
                }
                
                // get the chainIcon ResourceHash
                guard let chainIconResourceHash = self.getResourceHash(url: chain.icon, baseUrl: resourceHash.baseUrl) else {
                    return completion(nil, AppError(.metadataError, reason: self.errorPrefix + "Invalid chain icon."))
                }
                
                // check the chainIcon ResourceHash is https
                guard chainIconResourceHash.isHttps || chainIconResourceHash.isLocalhost else {
                    return completion(nil, AppError(.metadataError, reason: self.errorPrefix + "Cannot fetch chain icon from non-secure address \(chainIconResourceHash.resource)"))
                }
                
                // get the chainIcon, possibly require hash integrity
                dataCache.getData(url: chainIconResourceHash.resource, hash: chainIconResourceHash.hash, maxBytes: 50000,  requireHashIntegrity: requireIconHashIntegrity, completion: { (chainIconData, error) in
                    guard let chainIconData = chainIconData else {
                        return completion(nil, error)
                    }
                    guard let chainIcon = UIImage(data: chainIconData) else {
                        return completion(nil, AppError(.metadataError, reason: self.errorPrefix + "Chain icon at \(chainIconResourceHash.resource) is not an image."))
                    }
                    chain.iconImage = chainIcon
                    appMetadata.chain = chain
                    completion(appMetadata, nil)
                }, progress: progress)
                
            }, progress: progress)
        }, progress: progress)
    }
    
    func getResourceHash(url: String?, baseUrl: String?) -> ResourceHash? {
        guard var url = url, let baseUrl = baseUrl else { return nil }

        if url.prefix(4).lowercased() != "http" {
            url = baseUrl + url
        }
        return ResourceHash(url)
    }

}
