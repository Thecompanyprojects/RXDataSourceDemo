//
//  WebViewController.swift
//
//
//  Created 2018/8/4.
//  Copyright © 2018年  rights reserved.
//


import UIKit
import WebKit
import MJRefresh

import SnapKit

class WebViewController: UIViewController {
    
    var webView: CWebView!
    var scrollView = UIScrollView()
    var router : String? = ""
    var url: URL = URL(string: AppConfig.HOME + AppUtils.getLangSuffix())!
    var isPullRefreshing = false
    let reachability = Reachability()
    var isNetConnect: Bool = true
    var isLoading: Bool = false
    var istabbarVC:Bool = true
    var currentUrl: URL!
    let refreshControl = UIRefreshControl()
    
    lazy var eventQueue: [NavigaTionStatus: () -> Void] = {
        return [NavigaTionStatus: () -> Void]()
    }()
    
    lazy var networkAlert = {
        return VVAlert.alert(title: "Nointernetconnection", message: "Networkerror", dismissTitle: "RETRY", inViewController: self, withDismissAction: {
            self.webView.load(URLRequest(url: self.currentUrl))
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        url = (router?.isEmpty)!  ?  URL(string: AppConfig.HOME + AppUtils.getLangSuffix())! : URL(string: AppConfig.HOME + AppUtils.getDefaultLangSuffix() + router!)!
        
        addScrollView()
        addWebView()
    
        
        if let tempUrl = getUrlWithPath(path: AppConfig.NOTIFICATION_PATH) {
            url = tempUrl
            AppConfig.NOTIFICATION_PATH = nil
        }
        loadUrl(url: url)
        currentUrl = url
        
        automaticallyAdjustsScrollViewInsets = false
         self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(webviewLoad(notification:)), name: .NotificationReloadWebView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshWebView), name: .LoginStatusChange, object: nil)
        
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new, .old], context: nil)
        self.scrollView.mj_header.beginRefreshing()
        
    }
    
    // MARK:- Notification
    @objc func webviewLoad(notification: Notification) {
        if let tempUrl = getUrlWithPath(path: notification.userInfo?["path"] as? String) {
            loadUrl(url: tempUrl)
        }
        AppConfig.NOTIFICATION_PATH = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath?.localizedCompare("estimatedProgress").rawValue == 0 {
            if self.webView.estimatedProgress >= 1.0 {
                self.hideLoading()
                //页面加载完成的时候判断是否能够滚动
                self.triggerScrollEnabled()
            }
        }
    }
    
    deinit {
        if self.webView != nil{
            self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    

    // MARK:- UI相关
    func addScrollView() {
        let height = istabbarVC ? (mScreenH - mNavibarH - mTabbarH ):Common.screenHeight - Common.statusBarHeight
        let y = istabbarVC ? 0 : mStatusbarH
        let headerView = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction:  #selector(refreshWebView))
        headerView?.lastUpdatedTimeLabel.isHidden = true
        
        self.scrollView.frame = CGRect(x: 0, y: y, width: Common.screenWidth, height: height)
        self.scrollView.bounces = true
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.delegate = self
        

        self.scrollView.mj_header = headerView
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
    }
    
    func addWebView() {
        let height = istabbarVC ? (mScreenH - mNavibarH - mTabbarH ):Common.screenHeight - Common.statusBarHeight
        let frame = CGRect(x: 0, y: 0, width: Common.screenWidth, height: height)
        let wkUIDelegate = CUIDelegate(viewController: self)
        self.webView = CWebView(frame: frame, configuration: initWebViewConfig(), uiDelegate: wkUIDelegate)
        self.webView.scrollView.bounces = false
        self.webView.allowsLinkPreview = false
        self.webView.navigationDelegate = self
        self.webView.scrollView.delegate = self
        JSBridgeRegisterHandler(webview: self.webView, webViewController: self).JsBridgeRegister()
        self.scrollView.addSubview(self.webView)
    }
    /// init WKWebViewconfig
    private func initWebViewConfig() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration().then {
            $0.allowsInlineMediaPlayback = true
           
        }
        return config
    }
    
    // MARK:- Url config
    func loadUrl(url: URL) {
        
        webView.loadLater(URLRequest(url: url))
    }
    
    func getUrlWithPath(path: String?) -> URL? {
        guard let path = path else {
            return nil
        }
        var langSuffix = ""
        if path.range(of: "/\\w{2}/", options: .regularExpression) == nil {
            langSuffix = AppUtils.getDefaultLangSuffix()
        }
        return URL(string: "\(AppConfig.HOME)\(langSuffix)\(path)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case "showThird":
            let thirdWebVC = segue.destination as! ThirdWebViewController
            thirdWebVC.callBack = {result in
                self.webView.load(URLRequest(url: result))
            }
            if let url = sender as? URL {
                thirdWebVC.url = url
            } else if let postData = sender as? [String: Any?], postData["baseUrl"] != nil {
                thirdWebVC.url = URL(string: postData["baseUrl"] as! String)
                thirdWebVC.htmlData = postData["htmlString"] as? String
            }
        //            thirdWebVC.url = sender as! URL
        default:
            break
        }
    }
    
    // MARK:- Loading HUD
    func showLoading(_ message: String? = nil) {
        self.scrollView.isScrollEnabled = false
        isLoading = true
        if self.isPullRefreshing {
        ProgressHUD.showLoading()
        }
    }
    
    func hideLoading() {
        self.scrollView.mj_header.endRefreshing()
        isPullRefreshing = false
        isLoading = false
    }
    
 // MARK:- Refresh
    @objc func refreshWebView() {
        
        self.webView.reload()
    }
}


// MARK:- WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        /// 无网络不跳转
        if !isNetworkConnect {
            self.networkAlert()
            ProgressHUD.dismissHUD()
            decisionHandler(.cancel)
            return
        }
       //
        
        /// 非站点不拦截
        if let host = navigationAction.request.url?.host {
            if  !("https://" + host).checkHostUrl() {
                
                decisionHandler(.allow)
                return
            } else {
                let strRequest :String = (navigationAction.request.url?.absoluteString.removingPercentEncoding!)!
                /// 主页不拦截
                if strRequest.checkHostUrl() {
                    decisionHandler(.allow)
                    return
                }
                /// 其他跳转
                
                /// 首页web屏蔽连续点击
                if let currentVC = AppUtils.getCurrentController(),
                    (currentVC.navigationController?.viewControllers.count)! > 1{
                    decisionHandler(.cancel)
                    return;
                }
               
                AppUtils.jumpToWebView(url: (navigationAction.request.url?.absoluteString)!)
                decisionHandler(.cancel)
                return
            }
        }
            
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        let urlString = webView.url?.absoluteString
     
        //self.showLoading()
        self.loopEvent(.didStart)
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        

        ///屏蔽长按事件
        self.webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none'", completionHandler: nil)
        self.webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none'", completionHandler: nil)
        
        subscribeTopic(siteDomain: webView.url?.host ?? AppConfig.HOST)
        self.hideLoading()
        self.loopEvent(.didFinish)
        //结束事件循环生命周期， 并清空事件
        self.flush()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideLoading()
        
    }
    
    func subscribeTopic(siteDomain: String) {
        if !AppUtils.getIfHasSetTopic() && UIApplication.shared.currentUserNotificationSettings!.types != [] && AppUtils.GetIfHasFcmToken() {
         
            AppUtils.hasSetTopic(status: true)
            
      
        }
    }
}


// MARK:- UIScrollViewDelegate
extension WebViewController: UIScrollViewDelegate {
    
    func triggerScrollEnabled() {
        let mainScrollView = self.scrollView
        let subScrollView = self.webView.scrollView
        if mainScrollView.contentOffset.y > 0 || subScrollView.contentOffset.y > 0 {
            mainScrollView.isScrollEnabled = false
        } else {
            mainScrollView.isScrollEnabled = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        triggerScrollEnabled()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        triggerScrollEnabled()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        triggerScrollEnabled()
    }
    
}
