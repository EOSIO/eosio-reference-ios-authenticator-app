//
//  EosioButton.swift
//  Eosio
//
//  Created by Steve McCoole on 10/25/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//
import Foundation
import UIKit

@IBDesignable

class EosioButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        self.titleLabel?.font = sourceSansProBold18
        self.setTitleColor(UIColor.white, for: .normal)
        self.backgroundColor = UIColor.customNavyBlue
        self.layer.cornerRadius = 6
    }
    
    //required method to present changes in IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupViews()
    }
    
}
