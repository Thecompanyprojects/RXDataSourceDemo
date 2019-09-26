//
//  AppDelegate+Extensions.swift
//
//
//  Created 2018/11/22.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import UIKit
import UserNotifications

import IQKeyboardManagerSwift



extension AppDelegate {
    @discardableResult func openSelf(url: URL?) -> Bool {
        guard let _url = url,
            let components = NSURLComponents(url: _url, resolvingAgainstBaseURL: true) else {
            return false
        }
        if var path = components.path, path != "" {
            if components.query != nil {
                path += "?" + components.query!
            }
            if _url.path.contains("app/open.php") {
                if let toPath = _url.queryParameters("path")?.removingPercentEncoding {
                    path = toPath
                } else {
                    return true
                }
            }
            notifyReload(path)
        }
        return true
    }
    
    func notifyReload(_ path: String?) {
        guard path != nil else { return }
        
        if let url = AppUtils.getUrlWithPath(path:path){
            AppUtils.jumpToWebView(url: url.absoluteString)
        }
    }
    
    // MARK:- 三方服务处理
    func configThirdServer(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        //keyboard
        IQKeyboardManager.shared.enable = true
        
   
    }
    
   
}

