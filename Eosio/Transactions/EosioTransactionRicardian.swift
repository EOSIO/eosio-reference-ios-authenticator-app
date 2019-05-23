//
//  EosioTransactionRicardian.swift
//
//  Created by Todd Bowden on 4/23/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import EosioSwift

extension EosioTransaction {

    func renderRicardians(strictParsingCTT: Bool) throws {
        guard let transactionJson = self.transactionAsJsonWithUnserializedActionData else { return }
        let contractTemplateToolkit = ContractTemplateToolkit.default
        for (i, action) in self.actions.enumerated() {
            if let jsonAbi = try? abis.jsonAbi(name: action.account) {
                if let ricardian = contractTemplateToolkit?.ricardian(abi: jsonAbi, transaction: transactionJson, index: i, strictParsingCTT: strictParsingCTT) {
                    action.ricardian = ricardian
                    if ricardian.error != "" {
                        throw EosioError(EosioErrorCode.deserializeError, reason: ricardian.error)
                    }
                }
            }
        }
    }

}
