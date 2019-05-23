//
//  Device+Current.swift
//  EosioReferenceAuthenticator
//
//  Created by Todd Bowden on 8/8/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit
import EosioSwiftVault

public extension Device {
    
    static var current: Device {
        
        let vault = EosioVault(accessGroup: Constants.vaultAccessGroup)
        
        let device = Device()
        device.deviceId = (try? vault.vaultIdentifier()) ?? ""
        device.name = UIDevice.current.name
        device.model = UIDevice.current.modelName ?? UIDevice.current.model
        device.make = "Apple"
        device.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        device.osVersion = UIDevice.current.systemVersion
        device.isCurrent = true
        device.isPresent = true
        
        if UIDevice.current.model == "iPad" {
            device.iconName = "iPad"
        } else if device.model == "iPhone X" {
            device.iconName = "iPhoneX"
        } else {
            device.iconName = "iPhone"
        }
        
        guard var vaultKeys = try? vault.getAllVaultKeys() else { return device }
        var numSecureEnclaveKeys = 0
        for key in vaultKeys {
            if key.isSecureEnclave {
                numSecureEnclaveKeys = numSecureEnclaveKeys + 1
            }
        }
        if numSecureEnclaveKeys == 0 {
            let _ = try? vault.newSecureEnclaveKey(bioFactor: .none, metadata: ["name":"Secure Key"])
            vaultKeys = (try? vault.getAllVaultKeys()) ?? vaultKeys
        }
        
        for vaultKey in vaultKeys {
            if !vaultKey.isRetired && vaultKey.isEnabled {
                device.keys.append(Key(vaultKey: vaultKey, deviceId: device.deviceId))
            }
        }
                
        return device
    }
    
    
}
