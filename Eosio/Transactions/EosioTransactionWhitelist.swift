//
//  EosioTransactionWhitelist.swift
//  EosioReferenceAuthenticator
//
//  Created by Todd Bowden on 4/23/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import EosioSwift

extension EosioTransaction {

    public func nonWhitelistedActions(manifest: AppManifest) -> [Action] {
        var nwActions = [Action]()
        for action in actions {
            if !manifest.isWhitelisted(contract: action.account.string, action: action.name.string) && !action.isAssertRequire {
                nwActions.append(action)
            }
        }
        return nwActions
    }

    public func nonWhitelistedActionsList(manifest: AppManifest) -> String? {
        let nwActions = nonWhitelistedActions(manifest: manifest)
        guard nwActions.count > 0 else { return nil }
        var list = ""
        for action in nwActions {
            if list != "" {
                list = list + ", "
            }
            list = list + action.account.string + "::" + action.name.string
        }
        return list
    }


}

