//
//  UtilityFunctions.swift
//  Eosio
//
//  Created by Ben Martell on 12/18/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit

func openInSafariAlert(inputURL: URL) {
    
    print("input url is...\(inputURL)")
    let safariAlert = UIAlertController(title: "Open In Safari", message: "This link is not a valid dApp. Would you like to view it in Safari?", preferredStyle: UIAlertController.Style.alert)
    
    safariAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
        UIApplication.shared.open(inputURL, options: [:])
    }))
    
    safariAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        safariAlert.dismiss(animated: true, completion: nil)
    }))
    
    print("\n\npresenting safari alert\n\n")
    // TODO comes out when HistoryViewController is scrapped
    //safariAlert.show()
}
