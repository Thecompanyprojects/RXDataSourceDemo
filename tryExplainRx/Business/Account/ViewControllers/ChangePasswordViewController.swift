//
//  ChangePasswordViewController.swift
//
//
//  Created by  on 2019/3/8.
//  Copyright © 2019年  rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    private var scrollView : UIScrollView! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func initUI() {
        self.view.backgroundColor = mThemeWhiteColor
        initNavigationBar()
        initInputView()
         self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.color(mThemeWhiteColor), for: UIBarPosition.any, barMetrics: .default)
        self.title = "ChangePassword"
        
    }
    
    func initScrollView() {
        scrollView = UIScrollView().then({
            $0.frame = CGRect(x: 0, y: 0, width: mScreenW, height: mScreenH - mNavibarH)
            $0.contentSize = CGSize(width: mScreenW,
                                    height: mScreenH - mNavibarH  )
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
        })
        self.view.addSubview(scrollView)
    }
    
    func initInputView() {
        initScrollView()
        
        let inputView = LoginRegisterInputView(style: .changePassword,rootVC:self)
        scrollView.addSubview(inputView)
        inputView.enterButton.rx.tap.subscribe(onNext:{
            
            changePassWord(currentPW:inputView.firstTextfield.text!,
                           newPW:inputView.thirdTextFiled.text!)
        }).disposed(by: rx.disposeBag)
        
        let accoutLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 18)
            $0.textColor = mThemeLabelNormalColor
            $0.text = mFilterNullOfString(UserDefaults.AccountInfo.string(forKey: .userEmail) as Any,"accout@a.com")
            $0.backgroundColor = .white
        }
        scrollView.addSubview(accoutLabel)
        accoutLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(16)
            make.right.equalTo(self.view).offset(-16)
            make.height.equalTo(24)
            make.bottom.equalTo(inputView.snp.top).offset(16)
        }
        
    }
}

///MARK:- 点击事件
func changePassWord(currentPW:String,newPW:String) {
    ProgressHUD.showLoading()
    //修改密码请求
    NetWorkRequest(.changePassword(parameters: ["old_password":currentPW,"new_password":newPW,"new_password_again":newPW]), success: { (result) -> (Void) in
        ProgressHUD.dismissHUD()
        ProgressHUD.showSuccess("Success")
        AppUtils.getCurrentController()!.navigationController?.popViewController(animated: false)
    }) { (errorMsg,errorCode) -> (Void) in
        ProgressHUD.showError(errorMsg)
    }
}


extension ChangePasswordViewController:NavUniversalable{
    func initNavigationBar() {
        let models = [NavigationBarItemMetric.back]
        self.universals(modelArr: models) {[weak self] (model) in
            guard let strongSelf = self else { return }
            strongSelf.tabBarController?.tabBar.isHidden = false
            strongSelf.navigationController?.popViewController(animated: false)
        }
    }
}
