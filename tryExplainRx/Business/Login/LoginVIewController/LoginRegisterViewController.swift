//
//  LoginRegisterViewController.swift
//
//
//  Created by  on 2019/3/6.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxSwift
import RxCocoa



class LoginRegisterViewController: BaseViewController {
    private var scrollView : UIScrollView! = nil
    private var headView: LoginRegisterHeaderView!
    private var loginInputSection : LoginRegisterInputView!
    private var resgisterInputSection : LoginRegisterInputView!
    
    private var currentStyle : String! = "login"
    /// 解决未登录check out 页面空白问题
    private var lastWebVC :UIViewController?
    var jumpStype:String! = "login"
    var route:String = "default"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false

        initUI()
        initNavigationBackBar()
        updateCurrentView(style: jumpStype)
        UserDefaults.AccountInfo.set(value:"", forKey: .registerAccount)
        /// 账户已存在,登录密码错误,刷新UI至登录
        let registerAccount = UserDefaults.AccountInfo.keyString(forKey: .registerAccount)
        let observer = UserDefaults.standard.rx.observe(String.self,registerAccount!,options: [.new]).debounce(0.1, scheduler: MainScheduler.asyncInstance)
        observer.subscribe(onNext: {[weak self] (value) in
            guard let strongSelf = self else { return }
            if let val = value, val.count > 1 {
               strongSelf.updateAllView()
            }
        }).disposed(by: rx.disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        if lastWebVC != nil && route == "webView" {
             //
            let viewControllers:[UIViewController] = (self.navigationController?.viewControllers)!
            var newViewControllers  = [UIViewController]()
            newViewControllers += viewControllers
            newViewControllers.insert(lastWebVC!, at: (viewControllers.count) - 1)
            //self.navigationController?.viewControllers.removeAll()
            /// to do : 此处插入webviewController 不成功 待解决
             self.navigationController?.setViewControllers(newViewControllers, animated: true)
            
            
           
        }
    }
    ///侧滑返回监听
    override func willMove(toParent parent: UIViewController?) {
        super .willMove(toParent: parent)
        
        if parent == nil && route == "webView"{
            if (self.navigationController?.viewControllers.count)! > 1 {
                if let VC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] ,VC is WebJumpViewController {
                    lastWebVC = VC
                    self.navigationController?.viewControllers.removeAll{$0 == VC}
                }
            }
        }
    }
   
    
    // MARK:- UI相关
    func initUI() {
        self.view.backgroundColor = mThemeWhiteColor
        initHeadUI()
        
        initInputView()
        let button = UIButton(type: .roundedRect).then {
            $0.setTitle("V E R Y V O G A", for: .normal)
            $0.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 16)
            $0.setTitleColor(mThemeLabelNormalColor, for: .normal)
            $0.sizeToFit()
            $0.rx.tap.subscribe(onNext:{ [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.navigationController?.popToRootViewController(animated: false)
              
            }).disposed(by: rx.disposeBag)
        }
        // 添加点击方法
        self.navigationItem.titleView = button;
    }
    
    func updateUI() {
        self.view.backgroundColor = mThemeWhiteColor
        initHeadUI()
        
        initInputView()
    }
    
    func initScrollView() {
        scrollView = UIScrollView().then({
            $0.frame = CGRect(x: 0, y: 0, width: mScreenW, height: mScreenH - mNavibarH)
            //let height = 107 + 260 + 108  < mScreenH - mNavibarH ? mScreenH - mNavibarH: 107 + 260 + 108
            $0.contentSize = CGSize(width: mScreenW,
                                    height: mScreenH - mNavibarH  )
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
        })
        self.view.addSubview(scrollView)
    }
    func initHeadUI() {
        initScrollView()
        self.automaticallyAdjustsScrollViewInsets = false
        let headerView = LoginRegisterHeaderView(frame: CGRect(x: 0, y: 0, width: mScreenW, height: 107 ))
        self.scrollView.addSubview(headerView)
        headerView.loginStatusButton!.rx.tap.subscribe(onNext:{[weak self] in
            
            guard let strongSelf = self else { return }
            strongSelf.updateCurrentView(style: "login")
        }).disposed(by: rx.disposeBag)
        headerView.registerStatusButton!.rx.tap.subscribe(onNext:{ [weak self] in
            
            guard let strongSelf = self else { return }
            strongSelf.updateCurrentView(style: "register")
            
        }).disposed(by: rx.disposeBag)
        self.headView = headerView
    }

    func initInputView() {
        let inputView = LoginRegisterInputView(style: .login,rootVC:self)
        self.scrollView.addSubview(inputView)
        inputView.forgetPwButton.rx.tap.subscribe(onNext:{
            
           AppUtils.jumpToWebView(route: AppUtils.getFunctionUrl(.forgetPWD))
        }).disposed(by: rx.disposeBag)
        if let registerAccount = UserDefaults.AccountInfo.string(forKey: .registerAccount),registerAccount.count > 1 {
            inputView.firstTextfield.text = registerAccount
            inputView.secondTextfield.becomeFirstResponder()
        }
        self.loginInputSection = inputView
    }
    func updateAllView() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
        currentStyle = "login"
        updateUI()
    }
    
    
    /// 网络请求 ps:暂时写法  rxswift 请求依赖还未研究透
    func register(_ userNameStr:String,passWordStr:String)  {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        
        var checkEmaildataDic: [String : Any] = ["from":"iOS",
                                                 "source":"",
                                                 "email":userNameStr,
                                                 "checkemail":1,
                                                 "password":passWordStr,
                                                 "password_again":passWordStr,
                                                 "agreeNewsLetter":0,
                                                 "fbToken":"",
                                                 "googleToken":""]
        
        NetWorkRequest(.register(parameters: checkEmaildataDic), success: { (result) -> (Void) in
            checkEmaildataDic.updateValue(0, forKey: "checkemail")
            checkEmaildataDic.updateValue(1, forKey: "agreeNewsLetter")
            NetWorkRequest(.register(parameters: checkEmaildataDic), success: {[weak self] (result) -> (Void) in
                guard let strongSelf = self else { return }
                let dic = result["data"] as! Dictionary<String, Any>
                strongSelf.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                ProgressHUD.dismissHUD()
                
                ProgressHUD.showSuccess("Success")
                strongSelf.resgisterInputSection.enterButton.isEnabled = true
                strongSelf.view.subviews.forEach{$0.removeFromSuperview()}
                strongSelf.route = "request"
                ///保存用户信息
                RegisterViewModel.registerSuccess(dic)
            }, failure: {[weak self] (error,errorCode) -> (Void) in
                guard let strongSelf = self else { return }
                strongSelf.resgisterInputSection.enterButton.isEnabled = true
                strongSelf.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                ProgressHUD.dismissHUD()
            })
        }) {[weak self] (errorMsg,errorCode) -> (Void) in
            guard let strongSelf = self else { return }
            strongSelf.resgisterInputSection.enterButton.isEnabled = true
            strongSelf.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            ProgressHUD.dismissHUD()
            if errorCode == "4" {
                VVAlert.confirmOrCancel(title:"EmailExists", message: "", confirmTitle: "LogInNow", cancelTitle: "Cancle", inViewController: strongSelf, withConfirmAction: {
                    
                    strongSelf.resgisterInputSection.loginReuqest()
                }, cancelAction: {})
            } else {
                ProgressHUD.showError(errorMsg)
            }
        }
    }
    
    func updateCurrentView(style:String) {
        if style == currentStyle {return}
        //let height = 107 + 260 + 108  < mScreenH - mNavibarH ? mScreenH - mNavibarH : 107 + 260 + 108
        self.scrollView.contentSize = CGSize(width: mScreenW,
                                             height: mScreenH - mNavibarH  )
        if style == "login" {
            if self.resgisterInputSection != nil {
                self.resgisterInputSection .removeFromSuperview()
                self.scrollView.addSubview(self.loginInputSection)
            }
        } else {
            if self.resgisterInputSection == nil {
                let inputView = LoginRegisterInputView(style: .register,rootVC:self)
                self.scrollView.addSubview(inputView)
                self.resgisterInputSection = inputView
            }
            self.resgisterInputSection.enterButton.rx.tap.subscribe(onNext:{ [weak self] _ in
                
                guard let strongSelf = self else { return }
                
                if !strongSelf.resgisterInputSection.agreeButton.isSelected {
                    strongSelf.resgisterInputSection.registerProtocolAlertLabel.isHidden = false
                } else {
                    ProgressHUD.showLoading()
                    strongSelf.resgisterInputSection.enterButton.isEnabled = false
                    strongSelf.register(strongSelf.resgisterInputSection.firstTextfield.text!, passWordStr: strongSelf.resgisterInputSection.secondTextfield.text!)
                }
            }).disposed(by: rx.disposeBag)
            self.loginInputSection.removeFromSuperview()
            self.scrollView.addSubview(self.resgisterInputSection)
        }
//        self.bottomView.frame = CGRect(x: 0, y: self.scrollView.contentSize.height - 108, width: mScreenW, height: 108)
        self.headView.updateButtonstatus(type: style)
        currentStyle = style
    }
    override func backToLastViewController() {
        
        self.tabBarController?.tabBar.isHidden = false
        if route == "default" {
            self.navigationController?.popViewController(animated: false)
        } else {
            if   (self.navigationController?.viewControllers.count)! > 2 {
                let index = (self.navigationController?.viewControllers.count)! - 3
                self.navigationController?.popToViewController((self.navigationController?.viewControllers[index])!, animated: false)
            } else {
                self.navigationController?.popViewController(animated: false)
            }
        }
        self.view.subviews.forEach{$0.removeFromSuperview()}
       
    }
}


