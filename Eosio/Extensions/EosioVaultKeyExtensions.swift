//
//  EosioVaultKeyExtensions.swift
//  EosioReferenceAuthenticator
//
//  Created by Todd Bowden on 4/24/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import EosioSwiftVault

extension EosioVault.VaultKey {

    var name: String {
        get {
            return self.metadata["name"] as? String ?? ""
        }
        set {
            self.metadata["name"] = newValue
        }

    }

    var isEnabled: Bool {
        get {
            return self.metadata["isEnabled"] as? Bool ?? true
        }
        set {
            self.metadata["isEnabled"] = newValue
        }
    }

    var isSoftKey: Bool {
        return !self.isSecureEnclave
    }

    

}
