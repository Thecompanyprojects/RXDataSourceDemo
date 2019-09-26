//
//  BaseNavigationViewController.swift
//
//
//  Created by  on 2018/9/30.
//  Copyright © 2018年  rights reserved.
//

import UIKit

protocol NavigationControllerBackButtonDelegate {
    func shouldPopOnBackButtonPress() -> Bool
}

class BaseNavigationController: UINavigationController, UINavigationBarDelegate {
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        
        if viewControllers.count < (navigationBar.items?.count ?? 0) {
            return true
        }
        
        var shouldPop = true
        if let viewController = topViewController as? NavigationControllerBackButtonDelegate {
            shouldPop = viewController.shouldPopOnBackButtonPress()
        }
        
        if shouldPop {
            DispatchQueue.main.async(execute: {
                self.popViewController(animated: true)
            })
        } else {
            for subview: UIView in navigationBar.subviews {
                if 0.0 < subview.alpha && subview.alpha < 1.0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        subview.alpha = 1.0
                    })
                }
            }
        }
        
        return false
    }
}
