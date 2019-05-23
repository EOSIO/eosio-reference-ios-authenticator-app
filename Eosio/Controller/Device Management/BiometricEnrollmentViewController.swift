//
//  BiometricEnrollmentViewController.swift
//  Eosio
//
//  Created by Steve McCoole on 10/22/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

class BiometricEnrollmentViewController: UIViewController {
    
    var error: NSError?
    var biometricType: LABiometryType = LABiometryType.none
    
    @IBOutlet weak var biometricEnrollmentErrorLabel: UILabel!
    @IBOutlet weak var biometricsEnrollmentHelperText: UILabel!
    @IBOutlet weak var biometricSetupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let biometrics = (biometricType == LABiometryType.none) ? "Biometrics" : biometricType.description
        biometricEnrollmentErrorLabel.text = "Set Up \(biometrics)"
        biometricsEnrollmentHelperText.text = "As you browse the web and use your favorite apps, your security and safety is of paramount importance. Take a moment to set up \(biometrics), ensuring only you have access to your securely stored Authenticators."
        biometricSetupButton.setTitle("Enroll in \(biometrics)", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func biometricSetupPressed(_ sender: Any) {
        let defaultSettingsString = UIApplication.openSettingsURLString
        
        let settingsUrls = [defaultSettingsString]
        for urlString in settingsUrls {
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:].convertToUIApplicationOpenExternalURLOptionsKeyDictionary(), completionHandler: nil)
                break
            }
        }
    }
}



