//
//  EosioTransactionContractTemplateToolkit.swift
//
//  Created by Todd Bowden on 8/27/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import EosioSwift
import JavaScriptCore


public extension EosioTransaction {
    
    class ContractTemplateToolkit {
        
        static let `default` = ContractTemplateToolkit()
        
        let jsContext = JSContext()
        
        public init?() {
            
            guard let path = Bundle(for: ContractTemplateToolkit.self).url(forResource: "contract-template-toolkit", withExtension: "js")?.path else { return nil }
            guard let js = try? NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String else { return nil }
            let _ = jsContext?.evaluateScript(js)
        }
        
        func ricardian(abi: String, transaction: String, index: Int, strictParsingCTT: Bool) -> EosioTransaction.Action.Ricardian?  {
            print("*****RICARDIAN")
            print(transaction)
            print("--------------------------")
            var errors: [String] = []

            jsContext?.exceptionHandler = { (context, value) in
                if let validError = value?.toString() {
                    errors.append(validError)
                    print(validError)
                }
            }
            
            guard let jsContext = jsContext else { return nil }
            guard let jsJSON = jsContext.objectForKeyedSubscript("JSON") else { return nil }
            guard let jsContractTemplateToolkit = jsContext.objectForKeyedSubscript("ContractTemplateToolkit") else { return nil }

            let allowUnusedVariables = !strictParsingCTT
            
            let jsonParam = """
                {
                    "abi" : \(abi),
                    "transaction" : \(transaction),
                    "actionIndex" : \(index),
                    "allowUnusedVariables" : \(allowUnusedVariables)
                }
            """

            guard let jsJsonParam = jsJSON.invokeMethod("parse", withArguments: [jsonParam]) else { return nil }
            guard let rcFactory = jsContractTemplateToolkit.objectForKeyedSubscript("RicardianContractFactory").construct(withArguments: nil) else { return nil }
            guard let rc = rcFactory.invokeMethod("create", withArguments: [jsJsonParam]) else { return nil }

            let ricardian = EosioTransaction.Action.Ricardian()
            ricardian.html = rc.invokeMethod("getHtml", withArguments: nil)?.toString() ?? ""
            ricardian.error = errors.first ?? ""
            if let metadata = rc.invokeMethod("getMetadata", withArguments: nil)?.toDictionary() {
                ricardian.metadata.icon = metadata["icon"] as? String ?? ""
                ricardian.metadata.summary = metadata["summary"] as? String ?? ""
                ricardian.metadata.title = metadata["title"] as? String ?? ""
            }
            
            print("==================================================================")
            print(ricardian.html)
            print("==================================================================")
            print(ricardian.metadata.title)
            print(ricardian.metadata.summary)
            print(ricardian.metadata.icon)
            print("==================================================================")

            return ricardian
        }
        
    }
    
}
