//
//  String+urlDomain.swift
//  EosioReferenceAuthenticator
//
//  Created by Todd Bowden on 1/3/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation

extension String {
    
    // returns the domain (host) component of a url
    var urlDomain: String? {
        var string = self
        if !string.contains("://") {
            string = "http://" + string
        }
        return URL(string: string)?.host
    }
    
}
