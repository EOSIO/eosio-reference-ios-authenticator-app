//
//  Snapshot.swift
//  EosioReferenceAuthenticatorTests
//
//  Created by Shawn Edge on 1/22/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import SnapshotTesting
import XCTest
import LocalAuthentication
@testable import EosioReferenceAuthenticator



class Snapshot: XCTestCase {

    // Test rendering of layout for BioEnrollment StoryBoard
     func testBioEnrollmentNone() {
        
        //Instantiate the ViewController for Storyboard
        let vc = UIStoryboard(name: "Biometrics", bundle: nil).instantiateViewController(withIdentifier: "BioEnrollmentController") as! BiometricEnrollmentViewController
        _ = vc.view
        
        //Assert storyboard view matches reference image
        //*** Snapshots are verifyed using iPhone 5s simulator. If you run the tests for any other simulator the image comparion will fail***
        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
        assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
        
        //Assert
        let realLabel = "Set Up Biometrics"
        XCTAssertEqual(vc.biometricEnrollmentErrorLabel.text, realLabel)
        
    }

    // Test rendering of layout for NoBioEnrollment Storyboard
    func testNoBioEnrollmentAvailable() {
        
        //Instantiate the ViewController for Storyboard
        let vc = UIStoryboard(name: "Biometrics", bundle: nil).instantiateViewController(withIdentifier: "NoBioController") as! NoBiometricsViewController
        _ = vc.view
        
        //Assert storyboard view matches reference image
        //*** Snapshots are verifyed using iPhone 5s simulator. If you run the tests for any other simulator the image comparion will fail***
        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
        assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
        
        let noLabel = "Sorry, Device is Not Supported"
        XCTAssertEqual(vc.noBiometricsErrorLabel.text, noLabel)
        
        let secondaryLabel = "This app requires Touch ID or Face ID which is not supported by your device."
        XCTAssertEqual(vc.noBiometricsSecondaryLabel.text, secondaryLabel)

    }
    
    // Test rendering of layout for Selective Disclosure Storyboard
    func testSelectiveDisclosureDisplay() {
        
        //Instantiate the ViewController for Storyboard
        let vc = UIStoryboard(name: "SelectiveDisclosure", bundle: nil).instantiateViewController(withIdentifier: "SelectiveDisclosureViewController") as! SelectiveDisclosureViewController
        _ = vc.view
        
        //Assert storyboard view matches reference image
        //*** Snapshots are verifyed using iPhone 5s simulator. If you run the tests for any other simulator the image comparion will fail***
        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
        assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
        
        let appLabel = "Allow \("Unknown App") to log in using this authenticator app?"
        XCTAssertEqual(vc.appLabel.text, appLabel)
        
        let radius = CGFloat(12)
        XCTAssertEqual(vc.appIconImageView.layer.cornerRadius, radius)

        let buttonColor = UIColor.clear
        XCTAssertEqual(vc.declineButton.backgroundColor, buttonColor)
        
        
    }
}
