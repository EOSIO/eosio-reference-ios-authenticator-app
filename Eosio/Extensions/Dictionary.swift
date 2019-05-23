//
//  Dictionary.swift
//  EosioReferenceAuthenticator
//
//  Created by Farid Rahmani on 1/16/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

//Converts a Dictionary<String, Any> to Dictionary<UIApplication.OpenExternalURLOptionsKey, Any> so that it can be used as the options argument to open(_:options:completionHandler:) method of UIApplication class.
extension Dictionary where Key == String, Value:Any{
    func convertToUIApplicationOpenExternalURLOptionsKeyDictionary() -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary<UIApplication.OpenExternalURLOptionsKey, Any>(uniqueKeysWithValues: map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
}

