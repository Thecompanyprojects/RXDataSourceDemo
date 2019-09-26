//
//  VWebView.swift
//
//
//  Created 2018/8/5.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    
    public func setJsBridge() -> JavascriptBridge {
        return JavascriptBridge(webView: self)
    }
}



let De = "very"


let ET = "Very"
