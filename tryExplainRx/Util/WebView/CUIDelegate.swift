//
//  CUIDelegate.swift
//
//
//  Created 2018/8/10.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import WebKit


class CUIDelegate: NSObject, WKUIDelegate {
    
    private weak var viewController: UIViewController?
    
    override convenience init() {
        self.init(viewController: nil)
    }
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        //解决window open被拦截问题
        if let url = navigationAction.request.url {
            let urlPath = url.absoluteString
            if urlPath.contains("https://") || urlPath.contains("http://") {
                webView.load(URLRequest(url: url))
            }
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        VVAlert.alert(title: nil, message: message, dismissTitle: "OK", inViewController: self.viewController, withDismissAction: completionHandler)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        VVAlert.confirmOrCancel(title: nil, message: message, confirmTitle: "Confirm", cancelTitle: "Cancel", inViewController: self.viewController, withConfirmAction: { () in
            completionHandler(true)
        }, cancelAction: {() in
            completionHandler(false)
        })
    }
    
}
