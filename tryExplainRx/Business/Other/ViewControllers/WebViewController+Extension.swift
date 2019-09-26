//
//  WebViewController+Extension.swift
//
//
//  Created 2018/8/30.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import WebKit

extension WebViewController {
    public enum NavigaTionStatus {
        case didStart, didFinish
    }
    //event queue 入队列
    public func push(_ status: NavigaTionStatus, navigation: @escaping () -> Void) {
        self.eventQueue[status] = navigation
    }
    public func flush() {
        self.eventQueue.removeAll()
    }
    public func loopEvent(_ status: NavigaTionStatus) {
        for (key, block) in self.eventQueue {
            if key == status {
                block()
            }
        }
    }
    
    //预先设置一个event
    public func restPage(_ step: Int = 0) {
        //如果用webview.reload 表单会重新提交
        self.webView.evaluateJavaScript("location.reload();"){ (res, error) in
            if step < 0 && self.webView.canGoBack {
                self.push(.didFinish) {
                    self.webView.evaluateJavaScript("window.history.go(\(step));", completionHandler: nil)
                }
            }
        }
    }
    
}
