//
//  ThirdWebViewController.swift
//
//
//  Created by  on 2018/8/17.
//  Copyright © 2018年  rights reserved.
//

import UIKit
import WebKit
import MJRefresh

class ThirdWebViewController: OtherPageViewController, WKNavigationDelegate, NavigationControllerBackButtonDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var url: URL!
    public var htmlData: String?
   
    
    var callBack: ((URL) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        title = "Loading"
        self.initNavigationBackBar()
        automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isHidden = false

        addWKWebView()
        addProgressView()
        if htmlData != nil {
            webView.loadHTMLString(htmlData!, baseURL: url)
        } else {
            webView.loadLater(URLRequest(url: url))
        }
        webView.allowsBackForwardNavigationGestures = true
        setNaviagtionTitleName()
        
    }
    
    private func setNaviagtionTitleName() {
        self.navigationItem.title = "Loading"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func addPullRefresh() {
        let headerView = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshWebView))
        headerView?.lastUpdatedTimeLabel.isHidden = true
        self.webView.scrollView.mj_header = headerView;
        webView.uiDelegate = self
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = true
    }
    
    @objc func refreshWebView() {
        self.webView.reload()
    }
    
    
    func shouldPopOnBackButtonPress() -> Bool {
        if webView.canGoBack {
            webView.goBack()
            return false
        }
        return true
    }

    


    fileprivate func addWKWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webView = WKWebView.init(frame: CGRect(x: 0, y: 0, width: Common.screenWidth, height: Common.screenHeight - Common.statusBarHeight - Common.navigationBarHeight), configuration: webConfiguration)
        webView?.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        view.addSubview(webView)
        addPullRefresh()
    }
    
    fileprivate func addProgressView() {
        
        progressView = UIProgressView.init(frame: CGRect(x: 0, y: 0, width: Common.screenWidth, height: 2))
        view.addSubview(progressView)
        progressView?.trackTintColor = UIColor.clear
        progressView?.progressTintColor = UIColor.orange
        
        view.addSubview(progressView!)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "estimatedProgress"){
            progressView.alpha = 1.0
            let animated = Float(webView.estimatedProgress) > progressView.progress;
            progressView.setProgress(Float(webView.estimatedProgress), animated: animated)
            
            if Float(webView.estimatedProgress) >= 1.0{
                self.webView.scrollView.mj_header.endRefreshing()
                UIView.animate(withDuration: 1, delay:0.01,options:UIView.AnimationOptions.curveEaseOut, animations:{()-> Void in
                    self.progressView.alpha = 0.0
                },completion:{(finished:Bool) -> Void in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        } else if (keyPath == "title") {
            self.navigationItem.title = webView.title;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //
        guard let requestHost = navigationAction.request.url?.host, let isMainFrame = navigationAction.targetFrame?.isMainFrame  else {
            decisionHandler(.allow)
            return
        }
        
        if isMainFrame && requestHost.range(of: AppConfig.HOST_KEY) != nil {
            decisionHandler(.cancel)
            if let url = navigationAction.request.url {
                ///支付页面到 checkout  页面 直接返回
                if url.absoluteString.checkCheckOutUrl() && navigationAction.request.httpMethod == "GET" {
                    self.navigationController?.popViewController(animated: false)
                    return
                }
                
                AppUtils.jumpToWebView(url: url.absoluteString)
                
                /// 从栈里移除支付页面
                if let VC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] ,VC is ThirdWebViewController {
                    self.navigationController?.viewControllers.removeAll{$0 == VC}
                }
                return
            }
            self.navigationController?.popViewController(animated: true)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ///解决PayPal backlist 为空开启侧滑返回会返回白页问题
        if (webView.title?.contains("PayPal"))! {
            webView.allowsBackForwardNavigationGestures = webView.backForwardList.backList.count > 0
        }
        ///
        
    }
    
}

extension ThirdWebViewController :NavUniversalable{
    func initNavigationBackBar() {
        let models = [NavigationBarItemMetric.back]
        self.universals(modelArr: models) { [weak self](model) in
            guard let strongSelf = self else { return }
            strongSelf.backToLastViewController()
        }
    }
    @objc func backToLastViewController() {
        self.navigationController?.popViewController(animated: false)
    }
}

extension ThirdWebViewController :WKUIDelegate{
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        /// 解决 twitter 博文连接点击不跳转问题
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
