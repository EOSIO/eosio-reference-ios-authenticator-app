//
//  ConfirmationViewController.swift
//  Eosio
//
//  Created by Adam Halper on 7/3/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit
import LocalAuthentication
import EosioSwift

protocol RicardiansFinshedLoadingDelegate: class {
    func ricardiansDisplaying()
}

class ConfirmationViewController: UIViewController, RicardiansFinshedLoadingDelegate {
   
    
    let minimumTimeRequiredForBiometricsAndSigning:TimeInterval = 10 //Number of seconds before the actual transaction expiration date, that the Approve button will be set to expired and disabled. The Approve button is set to expired before the actual expiration time in order to avoid signing expired transaction, in case the user presses the approve button very close to the transaction expiration time.
    let numberOfSecondsToAdd:TimeInterval = 8 //Number of seconds added back to the transaction expiration time after the user presses the Approve button.
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var accountChainLabel: UILabel!

    @IBOutlet weak var appNameLabel: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var timeoutDisplay: TimeoutDisplay!{
        didSet{
            timeoutDisplay.doWhenExpired {[weak self] in
                self?.updateButton(buttonStatus: false)
                //EosioVault.default.cancelPendingSigningRequest()
                self?.removeObservers()
                self?.rejectButton.setTitle("Go Back", for: .normal)
            }
        }
    }
    
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var appDomainLabel: UILabel!

    @IBOutlet weak var appNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var appNameBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var appNameLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var appNameRightCostraint: NSLayoutConstraint!
    
    var appName = String()
    var appImage = UIImage()
    var appDomain = String()
    var unpackedtrx = EosioTransaction()
    
    var reply: ((Bool)->Void)?
    var chainID = String()
    var accounts = [String]()
    var chainName = String()
    var chainIconImage = UIImage()
    
    var requestExpiration:Date?
    var requestStart:Date!
    
    var securityExclusionIconIntegrity = false //false means we do the integrity checks on icons
    
    //Enables or Disables the accept button
    func updateButton(buttonStatus: Bool) {
        acceptButton.isEnabled = buttonStatus
        if buttonStatus == true {
            acceptButton.backgroundColor = UIColor.customNavyBlue
        } else {
            acceptButton.backgroundColor = UIColor.customLightGray
        }
    }
    
    func getAccounts(){
        let actionArray = unpackedtrx.actions
        for action in actionArray {
            let authArray = action.authorization
            
            for auth in authArray {
                let actor = auth.actor
                print("actor is ...\(actor)")
                if !accounts.contains(actor.string) {
                    accounts.append(actor.string)
                }
            }
        }
    }
    
    func createSigningAsLabel(){
        print("total # of actors is ...\(accounts.count)\n\n")
        let signatureString = NSMutableAttributedString()
        let chainString = NSMutableAttributedString()
        switch accounts.count {
        case 0:
            accountChainLabel.text = "ERROR: NO AUTHORIZER CAN SIGN"
            return
        case 1:
            signatureString.normal("Signing as")
            signatureString.bold(" \(accounts[0]) ")
            accountChainLabel.attributedText = signatureString
        case 2:
            signatureString.normal("Signing as")
            signatureString.bold(" \(accounts[0]) ")
            signatureString.normal("and")
            signatureString.bold(" \(accounts[1]) ")
            accountChainLabel.attributedText = signatureString
        default:
            signatureString.normal("Signing as")
            signatureString.bold(" \(accounts[0]) ")
            signatureString.normal(",")
            signatureString.bold(" \(accounts[1]) ")
            signatureString.normal(",")
            signatureString.bold(" + \(accounts.count - 2) more ")
            accountChainLabel.attributedText = signatureString
        }
        chainString.normal("on ")
        let chainStringPrefixLength = chainString.length
        chainString.bold("  \(self.chainName)")
        let attachment = NSTextAttachment()
        attachment.image = chainIconImage
        attachment.bounds = CGRect(x: 0, y: -4, width: 20, height: 20)
        let attachmentString = NSAttributedString(attachment: attachment)
        chainString.insert(attachmentString, at: chainStringPrefixLength)
        let originalSignatureStringLength = signatureString.length
        accountChainLabel.attributedText = signatureString
        let numberOfLinesBeforeAddingChainName = accountChainLabel.numberOfVisibleLines()
        signatureString.append(chainString)
        accountChainLabel.attributedText = signatureString
        if accountChainLabel.numberOfVisibleLines() != numberOfLinesBeforeAddingChainName {
            let lineBreak = NSAttributedString(string: "\n")
            signatureString.insert(lineBreak, at: originalSignatureStringLength)
            accountChainLabel.attributedText = signatureString
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let childViewController = segue.destination as! RicardianViewController
        //pass down the securityExclusion setting
        childViewController.securityExclusionIconIntegrity = self.securityExclusionIconIntegrity
        childViewController.ricardiansFinshedLoadingDelegate = self
        childViewController.unpackedtrx = unpackedtrx
    }
    
    
    
    
    
    
    /**
    Observation objects that are set by setupAcceptButtonTimer() function and used by removeObservers() function to remove observers later.
     */
    
    var appDidBecomeActiveObserver:NSObjectProtocol?
    var appDidEnterBackgroundObserver:NSObjectProtocol?
    
    
    /**
     Sets up and starts AcceptButton animation and adds observers to NotificationCenter to listen to UIApplication.didBecomeActiveNotification and NotificationAppWillResignActive system notifications, so that the animation location can be set correctly if the application goes to background and comes back to foreground later.
 
    */
    
    func setupTimoutDisplay() {
        requestStart = Date()

        requestExpiration = Date(timeInterval: -minimumTimeRequiredForBiometricsAndSigning, since: unpackedtrx.expiration)

        
        
        //requestExpiration = Date(timeIntervalSinceNow: 30)
        guard let requestExpiration = requestExpiration else {
            print("Can't create Date from request expiration string.")
            return
        }
        
        
        
        let timeUntilTransactionExpiration = requestExpiration.timeIntervalSinceNow
        if timeUntilTransactionExpiration < minimumTimeRequiredForBiometricsAndSigning{
            timeoutDisplay.setToExpired()
            rejectButton.setTitle("Go Back", for: .normal)
            return
        }
        timeoutDisplay.startAnimation(expirationTime: requestExpiration)
        
        
        appDidBecomeActiveObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) {[weak self] (note) in
            guard let self = self, self.timeoutDisplay.animationStarted else{
                return
            }
            
            if requestExpiration.timeIntervalSinceNow <= 0{
                
                self.timeoutDisplay.setToExpired()
                self.rejectButton.setTitle("Go Back", for: .normal)
                return
            }
            
            let fraction = CGFloat(requestExpiration.timeIntervalSinceNow / (requestExpiration.timeIntervalSince(self.requestStart)))
            
            self.timeoutDisplay.continueAnimation(withFractionComplete: fraction, expirationTime: requestExpiration)
            
        }
        
        appDidEnterBackgroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) {[weak self] (note) in
            guard let self = self else{
                return
            }
            
            self.timeoutDisplay.stopAnimation()
        }
        
    }
    
    
    /**
     Removes the observers from the NotificationCenter which are set by setupAcceptButtonTimer() function.
    */
    
    func removeObservers() {
        guard let appDidBecomeActiveObserver = appDidBecomeActiveObserver, let appWillResignActiveObserver = appDidEnterBackgroundObserver else {
            return
        }
        
        NotificationCenter.default.removeObserver(appDidBecomeActiveObserver)
        NotificationCenter.default.removeObserver(appWillResignActiveObserver)
    }
                
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAccounts()
        appNameLabel.text = appName
        appDomainLabel.text = appDomain
        appIcon.image = appImage
        appIcon.layer.cornerRadius = 16
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        createSigningAsLabel()
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barStyle = .default
        //acceptButton.stopAnimation()
    }
    
    
    @IBAction func acceptButtonPressed(_ sender: Any) {
        removeObservers()
        guard let requestExpiration = requestExpiration else {
            print("Error: No request expiration.")
            return
        }
        //Adjust/add time to expiration time
        let newRequestExpiration = Date(timeInterval: numberOfSecondsToAdd, since: requestExpiration)
        let fraction = CGFloat(newRequestExpiration.timeIntervalSinceNow / (newRequestExpiration.timeIntervalSince(self.requestStart)))
        self.timeoutDisplay.continueAnimation(withFractionComplete: fraction, expirationTime: newRequestExpiration)
        
        //let fractionToRewind = self.numberOfSecondsToAdd / self.timeoutDisplay.duration
        //let fractionComplete = self.timeoutDisplay.completedAnimationFraction - CGFloat(fractionToRewind)
        //self.timeoutDisplay.continueAnimation(withFractionComplete: fractionComplete, expirationTime: requestExpiration!)
        self.reply?(true)
    }
    
    @IBAction func declineButtonPressed(_ sender: UIButton) {
        removeObservers()
        self.dismiss(animated: true)
        reply?(false)
    }

    
    
    // MARK: - RicardiansFinshedLoadingDelegate functions
    func ricardiansDisplaying() {
        setupTimoutDisplay()
    }
        
}



