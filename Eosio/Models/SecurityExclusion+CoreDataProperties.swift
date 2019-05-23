//
//  SecurityExclusion+CoreDataProperties.swift
//  Eosio
//
//  Created by Ben Martell on 11/26/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import CoreData

extension SecurityExclusion {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SecurityExclusion> {
        return NSFetchRequest<SecurityExclusion>(entityName: "SecurityExclusion")
    }
    
    @NSManaged public var domain: String?
    @NSManaged public var addAssertToTransaction: NSNumber?
    @NSManaged public var domainMatch: NSNumber?
    @NSManaged public var iconIntegrity: NSNumber?
    @NSManaged public var metadataIntegrity: NSNumber?
    @NSManaged public var sslFingerprint: NSNumber?
    @NSManaged public var whitelistedActions: NSNumber?
}
