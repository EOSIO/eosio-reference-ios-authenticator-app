//
//  Data+urlSafeBase64.swift
//  EosioMobileAuthenticatorSignatureProvider
//
//  Created by Todd Bowden on 10/18/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation


extension Data {
    var urlSafeBase64: String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    init?(urlSafeBase64: String) {
        var b64 = urlSafeBase64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let b64Mod4 = b64.count % 4
        if b64Mod4 > 0 {
            b64.append(String(repeating: "=", count: 4 - b64Mod4))
        }
        guard let data = Data(base64Encoded: b64) else {
            return nil
        }
        self = data
    }
}
