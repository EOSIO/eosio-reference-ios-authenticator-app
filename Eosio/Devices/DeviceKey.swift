//
//  Device+Key.swift
//  EosioReferenceAuthenticator
//
//  Created by Todd Bowden on 8/20/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import CloudKit
import EosioSwiftVault

public extension Device {
    
    struct Key: Encodable {
        public var deviceId = ""
        public var name = ""
        public var publicKey = ""
        public var type = ""
        public var factor = ""
        public var storage = ""
        public var isSecureEnclave = false
        public var isSoftKey = false
        public var isEnabled = true
        public var isArchived = false
        public var color = "000000"
        public var domainStateAtCreation: Data?
        
        
        init(vaultKey: EosioVault.VaultKey, deviceId: String) {
            self.deviceId = deviceId
            self.name = vaultKey.name
            self.publicKey = vaultKey.eosioPublicKey
            self.isSecureEnclave = vaultKey.isSecureEnclave
            self.isSoftKey = vaultKey.isSoftKey
            self.isEnabled = vaultKey.isEnabled
            self.isArchived = vaultKey.isRetired
        }
        
        init?(record: CKRecord) {
            guard let deviceRef = record["Device"] as? CKRecord.Reference else { return nil }
            deviceId = deviceRef.recordID.recordName
            name = record["name"] as? String ?? ""
            publicKey = record["publicKey"] as? String ?? ""
            type = record["type"] as? String ?? ""
            storage = record["storage"] as? String ?? ""
            isEnabled = record["isEnabled"] as? Bool ?? false
            isArchived = record["isArchived"] as? Bool ?? false
            domainStateAtCreation = record["domainStateAtCreation"] as? Data
        }
    }
    
}
