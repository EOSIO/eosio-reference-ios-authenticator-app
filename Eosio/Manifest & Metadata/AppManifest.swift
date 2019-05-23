//
//  AppManifest.swift
//  EosioReferenceAuthenticator
//
//  Created by Todd Bowden on 10/5/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation

public struct ChainManifests: Codable {
    public var spec_version = ""
    public var manifests = [ChainManifest]()
}

public struct ChainManifest: Codable {
    public var chainId = ""
    public var manifest = AppManifest()
}


public struct AppManifest: Codable {
    
    public private(set) var account = ""
    public private(set) var domain = ""
    public private(set) var appmeta = ""
    public private(set) var whitelist = [Whitelist]()
    public var metadata: AppMetadata = AppMetadata()
    public struct Whitelist: Codable {
        public var contract = ""
        public var action = ""
    }
    
    
    public func isWhitelisted(contract: String, action: String) -> Bool {
        for item in whitelist {
            if (item.contract == contract || item.contract == "0") && (item.action == action || item.action == "0") {
                return true
            }
        }
        return false
    }
    
    public var json: String? {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(self) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
        
    enum CodingKeys: String, CodingKey {
        case account
        case domain
        case appmeta
        case whitelist
    }
    
    public init() { }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        account = try container.decodeIfPresent(String.self, forKey: .account) ?? account
        domain = try container.decodeIfPresent(String.self, forKey: .domain) ?? domain
        appmeta = try container.decodeIfPresent(String.self, forKey: .appmeta) ?? ""
        whitelist = try container.decodeIfPresent([Whitelist].self, forKey: .whitelist) ?? whitelist
        
    }
    
    
}


