//
//  SecurityExclusion+CoreDataCustom.swift
//  Eosio
//
//  Created by Ben Martell on 11/26/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import CoreData

extension SecurityExclusion : Fetchable {
    
    func delete(context: NSManagedObjectContext = DataManager.shared.viewContext) {
        context.delete(self)
    }
    
    static func retrieveByDomain(domain: String, context: NSManagedObjectContext = DataManager.shared.viewContext) -> SecurityExclusion? {
        print("domain is \(domain))")
        return SecurityExclusion.fetch(string: domain, propertyName: "domain", context: context)
    }
    
    static func upsert(dto: SecurityExclusionDto, context: NSManagedObjectContext = DataManager.shared.viewContext) -> SecurityExclusion? {
        var theSecurityExclusion: SecurityExclusion? = nil
        
        if let securityExclusion = SecurityExclusion.retrieveByDomain(domain: dto.domain, context: context) {
            theSecurityExclusion = securityExclusion
        } else {
            theSecurityExclusion = SecurityExclusion(context: context)
        }
        
        theSecurityExclusion?.updateFrom(dto: dto)
        
        return theSecurityExclusion
    }
    
    func updateFrom(dto: SecurityExclusionDto) {
        
        self.domain = dto.domain
        self.domainMatch = dto.domainMatch as NSNumber
        self.addAssertToTransaction = dto.addAssertToTransaction as NSNumber
        self.iconIntegrity = dto.iconIntegrity as NSNumber
        self.metadataIntegrity = dto.metadataIntegrity as NSNumber
        self.sslFingerprint = dto.sslFingerprint as NSNumber
    }
}
