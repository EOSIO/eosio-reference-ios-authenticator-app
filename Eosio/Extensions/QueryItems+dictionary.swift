//
//  QueryItems+dictionary.swift
//  Eosio
//
//  Created by Todd Bowden on 10/19/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation

extension Array where Element == URLQueryItem {
    
    var dictionary: [String:String] {
        var dict = [String:String]()
        for item in self {
            if let value = item.value {
                dict[item.name] = value
            }
        }
        return dict
    }
    
    
}
