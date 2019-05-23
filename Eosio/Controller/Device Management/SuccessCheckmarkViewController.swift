//
//  SuccessCheckmarkViewController.swift
//  Eosio
//
//  Created by Serguei Vinnitskii on 10/18/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit

class SuccessCheckmarkViewController: UIViewController {

    var dismissButtonPressed: (()->())?

    @IBOutlet weak var whiteBackground: UIView!
    @IBOutlet weak var checkmarkOutterCircle: UIImageView!
    @IBOutlet weak var checkmarkInnerCircle: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    //constraints
    @IBOutlet weak var backgroundHeight: NSLayoutConstraint!
    @IBOutlet weak var backgroundWidth: NSLayoutConstraint!
    @IBOutlet weak var checkmarkOutterCircleHeight: NSLayoutConstraint!
    @IBOutlet weak var checkmarkOutterCircleWidth: NSLayoutConstraint!
    @IBOutlet weak var checkmarkInnerCircleHeight: NSLayoutConstraint!
    @IBOutlet weak var checkmarkInnerCircleWidth: NSLayoutConstraint!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        self.checkmarkOutterCircle.isHidden = true
        self.checkmarkInnerCircle.isHidden = true
        self.messageLabel.isHidden = true
        self.checkmarkOutterCircleWidth.constant = 0
        self.checkmarkOutterCircleHeight.constant = 0
        self.checkmarkInnerCircleHeight.constant = 0
        self.checkmarkInnerCircleWidth.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.backgroundWidth.constant = self.view.frame.width
        self.backgroundHeight.constant = self.view.frame.height

        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { _ in

            self.checkmarkOutterCircle.isHidden = false
            self.checkmarkInnerCircle.isHidden = false
            self.checkmarkOutterCircleHeight.constant = 156
            self.checkmarkOutterCircleWidth.constant = 156

            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                self.messageLabel.isHidden = false
                self.checkmarkInnerCircleHeight.constant = 112
                self.checkmarkInnerCircleWidth.constant = 112

                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                }) { _ in
                }
            }
        }
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: false) { self.dismissButtonPressed?() }
    }

}
