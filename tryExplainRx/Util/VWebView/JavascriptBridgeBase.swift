//
//  JavascriptBridgeBase.swift
//
//
//  Created 2018/8/6.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import WebKit

protocol JavascriptBridgeBaseDelegate: AnyObject {
    func evaluateJavascript(javascript: String)
    func addUserScript(_ script: WKUserScript)
}

public class JavascriptBridgeBase {
    
    public typealias Handler = (_ parameters: [String: Any]?) -> Void
    public typealias Message = [String: Any]
    
    weak var delegate: JavascriptBridgeBaseDelegate?
    var messageHandlers = [String: Handler]()

    
    func send(handlerName: String, data: Any?) {
        var message = [String: Any]()
        message["handlerName"] = handlerName
        if data != nil {
            message["data"] = data
        }
        dispatch(message: message)
    }
    
    func send(messageId: String, data: Any?) {
        var message = [String: Any]()
        message["messageId"] = messageId
        if data != nil {
            message["data"] = data
        }
        dispatch(message: message)
    }
    
    func exec(body: Any?) {
        let messageStrng = body as? String
        if messageStrng == nil {
            return
        }
        guard let message = deserialize(messageJSON: messageStrng!) else {
            
            return
        }
        //兼容android
        guard let handlerName = message["handlerName"] as? String else { return }
        
        guard let handler = messageHandlers[handlerName] else {
//            
            return
        }
        handler(message["data"] as? [String: Any])
    }
    
    func inject() {
       
    }
    
    private func serialize(message: Message, pretty: Bool) -> String? {
        var result: String?
        do {
            let data = try JSONSerialization.data(withJSONObject: message, options: pretty ? .prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0))
            result = String(data: data, encoding: .utf8)
        } catch  {}
        return result
    }
    
    private func deserialize(messageJSON: String) -> Message? {
        var result: Message?
        guard let data = messageJSON.data(using: .utf8) else { return nil }
        do {
            result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JavascriptBridgeBase.Message
        } catch {}
        return result
    }
    
    private func dispatch(message: Message) {
        guard let messageJSON = serialize(message: message, pretty: false) else { return }
        let javascriptCommand = "\(AppConfig.JS_BRIDGE).handleMessageFromApp('\(messageJSON)');"
        if Thread.current.isMainThread {
            delegate?.evaluateJavascript(javascript: javascriptCommand)
        } else {
            DispatchQueue.main.async {
                self.delegate?.evaluateJavascript(javascript: javascriptCommand)
            }
        }
    }
}


