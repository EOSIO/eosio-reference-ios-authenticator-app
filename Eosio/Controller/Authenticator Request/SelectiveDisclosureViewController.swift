//
//  SelectiveDisclosureViewController.swift
//  Eosio
//
//  Created by Todd Bowden on 11/13/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit
import EosioSwiftReferenceAuthenticatorSignatureProvider

class SelectiveDisclosureViewController: UIViewController {
    
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var allowButton: EosioButton!
    @IBOutlet weak var declineButton: EosioButton!
    @IBOutlet weak var requestingAppURL: UILabel!

    var appName: String?
    var appDescription: String? // not used at the moment
    var appIcon: UIImage?
    var appUrl: String?
 
    var request: EosioReferenceAuthenticatorSignatureProvider.SelectiveDisclosureRequest?
    var reply: ((Bool)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appLabel.text = "Allow \(appName ?? "Unknown App") to log in using this authenticator app?"
        appIconImageView.image = appIcon
        appIconImageView.layer.cornerRadius = 12
        appIconImageView.clipsToBounds = true
        requestingAppURL.text = appUrl

        declineButton.backgroundColor = UIColor.clear
        declineButton.setTitleColor(UIColor.customNavyBlue, for: .normal)

        // currently only authenticator disclosures are supported, more will be added
        guard isRequestAuthenticatorDisclosure() else {
            reply?(false)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func isRequestAuthenticatorDisclosure() -> Bool {
        guard let request = request else { return false }
        for disclosure in request.disclosures {
            if disclosure.type == .authorizers {
                return true
            }
        }
        return false
    }
    
    @IBAction func didTapAllow(_ sender: Any) {
        reply?(true)
    }
    
    @IBAction func didTapDecline(_ sender: Any) {
        reply?(false)
    }
    
}
