//
//  Device.swift
//  EosioReferenceAuthenticator
//
//  Created by Todd Bowden on 8/8/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import CloudKit

public class Device: Encodable {
    
    public var name = ""
    public var deviceId = ""
    public var userId = ""
    public var make = ""
    public var model = ""
    public var iconName = ""
    public var osVersion = ""
    public var appVersion = ""
    public var isPresent = false
    public var isCurrent = false
    public var keys = [Key]()
    
    public var json: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    var record: CKRecord {
        let record = CKRecord(recordType: "Device", recordID: CKRecord.ID(recordName: deviceId))
        record["name"] = name as CKRecordValue
        record["userId"] = userId as CKRecordValue
        record["make"] = make as CKRecordValue
        record["model"] = model as CKRecordValue
        record["osVersion"] = osVersion as CKRecordValue
        record["appVersion"] = appVersion as CKRecordValue
        return record
    }
    
    init() { }
    
    public init(record: CKRecord) {
        deviceId = record.recordID.recordName
        name = record["name"] as? String ?? ""
        userId = record["userId"] as? String ?? ""
        make = record["make"] as? String ?? ""
        model = record["model"] as? String ?? ""
        osVersion = record["osVersion"] as? String ?? ""
        appVersion = record["appVersion"] as? String ?? ""
    }
    
    
    
}













