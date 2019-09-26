
//
//  LoginRegisterHeaderView.swift
//
//
//  Created by  on 2019/3/6.
//  Copyright © 2019年  rights reserved.
//

import UIKit
// MARK:- 常量
fileprivate struct Metric {
    
    static let buttonWidth: CGFloat = 150
    static let buttonHeight: CGFloat = 22.0
    static let lineHeight: CGFloat = 2.0
    static let lineWidth: CGFloat = 90
}
class LoginRegisterHeaderView: UIView {
    var loginStatusButton : UIButton?
    var registerStatusButton : UIButton?
    var buttonLine: UIView?
    
    
    override init(frame: CGRect) {
        super .init(frame:frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoginRegisterHeaderView {
    func initUI() {
        let buttonLineView = UIView().then {
            $0.backgroundColor = mThemePinkColor
        }
        let loginStatusButton = UIButton().then {
            $0.setTitle("SignIn", for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            $0.setTitleColor(mThemeLabelNormalColor, for: .normal)
        
        }
        let registerStatusButton = UIButton().then {
            $0.setTitle("Register", for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
             $0.setTitleColor(mThemeLabelNormalColor, for: .normal)
        }
        loginStatusButton.rx.tap.subscribe(onNext:{
            registerStatusButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            loginStatusButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            buttonLineView.snp.remakeConstraints({ (make) in
                make.width.equalTo(Metric.lineWidth)
                make.height.equalTo(Metric.lineHeight)
                make.centerX.equalTo(loginStatusButton)
                make.top.equalTo(loginStatusButton.snp.bottom).offset(8)
            })
        }).disposed(by: rx.disposeBag)

        registerStatusButton.rx.tap.subscribe(onNext:{
            loginStatusButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            registerStatusButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            buttonLineView.snp.remakeConstraints({(make) in
                make.width.equalTo(Metric.lineWidth)
                make.height.equalTo(Metric.lineHeight)
                make.centerX.equalTo(registerStatusButton)
                make.top.equalTo(loginStatusButton.snp.bottom).offset(8)
            })
        }).disposed(by: rx.disposeBag)
        
    
        self.addSubview(buttonLineView)
        self.addSubview(loginStatusButton)
        self.addSubview(registerStatusButton)
        loginStatusButton.snp.makeConstraints { (make) in
            make.width.equalTo(Metric.buttonWidth)
            make.height.equalTo(Metric.buttonHeight)
            make.top.equalTo(self.snp.top).offset(60)
            make.left.equalTo(self.snp.left).offset((mScreenW - 2*Metric.buttonWidth - 18)/2)
        }
        registerStatusButton.snp.makeConstraints { (make) in
            make.left.equalTo(loginStatusButton.snp.right).offset(18)
            make.top.equalTo(loginStatusButton)
            make.size.equalTo(loginStatusButton.snp.size)
        }
        
        buttonLineView.snp.makeConstraints { (make) in
            make.width.equalTo(Metric.lineWidth)
            make.height.equalTo(Metric.lineHeight)
            make.centerX.equalTo(loginStatusButton)
            make.top.equalTo(loginStatusButton.snp.bottom).offset(8)
        }
        self.registerStatusButton = registerStatusButton
        self.loginStatusButton = loginStatusButton
        self.buttonLine = buttonLineView
    }
    func updateButtonstatus(type:String) {
        if type == "register" {
            self.loginStatusButton!.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            self.registerStatusButton!.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            self.buttonLine!.snp.remakeConstraints({(make) in
                make.width.equalTo(Metric.lineWidth)
                make.height.equalTo(Metric.lineHeight)
                make.centerX.equalTo(self.registerStatusButton!)
                make.top.equalTo(self.loginStatusButton!.snp.bottom).offset(8)
            })
        } else {
             self.registerStatusButton!.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            self.loginStatusButton!.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            self.buttonLine!.snp.remakeConstraints({ (make) in
                make.width.equalTo(Metric.lineWidth)
                make.height.equalTo(Metric.lineHeight)
                make.centerX.equalTo(self.loginStatusButton!)
                make.top.equalTo(self.loginStatusButton!.snp.bottom).offset(8)
            })
        }
    }
}
