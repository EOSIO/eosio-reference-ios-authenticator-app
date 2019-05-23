//
//  Validations.swift
//  Eosio
//
//  Created by Ben Martell on 11/8/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import EosioSwift

class Validation : NSObject {

    public static func isMetaDataValid(appMetaData: AppMetadata?) -> Bool {
        
        if let metaData = appMetaData {
            
            print("\n\nisMetaDataValid Called\nshort name: \(String(describing: metaData.shortname))\n, name: \(String(describing: metaData.name))\n, scope: \(String(describing: metaData.scope))\n, apphome: \(String(describing: metaData.apphome))\n, icon: \(String(describing: metaData.icon))\n, description: \(String(describing: metaData.description))\n")
            
            if metaData.scope == nil {return false}
            
            if metaData.name.isEmpty {return false}
            if metaData.shortname.isEmpty {return false}
            
            if  ResourceIntegrity.getResourceHash(resourceUrlPath: metaData.icon) == nil { //force unwrap ok because was checked above
                print("App icon from metadata is invalid")
                return false
            }
            return true
        } else {
           return false
        }
    }
    
    typealias CttValidation = (isValid:Bool, errorDetails:[AppError])
    public static func cttIsValid(transaction: EosioTransaction) -> CttValidation {
        var isValid = true
        var allErrors = [AppError]()
        
        for action in transaction.actions {
            if let error = action.ricardian?.error {
                if (error != "") {
                    
                    let theError = AppError(AppErrorCode.resourceIntegrityError, reason: error.replacingOccurrences(of: "\"", with: "\\\""))
                    
                    allErrors.append(theError)
                    
                    if true /* left in for place holder ( UserDefaults.Eosio.bool(forKey: .strictParsingCTT, defaultValue: true) == true ) */{
                        isValid = false
                    }
                }
            }
        }
        
        return CttValidation(isValid, allErrors)
    }
}
