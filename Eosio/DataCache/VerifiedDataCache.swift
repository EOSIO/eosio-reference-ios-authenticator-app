//
//  VerifiedDataCache.swift
//  EosioReferenceAuthenticator
//
//  Created by Todd Bowden on 9/27/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation


public class VerifiedDataCache {
    
    //simple synchronous calls (i.e.; without a completion closure) were needed to effectively use this in the app where it is being used.
    public func getData(forHash: String) -> Data? {
        
        return getData(hash: forHash)
    }

    public func isHashValid(hash: String) -> Bool {
        
        if localUrlForData(hash: hash) != nil {
            return true
        } else {
            return false
        }
    }
    
    //now primarity used for adding and updating icon data
    public func getData(url: String, hash: String?, maxBytes: UInt64?, requireHashIntegrity: Bool = true,
                        completion: @escaping (Data?, AppError?) -> Void,
                        progress: ((DataFetcher, DataFetcherState) -> Void)? = nil) {
        
        if let hash = hash?.lowercased(), let data = getData(hash: hash) {
            return completion(data, nil)
        }
        
        guard let url2 = URL(string: url) else {
            return completion(nil, AppError(AppErrorCode.resourceRetrievalError, reason: "\(url) is not a valid url"))
        }
        
        let dataFetcher = DataFetcher(url: url2, maxBytes: maxBytes)
        dataFetcher.fetch(completion: { (data, error) in
            guard let data = data else {
                return completion(nil, error)
            }
            
            let fetchedHash = data.sha256.hexEncodedString().lowercased()
            
            let hash = hash?.lowercased() ?? ""
            if requireHashIntegrity && fetchedHash != hash {
                return completion(nil, AppError(AppErrorCode.resourceIntegrityError, reason: "Hash of data at \(url) is \(fetchedHash) and does not match \(hash)."))
            }
            
            self.saveData(data)
            completion(data, nil)
        },
        progress: progress)
        
    }
    
    public func clearCache() {
        guard var cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        cachesDirectory = cachesDirectory.appendingPathComponent("DataByHash")
        try? FileManager.default.removeItem(at: cachesDirectory)
    }
    
    public init() { }
    
    private func localUrlForData(hash: String) -> URL? {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        return cachesDirectory.appendingPathComponent("DataByHash").appendingPathComponent(hash)
    }
    
    private func getData(hash: String) -> Data? {
        guard let url = localUrlForData(hash: hash) else { return nil }
        return try? Data(contentsOf: url)
    }
    
    private func saveData(_ data: Data) {
        let hash = data.sha256.hexEncodedString()
        guard let url = localUrlForData(hash: hash) else{ return }
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        try? data.write(to: url)
    }
    
    
}
