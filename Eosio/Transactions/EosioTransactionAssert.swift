//
//  EosioTransactionAssert.swift
//
//  Created by Todd Bowden on 10/19/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//
//  This Extension will add the eosio.assert::require action to the actions
//

import Foundation
import EosioSwift

extension EosioTransaction.Action {
    public var isAssertRequire: Bool {
        return account.string == "eosio.assert" && name.string == "require"
    }
}

extension EosioTransaction {
    
    public struct ChainParams: Codable {
        public var chainId = ""
        public var chainName = ""
        public var icon = ""
        public init() { }
        public init(chainId: String, chainName: String, icon: String) {
            self.chainId = chainId
            self.chainName = chainName
            self.icon = icon.components(separatedBy: "#").last ?? ""
        }
    }
    
    struct AssertRequireDataStruct: Encodable {
        var chainParamsHash = ""
        var manifestId = ""
        var actions = [ContractAction]()
        var abiHashes = [String]()
        
        struct ContractAction: Equatable, Encodable {
            var contract: EosioName
            var action: EosioName
        }

        enum CodingKeys: String, CodingKey {
            case chainParamsHash = "chain_params_hash"
            case manifestId = "manifest_id"
            case actions
            case abiHashes = "abi_hashes"
        }
    }
    
    
    private func areAssertRequireActionsEqual(action1: Action, action2: Action) -> Bool {
        return action1.isAssertRequire &&
            action2.isAssertRequire &&
            action1.account == action2.account &&
            action1.name == action2.name &&
            action1.authorization == action2.authorization &&
            action1.dataSerialized == action2.dataSerialized &&
            action1.dataSerialized != nil &&
            action2.dataSerialized != nil
    }
    
    
    func addAssertRequireAction(appManifest: AppManifest) throws {
        let computedAssertRequireAction = try makeAssertRequireAction(appManifest: appManifest)
                
        // if the first action is an assert either validate it and return or throw an error
        if let firstAction = actions.first, firstAction.isAssertRequire {
            if areAssertRequireActionsEqual(action1: firstAction, action2: computedAssertRequireAction) {
                return
            } else {
                throw EosioError(.eosioTransactionError, reason: "eosio.assert::require action is invalid")
            }
        }
        // if another action is an assert but is not the first action, throw error
        for action in actions {
            if action.isAssertRequire {
                throw EosioError(.eosioTransactionError, reason: "eosio.assert::require must the be first action")
            }
        }
        // if the transaction already has signatures, you can't add more actions
        guard signatures == nil || signatures?.count == 0 else {
            throw EosioError(.eosioTransactionError, reason: "Cannot add eosio.assert::require to transaction with existing signatures")
        }
        // add assert as the first action
        self.add(action: computedAssertRequireAction, at: 0)
    }
    
    
    func makeAssertRequireAction(appManifest: AppManifest) throws -> Action {
        
        var assertRequireDataStruct = AssertRequireDataStruct()
        
        // get all unique contract actions
        var contractActions = [AssertRequireDataStruct.ContractAction]()
        for action in actions {
            let contractAction = AssertRequireDataStruct.ContractAction(contract: action.account, action: action.name)
            if !contractActions.contains(contractAction) && !action.isAssertRequire {
                contractActions.append(contractAction)
            }
        }
        
        // add contract_actions and hashs
        for contractAction in contractActions {
            let hash = try abis.hashAbi(name: contractAction.contract)
            assertRequireDataStruct.actions.append(contractAction)
            assertRequireDataStruct.abiHashes.append(hash)
        }
        
       
        // create json encoder
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        
        // get eosio.assert abi
        let eosioAssertAbi = try getAbiJsonFile(fileName: "eosio.assert.abi.json")
        
        // get serialization provider
        guard let serializationProvider = serializationProvider else {
            throw EosioError(.eosioTransactionError, reason: "No serialization provider")
        }
        
        // add manifestId hash
        let manifestJson = try appManifest.toJsonString(convertToSnakeCase: true, prettyPrinted: false)
        let manifestHex = try serializationProvider.serialize(contract: nil, name: "", type: "manifest", json: manifestJson, abi: eosioAssertAbi)
        let manifestHash = try Data(hex: manifestHex).sha256.hex
        assertRequireDataStruct.manifestId = manifestHash
        
        // add chainParams hash
        let chainParamsJsonData = try jsonEncoder.encode(appManifest.metadata.chainParams)
        guard let chainParamsJson = String(data: chainParamsJsonData, encoding: .utf8) else {
            throw EosioError(.eosioTransactionError, reason: "Cannot convert chainParamsJson data to json")
        }
     
        let chainParamsHex = try serializationProvider.serialize(contract: "eosio.assert", name: "", type: "chain_params", json: chainParamsJson, abi: eosioAssertAbi)
        guard let chainParamsData = Data(hexString: chainParamsHex) else {
            throw EosioError(.eosioTransactionError, reason: "Cannot convert chainParamsHex to data")
        }
        assertRequireDataStruct.chainParamsHash = chainParamsData.sha256.hex
        
        // uncomment for error checking by adding an invalid hash
        // assertRequireDataStruct.chainParamsHash = "invalid chain hash boo :(".data(using: .utf8)!.sha256.hex
        
        let assertRequireAction = try Action(account: "eosio.assert", name: "require", authorization: [], data: assertRequireDataStruct)
        try assertRequireAction.serializeData(abi: eosioAssertAbi, serializationProvider: serializationProvider)
        return assertRequireAction
    }
    
    
    private func getAbiJsonFile(fileName: String) throws -> String {
        var abiString = ""
        let path = Bundle.main.url(forResource: fileName, withExtension: nil)?.path ?? ""
        abiString = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
        guard abiString != "" else {
            throw EosioError(.serializationProviderError, reason: "Json to hex -- No ABI file found for \(fileName)")
        }
        return abiString
    }

    
}



