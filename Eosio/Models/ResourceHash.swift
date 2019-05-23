//
//  ResourceHash.swift
//  Eosio
//
//  Created by Todd Bowden on 12/4/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation


struct ResourceHash {
    let resource: String
    let hash: String
    let host: String
    var baseUrl: String
    let scheme: String
    let port: Int?
    var isHttps: Bool {
        return scheme.lowercased() == "https"
    }

    var isLocalhost: Bool {
        return host == "localhost"
    }
    
    init?(_ string: String) {
        let components = string.components(separatedBy: "#")
        guard components.count == 2 else { return nil }
        self.resource = components[0]
        self.hash = components[1]
        guard let url = URL(string: resource) else { return nil }
        guard let _ = Data(hexString: hash) else { return nil }
        guard let host = url.host else { return nil }
        self.host = host
        self.port = url.port
        guard let scheme = url.scheme else { return nil }
        self.scheme = scheme
        self.baseUrl = scheme + "://" + host
        if let port = port {
            self.baseUrl += ":\(port)"
        }
    }
}
