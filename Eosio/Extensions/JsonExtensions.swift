//
//  JsonExtensions.swift
//  Eosio
//
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//


import Foundation


extension Dictionary {
    
    var jsonString: String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    
}


extension Array {
    
    var jsonString: String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    
}


extension String {
    
    var toJsonDictionary: [String:Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        let dict = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]) ?? nil
        return dict
    }
    
    
    static func jsonString(jsonObject: Any?) -> String? {
        guard let object = jsonObject else { return nil }
        if let string = object as? String {
            return string
        }
        let jsonData = try! JSONSerialization.data(withJSONObject: object, options: [])
        return String(data: jsonData, encoding: .utf8)
    }
    
}


