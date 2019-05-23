//
//  RicardianViewController.swift
//  EosioReferenceAuthenticator
//
//  Created by Ben Martell on 1/15/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit
import WebKit
import EosioSwift

let ricardianCache = NSCache<NSString, NSString>()

protocol RicardianWebViewsRenderedDelegate: class {
    func ricardianWebViewRendered()
}

class RicardianViewController: UIViewController, RicardianWebViewsRenderedDelegate  {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    var confirmVC: ConfirmationViewController?
    var actionData = [ActionData]()
    var webViewsLoaded = 0
    var unpackedtrx = EosioTransaction()
    
    var ricardiansFinshedLoadingDelegate: RicardiansFinshedLoadingDelegate?
    
    var ricardianActionViewsRendered: Int = 0
    
    var securityExclusionIconIntegrity = false //false means we do the integrity checks on icons
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        actionData = createActionData()
        debugPrint("actionDataTable created")
        setUpActionViews()
        stackViewHeightConstraint.isActive = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        debugPrint("viewWillAppear")
        confirmVC = self.parent as? ConfirmationViewController
        if actionData.count > 0 {
            confirmVC?.updateButton(buttonStatus: true)
        } else {
            confirmVC?.updateButton(buttonStatus: false)
        }
    }
    
    //Create and setup the stacked views
    func setUpActionViews() {
        
        let shouldShow =  actionData.count > 1 ? false : true
        for actionCellData in actionData {
            let ricardianActionView =  RicardianActionView(frame: .zero)
            ricardianActionView.ricardianWebViewsRenderedDelegate = self
            self.contentStackView.addArrangedSubview(ricardianActionView)
            ricardianActionView.setUpView(action: actionCellData, showContract: shouldShow)
        }
        
        debugPrint("\(actionData.count) RicardianViews added")
    }
    
    //Converts an unpackedTransaction into an array of actioncelldata objects ready for tableview
    func createActionData() -> [ActionData] {
        
        var actionDataArray = [ActionData]()

        var unpackedActionArray = unpackedtrx.actions
        if ProcessInfo.processInfo.environment["SHOW_ASSERT_ACTION"] == nil {
            unpackedActionArray = unpackedtrx.actions .filter {$0.isAssertRequire == false} // discard assert actions
        }
        for actionData in unpackedActionArray {
            
            let account = actionData.account
            
            var summary = "[Missing Summary]"
            var title = "[" + actionData.name.string + "]"
            var icon = ""
            
            if let metaData = actionData.ricardian?.metadata {
                if metaData.summary.count > 0 {
                    summary = metaData.summary
                }
                if metaData.title.count > 0 {
                    title = metaData.title
                }
                if metaData.icon.count > 0 {
                    icon = metaData.icon
                }
            }
            
            if let ricardianHTML = actionData.ricardian?.html {
                let actionData = ActionData(account: account.string, summary: summary, title: title, icon: icon, html: ricardianHTML )
                actionData.securityExclusionIconIntegrity = self.securityExclusionIconIntegrity
                actionDataArray.append(actionData)                
            }
        }
        return actionDataArray
    }
    
    // MARK: - RicardianWebViewsRenderedDelegate functions
    func ricardianWebViewRendered() {
        
        self.ricardianActionViewsRendered = self.ricardianActionViewsRendered  + 1
        
        if self.ricardianActionViewsRendered == self.contentStackView.arrangedSubviews.count {
            
            self.ricardiansFinshedLoadingDelegate?.ricardiansDisplaying()
        }
        
    }
}

