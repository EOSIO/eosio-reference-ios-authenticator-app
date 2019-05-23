//
//  ImportKeyTableViewController.swift
//  Eosio
//
//  Created by Serguei Vinnitskii on 10/9/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit
import EosioSwiftVault


class ImportKeyTableViewController: UITableViewController {

    @IBOutlet weak var privateKeyField: UITextField!
    @IBOutlet weak var privateKeyUnderlineView: UIView!
    @IBOutlet weak var keyNameField: UITextField!
    @IBOutlet weak var keyNameUnderlineView: UIView!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var privateKeyHelperLabel: UILabel!
    @IBOutlet weak var keyNameHelperLabel: UILabel!
    @IBOutlet weak var privateKeyErrorMessageStack: UIStackView!
    @IBOutlet weak var keyNameErrorMessageStack: UIStackView!
    @IBOutlet weak var pasteButton: DarkBlueButtonWhiteTitle!
    @IBOutlet weak var helperTextLabel: UILabel!


    private let vault = EosioVault(accessGroup: Constants.vaultAccessGroup)
    public var completion: ((_ didImport: Bool) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title  = "Add Auth"
        privateKeyField.delegate = self
        keyNameField.delegate = self
        privateKeyField.becomeFirstResponder()
        self.updatePasteButton()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = EosioAppearance.navBarLargeTitleAttributes
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") // removes bottom line on NavBar (to show it, set value back to false)
        self.privateKeyField.attributedPlaceholder = NSAttributedString(string: "Paste Key", attributes: EosioAppearance.placeHolderStringAttributes)
        self.keyNameField.attributedPlaceholder = NSAttributedString(string: "Choose Nickname", attributes: EosioAppearance.placeHolderStringAttributes)
        self.privateKeyErrorMessageStack.alpha = 0
        self.keyNameErrorMessageStack.alpha = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePasteButton), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        completion?(false)
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Showing & Hiding Helper Text labels
    @IBAction func privateKeyFieldDidEndEditing(_ sender: UITextField) {
        self.privateKeyHelperLabel.isHidden = sender.text?.isEmpty ?? true
    }

    @IBAction func privateKeyValueChanged(_ sender: UITextField) {
        self.privateKeyHelperLabel.isHidden = false
        guard UIPasteboard.general.string != nil else { return }
        self.pasteButton.isHidden = !(sender.text?.isEmpty ?? false)
    }

    // KeyName Fields
    @IBAction func keyNameFieldDidEndEditing(_ sender: UITextField) {
        self.keyNameHelperLabel.isHidden = sender.text?.isEmpty ?? true
    }

    @IBAction func keyNameFieldValueChanged(_ sender: UITextField) {
        self.keyNameHelperLabel.isHidden = false
    }

    @IBAction func didTapImport(_ sender: Any) {
        guard let privateKey = privateKeyField.text else { return } // unwrap
        guard isValidKey(keyString: privateKey) == true else {
            privateKeyField.applyShakeAnimation()
            privateKeyField.becomeFirstResponder()
            displayError(withErrorStack: self.privateKeyErrorMessageStack, andUnderLineView: self.privateKeyUnderlineView)
            return
        }
        guard let name = keyNameField.text?.trimmingCharacters(in: .whitespaces), name.isEmpty == false, name != " " else {
            keyNameField.applyShakeAnimation()
            keyNameField.becomeFirstResponder()
            displayError(withErrorStack: self.keyNameErrorMessageStack, andUnderLineView: self.keyNameUnderlineView)
            return
        }
        do {
            try importKey(key: privateKey, name: name)
            let successViewController = SuccessCheckmarkViewController()
            successViewController.modalPresentationStyle = .overCurrentContext
            self.keyNameField.resignFirstResponder()
            self.privateKeyField.resignFirstResponder()
            self.present(successViewController, animated: false, completion: nil)
            successViewController.dismissButtonPressed = { [weak self] in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.dismiss(animated: true, completion: nil)
                }
            }
        } catch {
            showAlert(title: "Failed to Import", message: "There was an error importing this key. Does it already exist on this device?")
        }
    }

    @IBAction func pasteButtonPressed(_ sender: UIButton) {
        if let value = UIPasteboard.general.string {
            self.privateKeyField.text = value
            self.pasteButton.isHidden = true
            self.keyNameField.becomeFirstResponder()
        }
    }

    @objc func updatePasteButton() {
        pasteButton.isHidden = UIPasteboard.general.string == nil
    }

    func displayError(withErrorStack errorStack: UIView, andUnderLineView lineView: UIView) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        lineView.backgroundColor = UIColor.customRed
        UIView.animate(withDuration: 0.2) { errorStack.alpha = 1 }
        let when = DispatchTime.now() + 4
        DispatchQueue.main.asyncAfter(deadline: when){
            UIView.animate(withDuration: 0.2) { errorStack.alpha = 0 }
            lineView.backgroundColor = UIColor.customDarkBlue
        }
    }
    
    func importKey(key: String, name: String) throws {
        var key = try vault.addExternal(eosioPrivateKey: key)
        key.name = name
        let _ = vault.update(key: key)
    }

    func validateKey(keyString: String) -> Error? {
        //implement specific errors for dev mode?
        do {
            let _ = try Data.init(eosioPrivateKey: keyString)
            return nil
        } catch {
            return error.eosioError
        }
    }
    
    func isValidKey(keyString: String) -> Bool {
        return validateKey(keyString: keyString) == nil
    }
    
    func showAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source: No data source methods => all rows & cells generated by storyboard
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ImportKeyTableViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case privateKeyField:
            keyNameField.becomeFirstResponder()
            return true
        default:
            self.view.endEditing(true)
            didTapImport(importButton)
            return true
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard textField == privateKeyField else { return true }
        guard let originalText = textField.text else { return false }
        guard let validRange = Range(range, in: originalText) else { return false }
        guard let newText = textField.text?.replacingCharacters(in: validRange, with: string) else { return false }
        if isValidKey(keyString: newText) && self.keyNameField.text?.isEmpty == true {
            self.keyNameField.becomeFirstResponder()
        }
        return true
    }
}
