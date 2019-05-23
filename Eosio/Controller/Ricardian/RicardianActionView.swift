//
//  RicardianActionView.swift
//  EosioReferenceAuthenticator
//
//  Created by Ben Martell on 1/18/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit
import WebKit

class RicardianActionView: UIView, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var contractTitle: UILabel!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var chevron: UIImageView!
    @IBOutlet weak var actionIcon: UIImageView!
    @IBOutlet weak var contractwebViewContainer: UIView!
    @IBOutlet weak var webContainerHeight: NSLayoutConstraint!

    private var contractRenderedHeight:CGFloat = 0.0
    
    private var contractShowing: Bool = true
    var webView: WKWebView! = WebViewPreloader.getWarmedUpWebView()
    
    private var ricardianHtml = String()
    
    var ricardianWebViewsRenderedDelegate: RicardianWebViewsRenderedDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RicardianActionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
        
        webContainerHeight.constant = contractRenderedHeight
        webView.frame.size = CGSize(width: contractwebViewContainer.bounds.width, height: contractRenderedHeight)
    }
    
    func setUpView(action: ActionData, showContract: Bool) {
        
        self.contractShowing = showContract
        let image = contractShowing == true ? UIImage(named: "up-arrow") : UIImage(named: "down-arrow")
        chevron.image = image
        
        contractTitle.text = action.title
        let summaryText = action.summary
        summary.attributedText = interpolateDivs(summary: summaryText)
        accountName.text = action.account
        
        do {
            let image = try ResourceIntegrity.getImage(resourceUrlPath:action.icon, securityExclusionIconIntegrity: action.securityExclusionIconIntegrity)
            actionIcon.image = image
        } catch let error {
            
            //at this point the image was already verified by the data cache.  If it was not retrieved it is because the security exclusion icon toggle is turned off.  The image will not be displayed in this case and nothing else needs to be done here.
            print(error)
        }
        
        if showContract {
            chevron.isHidden = true
        } else {
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
            titleView.addGestureRecognizer(tapGesture)
        }
        
        ricardianHtml = self.buildHTML(ricardianHTML: action.html)
        
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        
        contractwebViewContainer.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: contractwebViewContainer.leadingAnchor, constant: 24).isActive = true
        webView.trailingAnchor.constraint(equalTo: contractwebViewContainer.trailingAnchor, constant: -24).isActive = true
        webView.topAnchor.constraint(equalTo: contractwebViewContainer.topAnchor, constant: 6).isActive = true
        webView.bottomAnchor.constraint(equalTo: contractwebViewContainer.bottomAnchor).isActive = true
    
        //Important! this is set to hidden here for proper intial behavoiur
        contractwebViewContainer.isHidden = true
        webView.loadHTML(fromString: self.ricardianHtml)
    }
    
    func interpolateDivs(summary: String) -> NSAttributedString? {
        let pattern = "\\<div.*?\\>(.*?)\\<.*?div\\>"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let formattedSummary = NSMutableAttributedString(string: summary, attributes: nil)
        let matches = regex?.matches(in: summary, options: .reportProgress, range: NSMakeRange(0, summary.count))
        let nsSummary = summary as NSString
        matches?.reversed().forEach({ match in
            if match.numberOfRanges > 1 {
                let boldString = NSAttributedString(string: nsSummary.substring(with: match.range(at: 1)),
                                                    attributes: [.font : sourceSansProBoldIt15])
                formattedSummary.replaceCharacters(in: match.range, with: boldString)
            }
        })
        return formattedSummary
    }
    
    @IBAction func arrowPressed(_ sender: Any) {
        
        contractShowing.toggle()
        
        if contractShowing {
            showContract()
        } else {
            hideContract()
        }
    }
    
    private func showContract() {
        debugPrint("Show")
        contractShowing = true
            
        let transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.1, animations: {
            self.chevron.transform = transform.rotated(by: 180 * CGFloat(Double.pi))
            self.chevron.transform = transform.rotated(by: -1 * CGFloat(Double.pi))
                
        }, completion: {
            (value: Bool) in
            self.contractwebViewContainer.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.2, animations: {
                self.contractwebViewContainer.isHidden = false
                self.contractwebViewContainer.layoutIfNeeded()
            })
        })
    }

    private func hideContract() {
        debugPrint("Hide")
        contractShowing = false
        UIView.animate(withDuration: 0.1, animations: {
                self.chevron.transform = CGAffineTransform.identity
                self.contractwebViewContainer.layoutIfNeeded()
        }, completion: {
            (value: Bool) in
            
            self.contractwebViewContainer.layoutIfNeeded()
            UIView.animate(withDuration: 0.2, animations: {
                self.contractwebViewContainer.isHidden = true
                self.contractwebViewContainer.layoutIfNeeded()
            })
        })
    }
    
    func buildHTML(ricardianHTML: String) -> String{
        return """
        <html>
        <head>
        <title>Contract Viewport</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
        <link rel="stylesheet" type="text/css" href="iPhone.css">
        </head>
        <body>
        <div id="ricardian">\(ricardianHTML)</div>
        </body>
        </html>
        """
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        //debugPrint("loaded webview")
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            
            if complete != nil {
                webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    
                    debugPrint("document.body.scrollHeight: \(height as! CGFloat)")
                    
                    self.contractRenderedHeight = (height as! CGFloat)
                    
                    webView.frame.size = CGSize(width: self.contractwebViewContainer.bounds.width, height: self.contractRenderedHeight)

                    self.webContainerHeight.constant = self.contractRenderedHeight
                    
                    if self.contractShowing {
                        self.contractwebViewContainer.isHidden = false
                    } else {
                        self.contractwebViewContainer.isHidden = true
                    }
                    
                    self.ricardianWebViewsRenderedDelegate?.ricardianWebViewRendered()
                })
            } else {
                print(error as Any)
            }
            
        })
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        contractShowing.toggle()
        if contractShowing {
            showContract()
        } else {
            hideContract()
        }
    }
}
