//
//  MCJSBridgeRegisterHandler.swift
//
//
//  Created by  on 2019/3/22.
//  Copyright © 2019年  rights reserved.
//

import Foundation

class MCJSBridgeRegisterHandler {
    private weak var webView: CWebView?
    private weak var webViewController: BaseWebViewController?
    
    init(webview: CWebView, webViewController: BaseWebViewController) {
        self.webView = webview
        self.webViewController = webViewController
    }
    
    func JsBridgeRegister() {
        self.webView!.JsBridge.register(handlerName: "UPDATE_CART") { data in
            guard data != nil else {return}
            
            ///
            UserDefaults.AccountInfo.set(value: 0, forKey: .cartGoodsTotal)
        }
        
        /// loading 状态
        self.webView!.JsBridge.register(handlerName: "MASK_SHOW_STATUS") { data in
            guard data != nil else {return}
            if let status = data!["status"],status as! Int == 0 {
                
                ProgressHUD.dismissHUD()
            }
        }
        
        self.webView!.JsBridge.register(handlerName: "SET_LOADING_STATUS") { data in
            guard data != nil else {return}
            let status = data!["status"] as! Bool
            if(!status) {
                ProgressHUD.dismissHUD()
            }
        }
        
        
        self.webView!.JsBridge.register(handlerName: "PAGE_BACK") { data in
            ProgressHUD.dismissHUD()
            if (self.webView!.canGoBack) {
                HistoryManager.goBack(webView: self.webView!)
            } else {
              self.webViewController!.navigationController?.popViewController(animated: true)
            }
        }
        
        self.webView!.JsBridge.register(handlerName:"SAVE_ADDRESS") { data in
            ///secure checkout 页面 修改/创建地址 返回 购物车页面
            guard data != nil else {return}
            
            ProgressHUD.dismissHUD()
            /// address 入口 不做跳转
            let accoutModel = AccountModel.mapModel(from: NetWorkManager.getCacheString(key: "accountData"))
            if  let route = self.webViewController?.router ,route == accoutModel.addressUrl{
                return
            }
            
            /// 账单地址
            if (self.webView?.url?.absoluteString.checkCreditCardPayNowUrl())! {
                self.webView?.goBack()
                return
            }
            
            if (self.webView?.url?.absoluteString.checkCheckOutUrl())! {
                AppUtils.jumpToWebView(route: AppUtils.getFunctionUrl(.checkOut))
                /// 在栈里移除 修改/创建地址 的webviewController
                if let viewControllers = AppUtils.getCurrentController()?.navigationController?.viewControllers,viewControllers.count > 1 {
                    if let VC = AppUtils.getCurrentController()?.navigationController?.viewControllers[viewControllers.count - 2] ,VC is WebJumpViewController {
                        AppUtils.getCurrentController()?.navigationController?.viewControllers.removeAll{$0 == VC}
                    }
                }
                return
            }
        }
        
        self.webView!.JsBridge.register(handlerName: "GO_TO_PATH") { (data) in
            guard data != nil else {
                return
            }
            
            if let name = data!["name"],name as! String == "register" {
                ProgressHUD.dismissHUD()
                AppUtils.gotoRegister()
            }
            if let name = data!["name"],name as! String == "login" {
                ProgressHUD.dismissHUD()
                AppUtils.gotoLogin()
            }
        
        
            
        }
        self.webView!.JsBridge.register(handlerName: "CHANGE_FAVORITE") { data in
            guard data != nil, let params = data!["params"] else {
                return
            }
            
            if let postDic = params as? [String: Any?], let num = postDic["num"] as? NSInteger  {
                
                UserDefaults.AccountInfo.set(value: num, forKey: .favoriteGoodsTotal)
                NotificationCenter.default.post(name: .TabbarNeedUpdate, object: nil, userInfo:nil)
            }
        }
        self.webView!.JsBridge.register(handlerName: "ADD_TO_CART") { data in
            guard data != nil, let num = data!["num"] else {
                return
            }
            UserDefaults.AccountInfo.set(value: num, forKey: .cartGoodsTotal)
            NotificationCenter.default.post(name: .TabbarNeedUpdate, object: nil, userInfo:nil)
        }

        //show_loading
        self.webView!.JsBridge.register(handlerName: "SHOW_LOADING") {[weak self] data in
            guard let strongSelf = self else { return }
            ProgressHUD.showLoadingIn((strongSelf.webViewController?.view)!)
        }
        
        
        track()
    }
}


extension MCJSBridgeRegisterHandler {
    
    func track() {
        self.webView!.JsBridge.register(handlerName: "LOG_EVENT") {data in
            guard data != nil else {
                return
            }
            if var params = data!["params"] as? [String: Any] {
                if params["items"] != nil {
                    if let items = params["items"] as? [String: Any] {
                        params["items"] = [ items ]
                    } else if let itemsArr = params["items"] as? [Any] {
                        var itemdicArr = [[String: Any?]]()
                        for item in itemsArr {
                            if let itemDic = item as? [String: Any] {
                                itemdicArr.append(itemDic)
                            }
                        }
                        params["items"] = itemdicArr
                    }
                }
        
            }
        }
        
        self.webView!.JsBridge.register(handlerName: "USER_PROPERTY") {data in
            guard data != nil, let name = data!["name"] as? String, let value = data!["value"] as? String else {
                return
            }
            
        }
        
        self.webView!.JsBridge.register(handlerName: "APP_POST") { data in
            guard data != nil, let postData = data!["PostData"] else {
                return
            }
            if let postDic = postData as? [String: Any?] {
                //目前不判断源， 直接使用third controller
                if let restPage = postDic["restPage"] as? Int {
                    //重置表单并回退重复的历史
                    self.webViewController!.restPage(restPage)
                }
                let thirdWebView = ThirdWebViewController()
                
                thirdWebView.url = URL(string: postDic["baseUrl"] as! String)
                
                thirdWebView.htmlData = (postDic["htmlString"] as! String)
                
            AppUtils.getCurrentController()!.navigationController!.pushViewController(thirdWebView, animated: false)
               
            }
        }
    }
    
}
