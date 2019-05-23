//
//  WebViewPreLoader.swift
//  EosioReferenceAuthenticator
//
//  Created by Ben Martell on 1/29/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import WebKit

class WebViewPreloader {
    
    static let warmupFieName = "Warmup"
    
    class func getWarmedUpWebView()->WKWebView? {
        
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        let htmlUrl = Bundle.main.url(forResource: WebViewPreloader.warmupFieName, withExtension: "html")
        
        if htmlUrl != nil {
            let request = NSURLRequest(url: htmlUrl!)
            webView.load(request as URLRequest)
            return webView
        } else {
            NSLog("Could not load: \(warmupFieName).html")
            return nil
        }
    }
}


