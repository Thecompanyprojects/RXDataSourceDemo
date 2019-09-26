//
//  HistoryManager.swift
//
//
//  Created by  on 2018/8/28.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import WebKit

class HistoryManager {
    
    private static let SPECIAL_KEY_WORD : [String: [String]] = [
        "pre_order_sn": ["checkout_payment_process"],
        "checkout_payment_process": ["checkout_payment_process"],
        "pay_now.php": ["pay_now.php"]
    ]
    
    
    class func goBack(webView: WKWebView) {
        guard let currUrl = webView.url?.absoluteString, webView.canGoBack else {
            return
        }
        let backList = webView.backForwardList.backList
        var findFlag = false
        var contiansFilter = false
        
        for item in backList.reversed() {
            if findFlag {
                webView.go(to: item)
                return
            }
            let oriFindUrl = item.url.absoluteString
            let findUrl = item.url.absoluteString.replacingOccurrences(of: "#/", with: "")
            let resPair = containsKeyWord(currUrl: currUrl, findUrl: findUrl)
            
            if oriFindUrl.range(of: "#/filter", options: .regularExpression) != nil {
                contiansFilter = true
            }
            //filter 页面返回的特殊处理
            if currUrl.range(of: ".+-c[0-9]+.*", options: .regularExpression) != nil {
                //如果是列表页面, 并且会退历史中包含filter, 则跳过这些记录
                let regx = ".+c[0-9]+"
                var compareCurrUrl = currUrl
                if let range = currUrl.range(of: regx, options: .regularExpression) {
                    compareCurrUrl = String(compareCurrUrl[range])
                }
                var compareFindUrl = oriFindUrl
                if let range = oriFindUrl.range(of: regx, options: .regularExpression) {
                    compareFindUrl = String(compareFindUrl[range])
                }
                if contiansFilter //返回路径中包含filter
                    && compareFindUrl.range(of: compareCurrUrl) == nil //不和自身匹配
                    && oriFindUrl.range(of: "#/filter", options: .regularExpression) == nil //不和filter匹配
                {
                    webView.go(to: item)
                    return
                }
            }
            
            if !resPair.0 {
                continue
            }
            
            let pattern = ".+act=checkout_payment_process&pre_order_sn=[a-zA-Z]+[0-9]+(#/)?"
            
            if resPair.1
                && findUrl.elementsEqual(currUrl.replacingOccurrences(of: "#/", with: ""))
                || (!resPair.1 && currUrl.range(of: pattern, options: .regularExpression) != nil && currUrl.range(of: findUrl) != nil ) {
                findFlag = true
            }
        }
        webView.goBack()
    }
    
    /**
     * first true means currUrl 需要进入特定的回退逻辑
     */
    private class func containsKeyWord(currUrl: String, findUrl: String) -> (Bool, Bool) {
        for (key, value) in SPECIAL_KEY_WORD {
            if currUrl.contains(key) {
                for str in value {
                    if findUrl.contains(str) {
                        return (true, str.elementsEqual(key))
                    }
                }
            }
        }
        
        return (false, false)
    }
}
