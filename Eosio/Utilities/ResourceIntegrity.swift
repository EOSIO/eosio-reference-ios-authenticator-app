//
//  IconIntegrity.swift
//  Eosio
//
//  Created by Ben Martell on 10/10/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import EosioSwift
import UIKit

class ResourceIntegrity : NSObject {
    
    static var verifiedDataCache: VerifiedDataCache = VerifiedDataCache()
    
    public static func updateDataCache(url: String, hash: String?, progress: ((DataFetcher, DataFetcherState) -> Void)? = nil) {
        
        let verifiedDataCache = VerifiedDataCache()
        
        verifiedDataCache.getData(url: url, hash: hash, maxBytes: nil, completion: { data, error in
            
            if let theError = error {
                //debug print
                print("Unable to update the icon data cache successfully: \(theError)")
            }
        },
        progress: progress)
    }
    
    public static func iconIntegrityPassed(hash: String, securityExclusionIconIntegrity: Bool) -> Bool {
        var retval = true
        
        if securityExclusionIconIntegrity == false {
            retval = ResourceIntegrity.verifiedDataCache.isHashValid(hash: hash)
        }
        
        return retval
    }
    
    static func getResourceHash(resourceUrlPath: String) -> String? {
        if let index = resourceUrlPath.lastIndex(of: "#") {
            let hash = resourceUrlPath[resourceUrlPath.index(after: index)...]
            return String(hash)
        } else {
            return nil
        }
    }
    
    
    static func getImage(resourceUrlPath: String, securityExclusionIconIntegrity: Bool) throws -> UIImage? {
        
        var retVal: UIImage?
        
        if let urlHash = ResourceIntegrity.getResourceHash(resourceUrlPath: resourceUrlPath) {
            
            let hash = urlHash.lowercased()
            
            if ResourceIntegrity.iconIntegrityPassed(hash: hash, securityExclusionIconIntegrity: securityExclusionIconIntegrity) == false {
                throw AppError(AppErrorCode.resourceRetrievalError, reason:"Image retrieval failed the integrity check")
            } else {
                
                if let data = ResourceIntegrity.verifiedDataCache.getData(forHash: hash) {
                    
                    if let image = UIImage(data: data as Data) {
                        print("image retrieval success")
                        retVal = image
                    }
                } else {
                    throw AppError(AppErrorCode.resourceRetrievalError, reason:"Unable to retrieve  image for hash: \(hash)")
                }
            }
        } else {
           throw AppError(AppErrorCode.resourceRetrievalError, reason:"Unable to retrieve image:  No valid hash or path found.")
        }
        
        return retVal
    }
    
    public static func getIconUrlString(url: URL, appMetadata: AppMetadata) -> String? {

        guard let urlHost = url.host else {return nil}
        guard appMetadata.icon.isAbsoluteURL() == false else { return appMetadata.icon.lowercased() }

        //check if http or https + construct absolute URL
        let delimiter = ":"
        let tokenized = url.absoluteString.components(separatedBy: delimiter)
        let urlPrefix = tokenized[0]
        let appIcon = appMetadata.icon 
        let fullImagePath = urlPrefix + "://" + urlHost + appIcon
        return fullImagePath
    }
    
    static func getActionIconUrls(transaction: EosioTransaction,
                                  progress: ((DataFetcher, DataFetcherState) -> Void)? = nil,
                                  completion: @escaping ([String], AppError?) -> Void) {
        
        completion([String](),nil)

        let waitGroup = DispatchGroup()
        
        var retVal: [String] = [String]()
        var returnError : AppError?
        var assertActionCount = 0
        
        let actions = transaction.actions
        
        for actionData in actions {

            if actionData.isAssertRequire {
                assertActionCount += 1
                continue
            }
            
            if returnError != nil {
                completion(retVal, returnError!)
            }
            
            if let metaData = actionData.ricardian?.metadata,
                metaData.icon.count > 0 {
                
                    let iconUrlPath = metaData.icon
                    let hash = ResourceIntegrity.getResourceHash(resourceUrlPath: iconUrlPath)
            
                    //This call is the first atttempt we encounter to get the action icon data.  We make an async network call that we need to wait to complete for each action icon. Validation needs to happen for all the action icons. Perhaps this should be done with PromiseKit?
                    waitGroup.enter()
                    ResourceIntegrity.verifiedDataCache.getData(url: iconUrlPath, hash: hash, maxBytes: nil,
                    completion: { data, error in
                        
                        if let theError = error {
                            completion(retVal, theError)
                        } else {
                           retVal.append(iconUrlPath)
                        }
                        
                        waitGroup.leave()
                    },
                    progress: progress
                    )

            } else {
               returnError = AppError(AppErrorCode.resourceIntegrityError, reason:"Action missing icon or invalid icon format")
            }
        }

        // If we got here, everything seems to be ok
        waitGroup.notify(queue: DispatchQueue.main) {
            if actions.count - assertActionCount != retVal.count {
                returnError = AppError(AppErrorCode.resourceIntegrityError, reason:"Actions missing one or more icon")
            } else {
                completion(retVal, returnError)
            }

        }
    }
}
