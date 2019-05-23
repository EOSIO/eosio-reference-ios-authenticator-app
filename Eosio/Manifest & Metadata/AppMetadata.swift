//
//  AppMetadata.swift
//  Eosio
//
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit
import EosioSwift

public struct AppMetadata: Decodable {
    public var name = ""
    public var shortname = ""
    public var appIdentifiers: [String]?
    public var scope: String?
    public var apphome: String?
    public var icon = ""
    public var description: String?
    public var chains = [Chain]()
    public var chain: Chain {
        get { return chains.first ?? Chain() }
        set { chains = [newValue] }
    }
    
    public var iconImage = UIImage()
    public var hash: String?
    
    public var chainParams: EosioTransaction.ChainParams {
        return EosioTransaction.ChainParams(chainId: chain.chainId, chainName: chain.chainName, icon: chain.icon)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case shortname
        case appIdentifiers
        case scope
        case apphome
        case icon
        case description
        case chains
        case hash
    }
    
    public struct Chain: Decodable {
        public var chainId = ""
        public var chainName = ""
        public var icon = ""
        public var iconImage = UIImage()

        enum CodingKeys: String, CodingKey {
            case chainId
            case chainName
            case icon
        }
    }
    
    
    
    public func chain(id: String) -> Chain? {
        for chain in chains {
            if id == chain.chainId {
                return chain
            }
        }
        return nil
    }
    
    public func chainParams(chainId: String) -> EosioTransaction.ChainParams? {
        for chain in chains {
            if chain.chainId == chainId {
                return EosioTransaction.ChainParams(chainId: chain.chainId, chainName: chain.chainName, icon: chain.icon)
            }
        }
        return nil
    }
    
    public func chainIconUrl(chainId: String) -> String {
        for chain in chains {
            if chain.chainId == chainId {
                return chain.icon
            }
        }
        return ""
    }
    
    
    
}
