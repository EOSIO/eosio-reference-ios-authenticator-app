//
//  AppDelegate.swift
//  Eosio
//
//  Created by Adam Halper on 6/29/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    var navigationController: UINavigationController?
    var useEmbeddedBrowser: Bool = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.isTranslucent = false
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "authorizersListVC") as! AuthorizersListViewController
        self.navigationController = UINavigationController(rootViewController: vc)
    
        // Configure NavigationBar
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.titleTextAttributes = EosioAppearance.navBarTitleAttributes
        self.navigationController?.navigationBar.largeTitleTextAttributes = EosioAppearance.navBarLargeTitleAttributes
        self.navigationController?.navigationBar.tintColor = UIColor.customDarkBlue
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") // removes bottom line on NavBar (to show it, set value back to false)
        self.window?.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        
        // This has to be handled specially because the ImportKeyTableViewController is presented modally but with its
        // own UINavigationController in order to have a UINavigationBar on it, but it can also have another modal
        // overlayed on it after successfully adding a new key.  This makes it more difficult to determine what to do
        // with the stack in order to reset it properly but this will work.  Technically we should not have another
        // UINavigationController in the app for this, its usually only done for UITabbarControllers or UISplitViewController.
        // If another base view controller starts a multiple modal stack like this, it will have to be dealt with
        // specifically as well.
        if let vc = self.navigationController?.viewControllers.first, type(of: vc) == AuthorizersListViewController.self, vc.presentedViewController != nil {
            vc.dismiss(animated: false, completion: nil)
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "authorizersListVC") as! AuthorizersListViewController
        
        if AuthenticatorRequestViewController.isAuthenticatorRequest(url: url) {
            let transactionSignatureRequestViewController = AuthenticatorRequestViewController(url: url, options: options)
            if (self.navigationController?.viewControllerBefore(className: String(describing: type(of: transactionSignatureRequestViewController)))) != nil {
                self.navigationController?.setViewControllers([vc, transactionSignatureRequestViewController], animated: false)
            } else {
                self.navigationController?.pushViewController(transactionSignatureRequestViewController, animated: false)
            }
            return true
        }
        
        self.navigationController?.setViewControllers([vc], animated: true)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        DataManager.shared.saveContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DataManager.shared.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
      
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let laContext = LAContext()
        var error: NSError?
        guard laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Go to biometric not on device or biometric needs enrollment screen
            print("Error evaulating biometric: \(String(describing: error))")
            guard let err = error else {
                fatalError("LAContext.canEvaluatePolicy returned false without setting an error.  Don't know how to proceed.")
            }
            
            //Changed to use the objc style error codes to avoid warning by Apple's LAError bug. NOTE: when this is fixed in the Swift frameworks we can revert back to using the Swift LAError enums raw values
            if err.code == kLAErrorBiometryNotAvailable && laContext.biometryType == .none {
                let noBioVc = UIStoryboard(name: "Biometrics", bundle: nil).instantiateViewController(withIdentifier: "NoBioController") as! NoBiometricsViewController
                self.navigationController?.setViewControllers([noBioVc], animated: true)
            } else if err.code == kLAErrorBiometryNotEnrolled ||
                      err.code == kLAErrorPasscodeNotSet ||
                      (err.code == kLAErrorBiometryNotAvailable && laContext.biometryType != .none) {
                let enrollBioVc = UIStoryboard(name: "Biometrics", bundle: nil).instantiateViewController(withIdentifier: "BioEnrollmentController") as! BiometricEnrollmentViewController
                enrollBioVc.error = err
                enrollBioVc.biometricType = laContext.biometryType
                self.navigationController?.setViewControllers([enrollBioVc], animated: true)
               
            } else {
                fatalError("LAcontext.canEvaluatePolicy returned unknown error, don't know how to proceed.")
            }
            
            return
        }
        
        if let vc = self.navigationController?.viewControllers.first, (type(of: vc) == NoBiometricsViewController.self || type(of: vc) == BiometricEnrollmentViewController.self) {
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "authorizersListVC") as! AuthorizersListViewController
            self.navigationController?.setViewControllers([vc], animated: false)
        }

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DataManager.shared.saveContext()
    }
    
    
    
    
}


