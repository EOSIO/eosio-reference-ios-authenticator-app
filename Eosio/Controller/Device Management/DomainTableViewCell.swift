//
//  DomainTableViewCell.swift
//  EosioReferenceAuthenticator
//
//  Created by Ben Martell on 2/12/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit

class DomainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var domainUrl: UILabel!
   
    @IBOutlet weak var deleteButton: UIButton!
    
    var removeDomainDelegate: RemoveDomainDelegate?
    
    var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func deletePresed(_ sender: UIButton) {
        
        self.removeDomainDelegate?.removeItem(itemIndex: index)
    }
    

}
