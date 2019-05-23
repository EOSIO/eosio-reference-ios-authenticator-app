//
//  ZAssert.swift
//  Eosio
//
//  Created by Steve McCoole on 10/11/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation

func ZAssert(_ test: Bool, message: String) -> Void {

    if(test) {
        return
    }

    #if DEBUG
        print(message)
        let exception = NSException()
        exception.raise()
    #else
        NSLog(message)
        return
    #endif

}
