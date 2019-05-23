//
//  AuthenticatorDetailsTableViewController.swift
//  Eosio
//
//  Created by Serguei Vinnitskii on 12/5/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit
import EosioSwiftVault

class AuthenticatorDetailsTableViewController: UITableViewController {

    @IBOutlet weak var keyNameTextField: UITextField!
    @IBOutlet weak var deleteKeyButton: UIButton!
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var warningMessageStack: UIStackView!
    @IBOutlet weak var keyNameUnderline: UIView!
    @IBOutlet weak var copyKeyButton: DarkBlueButtonWhiteTitle!

    var key: EosioVault.VaultKey? // set by parent View Controller
    private let vault = EosioVault(accessGroup: Constants.vaultAccessGroup)
    var keyDeletePressed: ((_ publicKey: String)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let validKey = key {
            self.keyNameTextField.text = validKey.name
            self.publicKeyLabel.text = validKey.eosioPublicKey
        }
        deleteKeyButton.isHidden = !canDeleteKey()
        copyKeyButton.isHidden = !UserDefaults.Eosio.bool(forKey: .copyPublicKey, defaultValue: true)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)) //empty footer to remove un-used cells
        self.warningMessageStack.alpha = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func applicationDidBecomeActive() {
        deleteKeyButton.isHidden = !canDeleteKey()
        copyKeyButton.isHidden = !UserDefaults.Eosio.bool(forKey: .copyPublicKey)
    }

    private func canDeleteKey() -> Bool {
        guard let validKey = key else { return false }
        return (UserDefaults.Eosio.bool(forKey: .disableDeleteKeysAbility, defaultValue: true) == false && validKey.isSecureEnclave == false) ? true : false
    }

    // MARK: - Outlet actions
    @IBAction func keyNameEditingEnded(_ sender: UITextField) {
        guard let validName = sender.text else { return }
        let nameWithoutSpaces = validName.trimmingCharacters(in: .whitespaces)
        guard nameWithoutSpaces.count > 0 else { // show error
            self.showErrorMessage()
            return
        }
        self.key?.name = nameWithoutSpaces
        guard let validKey = self.key else { return }
        if vault.update(key: validKey) {
            sender.resignFirstResponder()
            let nameUpdatedAlert = UIAlertController(title: "Name Updated", message: "", preferredStyle: UIAlertController.Style.alert)
            self.present(nameUpdatedAlert, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    nameUpdatedAlert.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    @IBAction func copyKeyPressed(_ sender: UIButton) {
        guard let validKey = key else { return }
        UIPasteboard.general.string = validKey.eosioPublicKey
        let copySuccess = UIAlertController(title: "Copied to Clipboard!", message: "", preferredStyle: UIAlertController.Style.alert)
        self.present(copySuccess, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                copySuccess.dismiss(animated: true, completion: nil)
            })
        })
    }

    func showErrorMessage() {
        self.keyNameTextField.applyShakeAnimation()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.2) { self.warningMessageStack.alpha = 1 }
        self.keyNameUnderline.backgroundColor = UIColor.customRed
        let when = DispatchTime.now() + 4
        DispatchQueue.main.asyncAfter(deadline: when){
            UIView.animate(withDuration: 0.2) { self.warningMessageStack.alpha = 0 }
            self.keyNameUnderline.backgroundColor = UIColor.customDarkBlue
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    @IBAction func deleteKeyPressed(_ sender: UIButton) {

        guard let validPublicKey = key?.eosioPublicKey else {
            let noValidKeyAlert = UIAlertController(title: "Error: \nNo valid key found", message: "", preferredStyle: .alert)
            self.present(noValidKeyAlert, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    noValidKeyAlert.dismiss(animated: true, completion: nil)
                })
            })
            return
        }

        self.key?.isEnabled = false
        guard let validKey = self.key else { return }
        if self.vault.update(key: validKey) {
            DispatchQueue.main.async {
                self.keyDeletePressed?(validPublicKey) // notify parent
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
