//
//  JavaScriptBridge.swift
//
//
//  Created 2018/8/6.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import WebKit

public class JavascriptBridge: NSObject {
    private weak var webView: WKWebView?
    private var base: JavascriptBridgeBase!
    
    public init(webView: WKWebView) {
        super.init()
        self.webView = webView
        base = JavascriptBridgeBase()
        base.delegate = self
        addScriptMessageHandlers()
        base.inject()
    }
    deinit {
        removeScriptMessageHandlers()
    }
    
    public func register(handlerName: String, handler: @escaping JavascriptBridgeBase.Handler) {
        //保证相同方法名 不被重复注册
        guard base.messageHandlers[handlerName] == nil else {
            return
        }
        base.messageHandlers[handlerName] = handler
    }
    
    public func call(handlerName: String, data: Any? = nil) {
        base.send(handlerName: handlerName, data: data)
    }
    
    public func response(messageId: String, data: Any? = nil) {
        base.send(messageId: messageId, data: data)
    }
    
    public func exec(body: Any?) {
        base.exec(body: body)
    }
    
    private func addScriptMessageHandlers() {
        
    }
    private func removeScriptMessageHandlers() {
        
    }
}

extension JavascriptBridge: JavascriptBridgeBaseDelegate, WKScriptMessageHandler {
    func evaluateJavascript(javascript: String) {
        webView?.evaluateJavaScript(javascript, completionHandler: nil)
    }
    
    func addUserScript(_ script: WKUserScript) {

        guard webView != nil else { return }
        webView!.configuration.userContentController.addUserScript(script)
        webView!.evaluateJavaScript(script.source) { (_, _) in }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
       
    }
}


class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    init(delegate: WKScriptMessageHandler) {
        super.init()
        self.delegate = delegate
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
