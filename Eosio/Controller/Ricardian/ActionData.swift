//
//  ActionData.swift
//  EosioReferenceAuthenticator
//
//  Created by Ben Martell on 1/18/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit
import WebKit

class ActionData {
    
    //ricardian properties
    var account = String()
    var summary = String()
    var title = String()
    var icon = ""
    var html = String()
    var securityExclusionIconIntegrity = false
    
    init(account: String, summary: String, title: String, icon: String, html: String) {
        
        self.account = account
        self.summary = summary
        self.title = title
        self.icon = icon
        self.html = html
    }
}
