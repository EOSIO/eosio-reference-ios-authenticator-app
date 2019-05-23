//
//  UIWindowExtensions.swift
//  EosioReferenceAuthenticator
//
//  Created by Steve McCoole on 1/4/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    
    func getCurrentViewController() -> UIViewController? {
        
        guard let rootVC = self.rootViewController else {
            return nil
        }
    
        if let presentedVC = rootVC.presentedViewController {
            return presentedVC
        } else if let splitVC = rootVC as? UISplitViewController, splitVC.viewControllers.count > 0 {
            return splitVC.viewControllers.last!
        } else if let navController = rootVC as? UINavigationController, navController.viewControllers.count > 0 {
            return navController.topViewController!
        } else if let tabBarController = rootVC as? UITabBarController, let selectedVC = tabBarController.selectedViewController {
            return selectedVC
        }
        
        return rootVC
    }

}
