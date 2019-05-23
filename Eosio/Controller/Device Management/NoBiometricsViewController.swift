//
//  NoBiometricsViewController.swift
//  Eosio
//
//  Created by Steve McCoole on 10/22/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit

class NoBiometricsViewController: UIViewController {
        
    @IBOutlet weak var noBiometricsErrorLabel: UILabel!
    @IBOutlet weak var noBiometricsSecondaryLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        noBiometricsErrorLabel.text = "Sorry, Device is Not Supported"
        noBiometricsSecondaryLabel.text = "This app requires Touch ID or Face ID which is not supported by your device."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
}
