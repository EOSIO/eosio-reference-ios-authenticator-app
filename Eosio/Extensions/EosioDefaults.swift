//
//  EosioDefaults.swift
//  EosioReferenceAuthenticator
//
//  Created by Steve McCoole on 10/3/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation

public protocol EosioDefaultable {
    associatedtype EosioDefaultKey: RawRepresentable
}

public extension EosioDefaultable where EosioDefaultKey.RawValue == String {
        
    static func set(_ bool: Bool, forKey key: EosioDefaultKey) {
        UserDefaults.standard.set(bool, forKey: key.rawValue)
    }
    
    static func bool(forKey key: EosioDefaultKey) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    static func bool(forKey key: EosioDefaultKey, defaultValue: Bool) -> Bool {
        if (UserDefaults.standard.value(forKey: key.rawValue) == nil) {
            UserDefaults.standard.set(defaultValue, forKey: key.rawValue)
        }
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
}

public extension UserDefaults {
    struct Eosio: EosioDefaultable {
        private init() { }
        
        public enum EosioDefaultKey: String {
            case copyPublicKey = "COPY_PUBLIC_KEY"
            case disableDeleteKeysAbility = "DISABLE_DELETE_SOFT_KEYS"
            case autorizersHelperTextHasBeenShown = "AUTHORIZERS_TUTORIAL_SHOWN"
            case insecureMode = "INSECURE_MODE"
        }

    }
    
}
