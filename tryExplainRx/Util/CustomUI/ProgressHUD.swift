//
//  ProgressHUD.swift
//
//
//  Created by  on 2019/3/18.
//  Copyright © 2019年  rights reserved.
//

import Foundation

import UIKit


enum HUDType {
    case success
    case error
    case loading
    case info
    case progress
    case loadingInView
}

class ProgressHUD: NSObject {
    
    class func showSuccess(_ status: String) {
        self.showMCProgressHUD(type: .success, status: status)
    }
    class func showError(_ status: String) {
        self.showMCProgressHUD(type: .error, status: status)
    }
    class func showLoading() {
        self.showMCProgressHUD(type: .loading, status: "Loading")
    }
    class func showLoadingIn(_ view: UIView) {
        self.showMCProgressHUD(type: .loadingInView, status: "Loading",view:view)
    }
    class func showInfo(_ status: String) {
        self.showMCProgressHUD(type: .info, status: status)
    }
    class func showProgress(_ status: String, _ progress: CGFloat) {
        self.showMCProgressHUD(type: .success, status: status, progress: progress)
    }
    class func dismissHUD(_ delay: TimeInterval = 0) {
        
    }
}

extension ProgressHUD {
    class func showMCProgressHUD(type: HUDType, status: String, progress: CGFloat = 0,view: UIView? = nil) {
       
    }
}

