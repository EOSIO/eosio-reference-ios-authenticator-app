//
//  UINavigationControllerExtensions.swift
//  EosioReferenceAuthenticator
//
//  Created by Steve McCoole on 1/10/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    public func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    public func viewControllerBefore(className: String) -> UIViewController?  {
        // Find the first viewcontroller of the type we specify in the argument and return the viewcontroller
        // that is before it on the stack so that we can popToViewController to return to where we were before
        // starting a specific request.
        if let foundIndex = self.viewControllers.index(where: { String(describing: type(of: $0)) == className }) {
            let before = foundIndex > 0 ? foundIndex - 1 : foundIndex
            return self.viewControllers[before]
        } else {
            return nil
        }
    }
}
