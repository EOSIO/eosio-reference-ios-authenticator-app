//
//  NetworkOfflineViewController.swift
//  Eosio
//
//  Created by Steve McCoole on 12/13/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit
import Reachability

class NetworkOfflineViewController : UIViewController {
    
    @IBOutlet weak var offlineTitle: UILabel!
    @IBOutlet weak var offlineSecondary: UILabel!
    @IBOutlet weak var retryingLabel: UILabel!
    @IBOutlet weak var goBackButton: EosioButton!
    
    private var timeoutSeconds = 30
    private var timer: Timer?
    
    let reachabilityHost = "www.google.com"
    var reachability: Reachability?
    
    var networkOnline : (() -> Void)?
    var userCancelled : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        if let reach = Reachability(hostname: reachabilityHost) {
            self.reachability = reach
            setupReachability()
        } else {
            setupRetryCountdown()
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let reach = self.reachability {
            reach.stopNotifier()
            retryingLabel.layer.removeAllAnimations()
        }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        self.timer?.invalidate()
        self.userCancelled?()
    }
    
    private func setupReachability() {
        let anim : CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 1
        anim.toValue = 0
        anim.duration = 0.75
        anim.autoreverses = true
        anim.repeatCount = Float.infinity
        retryingLabel.layer.add(anim, forKey: "flashOpacity")
        
        // Check if we came back online while getting here
        if reachability?.connection != Reachability.Connection.none {
            networkOnline?()
            return
        }
        
        reachability?.whenReachable = { [weak self] reachability in
            if let strongSelf = self {
                strongSelf.networkOnline?()
            }
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            reachability = nil
            setupRetryCountdown()
        }
    }
    
    private func setupRetryCountdown() {
        updateRetryTimerLabel()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(countdownTick)), userInfo: nil, repeats: true)
    }
    
    @objc private func countdownTick() {
        self.timeoutSeconds -= 1
        updateRetryTimerLabel()
        if self.timeoutSeconds <= 0 {
            timer?.invalidate()
            networkOnline?()
        }
    }
    
    private func updateRetryTimerLabel() {
        self.retryingLabel.text = "Retrying in \(self.timeoutSeconds) seconds"
    }
}
