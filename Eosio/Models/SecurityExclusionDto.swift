//
//  SecurityExclusionDto.swift
//  Eosio
//
//  Created by Ben Martell on 11/26/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation

struct SecurityExclusionDto {
    let domain: String
    let addAssertToTransaction: Bool
    let domainMatch: Bool
    let iconIntegrity: Bool
    let metadataIntegrity: Bool
    let sslFingerprint: Bool
    let whitelistedActions: Bool
}
