//
//  JSBridgeRegisterHandler.swift
//
//
//  Created by  on 2018/8/9.
//  Copyright © 2018年  rights reserved.
//

import Foundation

class JSBridgeRegisterHandler {
    public var webView: CWebView
    public var webViewController: WebViewController
    
    init(webview: CWebView, webViewController: WebViewController) {
        self.webView = webview
        self.webViewController = webViewController
    }

    
    public func JsBridgeRegister() {
        self.webView.JsBridge.register(handlerName: "SELECT_LANG") { data in
            
            guard data != nil else {return}
            guard let lang = data!["lang"] as! String?, lang != AppUtils.getUserLanguage() else {return}
            //AppUtils.setUserLanguage(lang: lang)
            self.webViewController.refreshControl.attributedTitle = NSAttributedString(string: "loading")
            
        }
        self.webView.JsBridge.register(handlerName: "SET_LOADING_STATUS") { data in
            guard data != nil else {return}
            let status = data!["status"] as! Bool
            if(!status) {
                DispatchQueue.main.async {
                    self.webViewController.hideLoading()
                }
            }
        }
        self.webView.JsBridge.register(handlerName: "PAGE_BACK") { data in
            if (self.webView.canGoBack) {
                HistoryManager.goBack(webView: self.webView)
            } else if ((self.webViewController.navigationController?.viewControllers.count) != nil) && (self.webViewController.navigationController?.viewControllers.count)! <= 1 {
                self.webViewController.loadUrl(url: URL(string: AppConfig.HOME + AppUtils.getLangSuffix())!)
            } else {
                
                self.webViewController.navigationController?.popViewController(animated: true)
            }
        }
        self.webView.JsBridge.register(handlerName: "GO_TO_PATH") { (data) in
            guard data != nil else {
                return
            }
            if let name = data!["name"],name as! String == "register" {
                AppUtils.gotoRegister()
            }
            if let name = data!["name"],name as! String == "login" {
                AppUtils.gotoLogin()
            }
        }
    
        self.webView.JsBridge.register(handlerName: "APP_POST") { data in
            guard data != nil, let postData = data!["PostData"] else {
                return
            }
            if let postDic = postData as? [String: Any?], let identifier = postDic["identifier"] as? String  {
                //目前不判断源， 直接使用third controller
                if let restPage = postDic["restPage"] as? Int {
                    //重置表单并回退重复的历史
                    self.webViewController.restPage(restPage)
                }
                self.webViewController.performSegue(withIdentifier: identifier, sender: postData)
            }
        }
        self.webView.JsBridge.register(handlerName: "CAN_SWIPE_REFRESH", handler: {data in
            guard data != nil, let status = data!["status"] as? Bool, let tag = data!["tag"] as? String else {return}
            if tag == "filter" {
                self.webViewController.scrollView.bounces = status
            }
        })
        
    }
}
