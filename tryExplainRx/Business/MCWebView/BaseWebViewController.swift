//
//  BaseWebViewController.swift
//
//
//  Created by  on 2019/3/15.
//  Copyright © 2019年  rights reserved.
//

import WebKit
import MJRefresh

import SnapKit
import RxSwift

class BaseWebViewController: BaseViewController {
    var router : String? = ""
    var path: String? = ""
    var jumpUrl: String? = ""
    private  var url: URL = URL(string: AppConfig.HOME + AppUtils.getLangSuffix())!
    var webView : CWebView!
    private let reachability = Reachability()
    var istabbarVC:Bool = true
    private  var currentUrl: URL!
    private var hadLoadSuccess: Bool = false
    private var needRefrsh: Bool = false
    
    lazy var eventQueue: [NavigaTionStatus: () -> Void] = {
        return [NavigaTionStatus: () -> Void]()
    }()
    
    lazy var networkAlert = {
        return VVAlert.alert(title: "Nointernetconnection", message: "Networkerror", dismissTitle: "RETRY", inViewController: self, withDismissAction: {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.webView.load(URLRequest(url: strongSelf.currentUrl))
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBadgeObersver()
        addNetworkListener()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needRefrsh {
            self.reloadData()
        }
    }
    
    private func initUI() {
        self.url = URL(string: "https:www.baidu.com")!
        addWebView()
        if let tempUrl = getUrlWithPath(path: AppConfig.NOTIFICATION_PATH) {
            url = tempUrl
            AppConfig.NOTIFICATION_PATH = nil
        }
        currentUrl = url
        if isNetworkConnect {
            loadUrl(url: url)
            if AppUtils.getCurrentController() == self {
                ProgressHUD.showLoadingIn(self.view)
            }
        } else {
            updateUI()
        }
    }
        
    
    private func updateUI() {
        if hadLoadSuccess { return }
        self.view.subviews.forEach{$0.removeFromSuperview()}
        if isNetworkConnect {
            self.initUI()
        } else {
            self.addNoNetworkView()
        }
    }
    
    private func addBadgeObersver() {
        /// favorite 自己监听
        if let navigationVC = AppUtils.getCurrentController() {
            if let title = navigationVC.navigationItem.title,
                title.contains("MyFavorites") {
                return
            }
        }
        
        //// 监听badge 数字变更
        let favoriteGoodsTotal = UserDefaults.AccountInfo.keyString(forKey: .favoriteGoodsTotal)
        let observer = UserDefaults.standard.rx.observe(Int.self, favoriteGoodsTotal!,options: [.new]).debounce(0.01, scheduler: MainScheduler.asyncInstance)
        observer.subscribe(onNext: {[weak self] (value) in
            guard let strongSelf = self else { return }
            if value != nil {
                if AppUtils.getCurrentController() == strongSelf { return }
                 NotificationCenter.default.post(name: .TabbarNeedUpdate, object: nil, userInfo:nil)
                strongSelf.needRefrsh = true
            }
        }).disposed(by: rx.disposeBag)
        let cartGoodsTotal = UserDefaults.AccountInfo.keyString(forKey: .cartGoodsTotal)
        let bagObserver = UserDefaults.standard.rx.observe(Int.self, cartGoodsTotal!,options: [.new]).debounce(0.01, scheduler: MainScheduler.asyncInstance)
        bagObserver.subscribe(onNext: {[weak self] (value) in
            guard let strongSelf = self else { return }
            if value != nil {
                if AppUtils.getCurrentController() == strongSelf { return }
                  NotificationCenter.default.post(name: .TabbarNeedUpdate, object: nil, userInfo:nil)
                strongSelf.needRefrsh = true
            }
        }).disposed(by: rx.disposeBag)
        
        let loginStatus = UserDefaults.LoginInfo.keyString(forKey: .status)
        let observerLogin = UserDefaults.standard.rx.observe(String.self, loginStatus!,options: [.new]).debounce(0.01, scheduler: MainScheduler.asyncInstance)
        observerLogin.subscribe(onNext: {[weak self] (value) in
            guard let strongSelf = self else { return }
            if value != nil {
                 DispatchQueue.global().async {
                    strongSelf.refreshWebView()
                }
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    
    private func addNetworkListener() {
        
        reachability?.whenUnreachable = { [weak self] _ in
            guard let strongSelf = self else { return }
            if !strongSelf.hadLoadSuccess && !isNetworkConnect {
                strongSelf.hideLoading()
                strongSelf.webView.stopLoading()
                strongSelf.webView.scrollView.mj_header.endRefreshing()
                strongSelf.updateUI()
            }
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            
        }
    }
    // MARK:- UI相关
    private func addWebView() {
        let height = istabbarVC ? (mScreenH - mNavibarH - mTabbarH ): mScreenH - mStatusbarH
        let y = istabbarVC ? mNavibarH : mStatusbarH
        let frame = CGRect(x: 0, y: y, width: mScreenW, height: height)
        let wkUIDelegate = CUIDelegate(viewController: self)
        let config = initWebViewConfig()
        
        self.webView = CWebView(frame: frame, configuration:config, uiDelegate: wkUIDelegate)
        self.webView.navigationDelegate = self
        self.webView.allowsLinkPreview = false
       // webView.isOpaque = false
        // webView.backgroundColor = view.backgroundColor;
        //refreshWebView
        let headerView = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshWebView))
        headerView?.lastUpdatedTimeLabel.isHidden = true
        self.webView.scrollView.mj_header = headerView;
        MCJSBridgeRegisterHandler(webview: self.webView, webViewController: self).JsBridgeRegister()
        self.view.addSubview(self.webView)
        
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
    
    private func getUrlWithPath(path: String?) -> URL? {
        guard let path = path else {
            return nil
        }
        var langSuffix = ""
        if path.range(of: "/\\w{2}/", options: .regularExpression) == nil {
            langSuffix = AppUtils.getLangSuffix()
        }
        return URL(string: "\(AppConfig.HOME)\(langSuffix)\(path)")
    }
    
    // MARK:- Loading HUD
    func showLoading(_ message: String? = nil) {
        guard self.webView != nil else { return }
        if !self.webView.scrollView.mj_header.isRefreshing && isNetworkConnect{
            if AppUtils.getCurrentController() == self {
                ProgressHUD.showLoadingIn(self.view)
          
            }
        }
    }
    
    func hideLoading() {
        ProgressHUD.dismissHUD()
        self.webView.scrollView.mj_header .endRefreshing()
    }
    func reloadData() {
        self.webView.scrollView.mj_header.beginRefreshing()
    }
    // MARK:- Refresh
    @objc func refreshWebView() {
         DispatchQueue.main.async {
            if self.webView.url != nil {
                self.webView.reload()
            } else {
                self.webView.loadLater(URLRequest(url: self.currentUrl))
            }
        }
    }
    
}

// MARK:- WKNavigationDelegate

extension BaseWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
      
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        
    
        self.loopEvent(.didStart)
        self.showLoading()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
         
        if needRefrsh {
            needRefrsh = false
        }
        if let urlHostString = webView.url?.host {

            subscribeTopic(siteDomain: urlHostString)
        } else {
             subscribeTopic(siteDomain:AppConfig.HOST)
        }
        ///屏蔽长按事件
        self.webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none'", completionHandler: nil)
        self.webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none'", completionHandler: nil)
        
        self.hadLoadSuccess = true
        self.hideLoading()
      
        self.loopEvent(.didFinish)
        //结束事件循环生命周期， 并清空事件
        self.flush()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideLoading()
    
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.hideLoading()
      
    }
    
    
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        self.webView.scrollView.mj_header.beginRefreshing()
    }
    
    func subscribeTopic(siteDomain: String) {
        if !AppUtils.getIfHasSetTopic() && UIApplication.shared.currentUserNotificationSettings!.types != [] && AppUtils.GetIfHasFcmToken() {
            let topicAll = "topic-\(AppConfig.STAGE)-all"
            let topicSite = "topic-\(AppConfig.STAGE)-\(siteDomain)"
            
            AppUtils.hasSetTopic(status: true)
            
     
        }
    }
}

extension BaseWebViewController {
    private func addNoNetworkView() {
        let noNetworkModel = PlaceholderViewModel.init(type: .noSignIn, title: "Networkerror", imageName: "noNetwork", buttonTitle: "TRYAGAIN", mFrame: CGRect(x: (mScreenW - 92)/2, y:20 + mNavibarH, width: 92, height: 102))
        universal(model: noNetworkModel) {[weak self] (model) in
            guard let strongSelf = self else { return }
            if isNetworkConnect {
                strongSelf.view.subviews.forEach { $0.removeFromSuperview() }
                if AppUtils.getCurrentController() == strongSelf {
                    ProgressHUD.showLoadingIn((strongSelf.navigationController?.view)!)
                }
                strongSelf.updateUI()
            }
        }
    }
    
}

