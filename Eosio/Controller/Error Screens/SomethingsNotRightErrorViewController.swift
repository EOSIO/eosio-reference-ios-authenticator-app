//
//  InAppErrorViewController.swift
//  Eosio
//
//  Created by Ben Martell on 12/20/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit
import EosioSwift

class SomethingsNotRightErrorViewController: UIViewController {

    @IBOutlet weak var errorDescriptionLabel: UILabel!
    
    public var error: AppError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        if let theError = error {
            errorDescriptionLabel.text = theError.description
        } else {
            errorDescriptionLabel.text = ""
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Navigation
    @IBAction func goToAuths(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "authorizersListVC") as! AuthorizersListViewController
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    

}
