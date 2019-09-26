//
//  CWebView.swift
//
//
//  Created 2018/8/5.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import WebKit

class CWebView: WKWebView {
    
    public var JsBridge: JavascriptBridge!
    public static var _userAgent: String?
    private var _uiDelete: WKUIDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        commonInit()
    }
    
    init(frame: CGRect, configuration: WKWebViewConfiguration, uiDelegate: WKUIDelegate) {
        super.init(frame: frame, configuration: configuration)
        self._uiDelete = uiDelegate
        commonInit()
    }
    
    func commonInit() {
      
        self.JsBridge = setJsBridge()
        //初始化 cookie
      
        self._uiDelete = self._uiDelete ?? CUIDelegate()
        //避免所引用被立即释放
        self.uiDelegate = self._uiDelete
        //允许返回手势
        self.allowsBackForwardNavigationGestures = true
    }
    
    deinit {
        self.JsBridge = nil
        self._uiDelete = nil
    }
}


extension WKWebView {
    @discardableResult func loadLater(_ request: URLRequest) -> WKNavigation? {        
        if CWebView._userAgent == nil {
            // 解决iOS 12 useragent 注入失败问题
            var dummyWebView: WKWebView? = WKWebView()
            dummyWebView!.evaluateJavaScript("navigator.userAgent") { (res, error) in
                guard res != nil else { return }
                dummyWebView = nil
                //
                CWebView._userAgent = res as? String
                self.customUserAgent = res as? String
                //
                self.load(request)
            }
        } else {
             DispatchQueue.main.async {
                if !(self.customUserAgent?.contains(AppConfig.AGENT_KEY))! {
                    self.customUserAgent = CWebView._userAgent! + AppConfig.AGENT_KEY
                    
                }
                self.load(request)
            }
        }
        return nil
    }
}

/**
 * 修复wkwebview选择图片上传后, 不出现done 按钮的情况
 * todo: 研究为什么在ios11.4.1 上面不出现done按钮
 */
extension UIImagePickerController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = UIModalPresentationStyle.custom
    }
}
