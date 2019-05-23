//
//  ValidationTests.swift
//  EosioTests
//
//  Created by Steve McCoole on 11/19/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import XCTest
import EosioSwiftVault

@testable import EosioReferenceAuthenticator

class ValidationTests: XCTestCase {

    let iconNoHash = "/icon.png"
    
    let jsonData = """
{
    "name" : "EOSIO Reference Authenticator App",
    "shortname" : "EOSIO Reference Authenticator",
    "scope" : "/",
    "apphome" : "/",
    "icon" : "/icon.png#b3f9c204715b2d618790a2dcbcbeb7d485c873d4482ef1a9fc3f2a77fb6ac0aa",
    "description" : "Transfer tokens between accounts on an EOSIO blockchain",
    "sslfingerprint" : "D3 5F 35 A9 A9 F2 F7 44 E0 44 3D 47 51 B4 EF 4F 9D 50 64 CF ED 63 2B 62 AF 07 E4 71 EF 91 37 C1",
    "chains" : [
        {
            "chainId" : "cf057bbfb72640471fd910bcb67639c22df9f92470936cddc1ade0e2f2e7dc4f",
            "chainName" : "Local Chain"    ,
            "icon" : "/localchainlogo.png#4720078c233754482699678cbf8e75b0b671596f794904a5a788515517f04ee3"
        }
    ],
    "hash" : "8271ed863596c5ac35284e5441945958ab5036bac00f567df07bdb943ba9a5b5"
}
""".data(using: .utf8)!
    
    override func setUp() {
    }

    override func tearDown() {
    }

    func testValidMetadata() {
        let appMetadata = metadataFromData(data: jsonData)
        XCTAssert(appMetadata != nil, "Failed to decode AppMetadata from JSON")
        let isMetadataValid = Validation.isMetaDataValid(appMetaData: appMetadata)
        XCTAssert(isMetadataValid, "AppMetadata failed validation that should have passed.")
    }

    func testScopeFails() {
        let appMetadata = createBadMetadata(fieldToChange: "scope")
        XCTAssert(appMetadata != nil, "Failed to decode AppMetadata from JSON")
        let isMetadataValid = Validation.isMetaDataValid(appMetaData: appMetadata)
        
        XCTAssert(isMetadataValid == false, "AppMetadata passed validation that should have failed.")
    }
    
    func testIconFails() {
        let appMetadata = createBadMetadata(fieldToChange: "icon", fieldValue: "")
        XCTAssert(appMetadata != nil, "Failed to decode AppMetadata from JSON")
        let isMetadataValid = Validation.isMetaDataValid(appMetaData: appMetadata)
        XCTAssert(isMetadataValid == false, "AppMetadata passed validation that should have failed.")
    }
    
    func testNameFails() {
        let appMetadata = createBadMetadata(fieldToChange: "name", fieldValue: "")
        XCTAssert(appMetadata != nil, "Failed to decode AppMetadata from JSON")
        let isMetadataValid = Validation.isMetaDataValid(appMetaData: appMetadata)
        XCTAssert(isMetadataValid == false, "AppMetadata passed nil validation that should have failed.")
        
        let appMetadata2 = createBadMetadata(fieldToChange: "name", fieldValue: "")
        XCTAssert(appMetadata2 != nil, "Failed to decode AppMetadata from JSON")
        let isMetadataValid2 = Validation.isMetaDataValid(appMetaData: appMetadata)
        XCTAssert(isMetadataValid2 == false, "AppMetadata passed empty validation that should have failed.")
    }
    
    func testShortNameFails() {
        let appMetadata = createBadMetadata(fieldToChange: "shortname", fieldValue: "")
        XCTAssert(appMetadata != nil, "Failed to decode AppMetadata from JSON")
        let isMetadataValid = Validation.isMetaDataValid(appMetaData: appMetadata)
        XCTAssert(isMetadataValid == false, "AppMetadata passed nil validation that should have failed.")
        
        let appMetadata2 = createBadMetadata(fieldToChange: "shortname", fieldValue: "")
        XCTAssert(appMetadata2 != nil, "Failed to decode AppMetadata from JSON")
        let isMetadataValid2 = Validation.isMetaDataValid(appMetaData: appMetadata)
        XCTAssert(isMetadataValid2 == false, "AppMetadata passed empty validation that should have failed.")
    }
    
    func testIconNoHashFails() {
        let appMetadata = createBadMetadata(fieldToChange: "icon", fieldValue: iconNoHash)
        XCTAssert(appMetadata != nil, "Failed to decode AppMetadata from JSON")
        let isMetadataValid = Validation.isMetaDataValid(appMetaData: appMetadata)
        XCTAssert(isMetadataValid == false, "AppMetadata passed icon with no hash validation that should have failed.")
    }
    
    private func metadataFromData(data: Data) -> AppMetadata? {
        do {
            let appMetadata = try JSONDecoder().decode(AppMetadata.self, from: data)
            return appMetadata
        } catch let jsonError {
            print("Error parsing JSON: \(jsonError.localizedDescription)")
            return nil
        }
    }
    
    private func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch let jsonError {
            print("Error parsing JSON: \(jsonError.localizedDescription)")
        }
        return nil
    }
    
    private func jsonToData(json: Any) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let jsonError {
            print("Error encoding JSON: \(jsonError.localizedDescription)")
        }
        return nil
    }
    
    private func createBadMetadata(fieldToChange: String, fieldValue: String? = nil) -> AppMetadata? {
        var json = dataToJSON(data: jsonData) as? [String: Any?]
        guard json != nil else {
            return nil
        }
        if let _ = json?[fieldToChange] {
            json?[fieldToChange] = fieldValue
        }
        guard let data = jsonToData(json: json as Any) else {
            return nil
        }
        return metadataFromData(data: data)
    }
}
