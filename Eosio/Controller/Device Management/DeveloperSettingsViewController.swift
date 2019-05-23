//
//  DeveloperSettingsViewController.swift
//  EosioReferenceAuthenticator
//
//  Created by Ben Martell on 2/12/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit

protocol RemoveDomainDelegate: class {
    func removeItem(itemIndex: Int)
}

class DeveloperSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, RemoveDomainDelegate {

    public static let exceptionDomainsArrayKey = "ExceptionDomainsArrayKey"
    
    let defaultText = "https://"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var domainTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var insecureSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    
    var tableData = [String]()
    
    public static func getSecurtyExceptionDomains() -> [String] {
        let defaults = UserDefaults.standard
        
        return defaults.object(forKey: DeveloperSettingsViewController.exceptionDomainsArrayKey) as? [String] ?? [String]()
    }
    
    public static func isExceptionDomain(domain: String) -> Bool {
        
        var theDomain = domain
        if !theDomain.starts(with: "https://") && !theDomain.starts(with: "http://localhost:") {
           theDomain =  "https://" + theDomain
        }
        let domains = DeveloperSettingsViewController.getSecurtyExceptionDomains()
        return domains.contains(theDomain)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        domainTextField.keyboardType = .URL
        domainTextField.delegate = self
        domainTextField.text = defaultText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = UserDefaults.standard
        self.tableData = defaults.object(forKey: DeveloperSettingsViewController.exceptionDomainsArrayKey) as? [String] ?? [String]()
        
        let switchValue = UserDefaults.Eosio.bool(forKey: .insecureMode)
        self.insecureSwitch.setOn(switchValue, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
    
    private func saveDomainData() {
        let defaults = UserDefaults.standard
        defaults.set(self.tableData, forKey: DeveloperSettingsViewController.exceptionDomainsArrayKey)
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DomainCell") as! DomainTableViewCell
        let domainUrl = self.tableData[indexPath.row]
        cell.domainUrl.text = domainUrl
        cell.index = indexPath.row
        cell.removeDomainDelegate = self
        return cell
    }
    
    // MARK: - Actions
    @IBAction func insecureSwitchChanged(_ sender: UISwitch) {
        
        if insecureSwitch.isOn {
            UserDefaults.Eosio.set(true, forKey: .insecureMode)
        }
        else {
            UserDefaults.Eosio.set(false, forKey: .insecureMode)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        guard let text = domainTextField.text, text.isEmpty == false && text.count > defaultText.count
            else { return }
        
        domainTextField.resignFirstResponder()
        self.tableData.append(text)
        saveDomainData()
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        domainTextField.text = defaultText
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        domainTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    
        DispatchQueue.main.async{
            
            let newPosition = self.domainTextField.endOfDocument
            self.domainTextField.selectedTextRange = self.domainTextField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    // MARK: - RemoveDomainDelegate
    func removeItem(itemIndex: Int) {
        
        self.tableData.remove(at: itemIndex)
        self.saveDomainData()
        self.tableView.reloadData()
    }
}
