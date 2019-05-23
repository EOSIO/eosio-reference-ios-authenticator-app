//
//  AuthorizersListDeviceCell.swift
//  Eosio
//
//  Created by Serguei Vinnitskii on 11/14/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit
import EosioSwiftVault

class AuthorizersListDeviceCell: UITableViewCell {

    @IBOutlet weak var keyName: UILabel!
    @IBOutlet weak var keyIcon: UIImageView!

    let device = Device.current

    func setupCell(withKey key: EosioVault.VaultKey?) {
        keyName.text = key?.name ?? "Unknown Key"
        keyIcon.image = key?.isSoftKey == true ? #imageLiteral(resourceName: "keyIcon-2") : #imageLiteral(resourceName: "iPhoneShapeIcon")
    }
}
