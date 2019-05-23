//
//  SignatureRequestViewController.swift
//
//  Created by Todd Bowden on 10/11/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit
import EosioSwift
import EosioSwiftReferenceAuthenticatorSignatureProvider

class AuthenticatorRequestViewController: UIViewController {
    
    static func isAuthenticatorRequest(url: URL) -> Bool {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let host = components?.host ?? ""
        return ["transaction-signature-request","request"].contains(host)
    }
    
    let session = URLSession(configuration: .default)
    private let url: URL
    private let sourceApp: String?
    private let ricardianViewController = ConfirmationViewController()
    private var requestPayload: EosioReferenceAuthenticatorSignatureProvider.RequestPayload?

    
    private lazy var activityIndicator:ActivityIndicatorWithTimeoutMessage = {
        let activityIndicator = ActivityIndicatorWithTimeoutMessage()
        activityIndicator.firstMessageTimeout = 2
        activityIndicator.firstTitle = "Almost there..."
        activityIndicator.firstSubtitle = "We're running some security checks."
        activityIndicator.secondMessageTimeout = 10
        activityIndicator.secondTitle = "This is Taking Longer Than Usual"
        activityIndicator.secondSubtitle = "Feel free to keep waiting or go back and try again."
        
        activityIndicator.titleLabel.textColor = UIColor(displayP3Red: 26/255, green: 50/255, blue: 122/255, alpha: 1)
        activityIndicator.subTitleLabel.textColor = UIColor(displayP3Red: 96/255, green: 124/255, blue: 159/255, alpha: 1)
        activityIndicator.titleLabel.font = sourceSansProBold36
        activityIndicator.subTitleLabel.font = sourceSansPro16
        activityIndicator.button.tintColor = .white
        activityIndicator.button.setTitle("Go Back", for: .normal)
        activityIndicator.button.layer.cornerRadius = 6
        activityIndicator.button.titleLabel?.font = sourceSansProBold16
        activityIndicator.button.backgroundColor = UIColor(displayP3Red: 26/255, green: 50/255, blue: 122/255, alpha: 1)
        activityIndicator.doOnCancel { [weak self] in
            guard let self = self, let requestPayload = self.requestPayload else {
                return
            }
            var responsePayload = EosioReferenceAuthenticatorSignatureProvider.ResponsePayload()
            responsePayload.id = requestPayload.id
            var selectiveDisclosureResponse = EosioReferenceAuthenticatorSignatureProvider.SelectiveDisclosureResponse()
            selectiveDisclosureResponse.error = EosioError(EosioErrorCode.signatureProviderError, reason: "User Declined")
            responsePayload.response.selectiveDisclosure = selectiveDisclosureResponse
            responsePayload.response.transactionSignature?.error = EosioError(EosioErrorCode.signatureProviderError, reason: "User Declined")
            self.sendResponse(requestPayload: requestPayload, responsePayload: responsePayload)
        }
        return activityIndicator
    }()
    
    init(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) {
        self.url = url
        self.sourceApp = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        //Add the activity indicator
        self.view.addSubview(activityIndicator)
       
        
        guard self.sourceApp != nil else {
            self.showMalformedRequestError(error: AppError(AppErrorCode.malformedRequestError, reason: "Unable to identify requesting app"))
            return
        }
        
        parseRequestPayload()
        
        handleRequest(progress: { [weak self] dataFetcher, dataFetcherState in
            guard let strongSelf = self else { return }
            
            let fetcher = dataFetcher
            let networkOfflineVC = UIStoryboard(name: "ErrorScreens", bundle: nil).instantiateViewController(withIdentifier: "NetworkOfflineViewController") as! NetworkOfflineViewController
            
            switch dataFetcherState {
            case DataFetcherState.WaitingForNetwork:
                networkOfflineVC.networkOnline = {
                    strongSelf.navigationController?.popViewController(animated: true)
                }
                
                networkOfflineVC.userCancelled = {
                    strongSelf.navigationController?.popViewController(animated: true, completion: {
                        fetcher.cancelCurrentTask()
                    })
                }
                strongSelf.navigationController?.pushViewController(networkOfflineVC, animated: true)
                
            case DataFetcherState.NotConnectedToInternet:
                
                networkOfflineVC.networkOnline = {
                    strongSelf.navigationController?.popViewController(animated: true, completion: {
                        fetcher.retryCurrentTask()
                    })
                }
                
                networkOfflineVC.userCancelled = {
                    strongSelf.navigationController?.popViewController(animated: true, completion: {
                        fetcher.cancelCurrentTask()
                    })
                }
                
                self?.navigationController?.pushViewController(networkOfflineVC, animated: true)
            default:
                break
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutIfNeeded()
        activityIndicator.startCountDown()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        activityIndicator.removeFromSuperview()
    }
    
    private func parseRequestPayload(){
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            self.showMalformedRequestError(error: AppError(AppErrorCode.malformedRequestError, reason: "Request URL invalid. Cannnot be parsed into URL Compnents"))
            return
        }
        
        guard let queryItems = urlComponents.queryItems else {
            self.showMalformedRequestError(error: AppError(AppErrorCode.malformedRequestError, reason: "Request URL has no query items."))
            return
        }
        
        guard let payloadHex = queryItems.dictionary["payload"] else {
            self.showMalformedRequestError(error: AppError(AppErrorCode.malformedRequestError, reason: "Request URL has no proper request payload in query items"))
            return
        }
        
        guard let payloadData = Data(hexString: payloadHex) else {
            self.showMalformedRequestError(error: AppError(AppErrorCode.malformedRequestError, reason: "Request payload cannot be converted from hex"))
            return
        }
        
        
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        requestPayload = try? jsonDecoder.decode(EosioReferenceAuthenticatorSignatureProvider.RequestPayload.self, from: payloadData)
        if requestPayload == nil {
            self.showMalformedRequestError(error: AppError(AppErrorCode.malformedRequestError, reason: "Request payload JSON does not conform to EosioMobileAuthenticatorSignatureProvider.RequestPayload"))
            return
        }
    }
    
    func handleRequest(progress: ((DataFetcher, DataFetcherState) -> Void)? = nil) {
        
        guard let requestPayload = requestPayload, let sourceApp = sourceApp else {
            return
        }
        let appManifestProvider = AppManifestProvider()
        
        if let activeSecurityExclusions = getActiveSecurityExclusions() {
            appManifestProvider.securityExclusionAppMetadataIntegrity = activeSecurityExclusions.appMetadataIntegrity
            appManifestProvider.securityExclusionIconIntegrity = activeSecurityExclusions.iconIntegrity
            appManifestProvider.securityExclusionDomainMatch = activeSecurityExclusions.domainMatch
        }
        
        let requireChainId = requestPayload.request.transactionSignature != nil
        
        appManifestProvider.getAppManifest(payload: requestPayload, requireChainId: requireChainId, requireHashIntegrity: true, completion: { [weak self] (manifest, manifestError) in
            guard let strongSelf = self else { return }
            
            // check for a valid manifest
            // if no valid manifest, decide if the error is returnable to the requesting app, if not show malformedRequest screen
            guard let manifest = manifest else {
                let manifestError: AppError = manifestError ?? AppError(.metadataError, reason: "manifest error", isReturnable: false)
                if manifestError.isReturnable {
                    let returnableError = EosioError(.signatureProviderError, reason: manifestError.reason)
                    var responsePayload = EosioReferenceAuthenticatorSignatureProvider.ResponsePayload()
                    responsePayload.id = requestPayload.id
                    if requestPayload.request.selectiveDisclosure != nil {
                        responsePayload.response.selectiveDisclosure = EosioReferenceAuthenticatorSignatureProvider.SelectiveDisclosureResponse(error: returnableError)
                    }
                    if requestPayload.request.transactionSignature != nil {
                        responsePayload.response.transactionSignature = EosioReferenceAuthenticatorSignatureProvider.TransactionSignatureResponse(error: returnableError)
                    }
                    strongSelf.sendResponse(requestPayload: requestPayload, responsePayload: responsePayload)
                } else {
                    strongSelf.showMalformedRequestError(error: manifestError)
                }
                return
            }
            
            // validate the source app identifier is declared in the metadata for native apps
            // and the returnUrl domain matches the manifest domain for web apps and universal links
            if let validationError = strongSelf.validateSourceAppAndReturnUrl(sourceApp: sourceApp, returnUrlString: requestPayload.returnUrl, manifest: manifest) {
                return strongSelf.showMalformedRequestError(error: validationError)
            }
            
            // handle SelectiveDisclosureRequest
            strongSelf.handleSelectiveDisclosureRequest(payload: requestPayload, manifest: manifest, completion: { (selectiveDisclosureResponse) in
                // handle TransactionSignatureRequest
                strongSelf.handleTransactionSignatureRequest(payload: requestPayload, manifest: manifest, completion: { (transactionSignatureResponse) in
                    var responsePayload = EosioReferenceAuthenticatorSignatureProvider.ResponsePayload()
                    responsePayload.id = requestPayload.id
                    responsePayload.response.selectiveDisclosure = selectiveDisclosureResponse
                    if let transactionSignatureResponse = transactionSignatureResponse {
                        responsePayload.response.transactionSignature = EosioReferenceAuthenticatorSignatureProvider.TransactionSignatureResponse(eosioTransactionSignatureResponse: transactionSignatureResponse)
                    }
                    print(responsePayload)
                    strongSelf.sendResponse(requestPayload: requestPayload, responsePayload: responsePayload)
                })
            })
            
            }, progress: progress)
        
    }

    
    func validateSourceAppAndReturnUrl(sourceApp: String, returnUrlString: String, manifest: AppManifest) -> AppError? {

        guard let returnUrl = URL(string: returnUrlString) else {
            return AppError(.domainError, reason: "Invalid return url \(returnUrlString)", isReturnable: false)
        }
        guard let returnUrlScheme = returnUrl.scheme?.lowercased() else {
            return AppError(.domainError, reason: "Invalid scheme for return url \(returnUrlString)", isReturnable: false)
        }
        
        // if returnUrlScheme is http/https validate the domain
        if returnUrlScheme == "http" || returnUrlScheme == "https" {
            
            guard let returnDomain = returnUrlString.urlDomain else {
                return AppError(.domainError, reason: "Invalid return url", isReturnable: false)
            }
            
            guard let manifestDomain = manifest.domain.urlDomain else {
                return AppError(.domainError, reason: "Invalid manifest domain", isReturnable: false)
            }
            
            if let secuityExclusions = getActiveSecurityExclusions() {
                
                //icon integrity checks happen deep in the process, need to pass this down starting here
                self.ricardianViewController.securityExclusionIconIntegrity = secuityExclusions.iconIntegrity
                
                //need to be careful here as the security exclsuions model boolean logic is reversed from what one would expect.  e.g. if domainMatch is true then that true means it is exluded and the checking should not be done!
                if secuityExclusions.domainMatch == false {
                    
                    guard manifestDomain == returnDomain else {
                        return AppError(.domainError, reason: "Domain of return url \(returnDomain) does not match domain \(manifestDomain) declared the app manifest.", isReturnable: false)
                    }
                 }
                
            } else {
                
                guard manifestDomain == returnDomain else {
                    return AppError(.domainError, reason: "Domain of return url \(returnDomain) does not match domain \(manifestDomain) declared the app manifest.", isReturnable: false)
                }
            }
        }
        
        // if sourceApp is not mobile safari, validate the app identifier
        if sourceApp != "com.apple.mobilesafari" {
            guard let appIdentifiers = manifest.metadata.appIdentifiers else {
                return AppError(AppErrorCode.metadataError, reason: "No app identifiers declared in the app metadata.", isReturnable: false)
            }
            guard appIdentifiers.contains(sourceApp) else {
                return AppError(AppErrorCode.metadataError, reason: "App bundle id \(sourceApp) does not match any identifiers declared in the app metadata. \(appIdentifiers)", isReturnable: false)
            }
            // possibly validate the returnUrl scheme for a native app matches schemes declared in the app metadata
        }
        
        // if no errors found return nil
        return nil
    }
    

	func sendResponse(requestPayload: EosioReferenceAuthenticatorSignatureProvider.RequestPayload,
                  responsePayload: EosioReferenceAuthenticatorSignatureProvider.ResponsePayload) {
    
    	// validate callback domain == manifest domain here? (or has this already been done)
    	if let callbackUrl = requestPayload.callbackUrl {
        	print("CALL BACK URL FOUND")
        	print("RETURN URL = \(requestPayload.returnUrl)")
        
        	guard let payloadHex = responsePayload.toHex else { return }
        	var returnUrl = requestPayload.returnUrl
        	if sourceApp == "com.google.chrome.ios" {
            	returnUrl = "googlechrome://"
        	} else {
            	returnUrl = (returnUrl.components(separatedBy: "#").first ?? "")
            	returnUrl = returnUrl + "#" + payloadHex
            	guard let url = URL(string: returnUrl) else { return }
            	DispatchQueue.main.async {
                	UIApplication.shared.open(url, options: [:].convertToUIApplicationOpenExternalURLOptionsKeyDictionary(), completionHandler: nil)
                    if let vcBeforeAuth = self.navigationController?.viewControllerBefore(className: String(describing: type(of: self))) {
                        self.navigationController?.popToViewController(vcBeforeAuth, animated: false)
                    } else {
                        self.navigationController?.popToRootViewController(animated: false)
                    }
            	}
            	return
        	}
        
        	callback(callbackUrl: callbackUrl, responsePayload: responsePayload) { (didSucceed) in
            	guard let url = URL(string: returnUrl) else { return }
            	DispatchQueue.main.async {
                	UIApplication.shared.open(url, options: [:].convertToUIApplicationOpenExternalURLOptionsKeyDictionary(), completionHandler: nil)
                    if let vcBeforeAuth = self.navigationController?.viewControllerBefore(className: String(describing: type(of: self))) {
                        self.navigationController?.popToViewController(vcBeforeAuth, animated: false)
                    } else {
                        self.navigationController?.popToRootViewController(animated: false)
                    }
            	}
        	}
        
    	} else {
        	print("SEND REPONSE IN RETURN URL")
        	print(requestPayload.returnUrl)
        	guard let payloadHex = responsePayload.toHex else { return }
        	guard let url = URL(string: requestPayload.returnUrl) else { return }
        	guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        	let queryItem = URLQueryItem(name: "response", value: payloadHex)
        	if urlComponents.queryItems == nil {
            	urlComponents.queryItems = [URLQueryItem]()
        	}
        	urlComponents.queryItems?.append(queryItem)
        	guard let responseUrl = urlComponents.url else { return }
        	DispatchQueue.main.async {
            	UIApplication.shared.open(responseUrl, options: [:].convertToUIApplicationOpenExternalURLOptionsKeyDictionary(), completionHandler: nil)
                if let vcBeforeAuth = self.navigationController?.viewControllerBefore(className: String(describing: type(of: self))) {
                    self.navigationController?.popToViewController(vcBeforeAuth, animated: false)
                } else {
                    self.navigationController?.popToRootViewController(animated: false)
                }
        	}
    	}
	}
    
    
    func callback(callbackUrl: String,
                  responsePayload: EosioReferenceAuthenticatorSignatureProvider.ResponsePayload,
                  completion: @escaping (Bool)->Void) {
        
        // get endpoint URL
        guard let url = URL(string: callbackUrl) else {
            return completion(false)
        }
        
        // create url request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(responsePayload) else {
            return completion(false)
        }
        urlRequest.httpBody = jsonData
        
        // make the network call
        session.dataTask(with: urlRequest) { (urlData, urlResponse, urlError) in
            completion(urlError == nil)
        }.resume()
    }
    
	private func showMalformedRequestError(error: AppError ) {
		
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "ErrorScreens", bundle: nil).instantiateViewController(withIdentifier: "somethingsNotRightErrorViewController") as! SomethingsNotRightErrorViewController
            vc.error = error
            self.navigationController?.setViewControllers([vc], animated: false)
        }
     
	}
    
    // return security exclusions only if insecure mode is on and the request's domain is included in the insecure domain list.
    func getActiveSecurityExclusions() -> SecurityExclusions? {
        
        var retVal:SecurityExclusions?
        
        if  UserDefaults.Eosio.bool(forKey:.insecureMode) == true {
            
            if let requestPayload = self.requestPayload,
                let declaredDomain = requestPayload.declaredDomain,
                DeveloperSettingsViewController.isExceptionDomain(domain: declaredDomain) == true {
                    retVal = requestPayload.securityExclusions
            }
        }
        return retVal
    }
}







