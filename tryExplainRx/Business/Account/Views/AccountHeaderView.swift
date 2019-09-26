//
//  AccountHeaderView.swift
//
//
//  Created by  on 2019/3/6.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import Kingfisher
import AttributedTextView

class AccountHeaderView: UIView {
    var titlelabel: UILabel!
    var settingButton: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initHeaderView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AccountHeaderView {
    func initHeaderView() {
        /// 初始化
        let headBackgroudImageView = UIImageView().then {
            $0.frame = CGRect(x: 0, y: 0, width: mScreenW, height: mScreenW/2)
            $0.image = mImage(name: "account_pic_bg_default")
            let accoutModel = AccountModel.mapModel(from: NetWorkManager.getCacheString(key: "accountData"))
            if let url = URL(string: "http:" + accoutModel.background) {
                $0.kf.setImage(with: url, placeholder: mImage(name: "login_pic_bg"), options: nil, progressBlock: nil, completionHandler: nil)
            }
          
            $0.isUserInteractionEnabled = true
        }
        
        let setButton = UIButton.init(type: .custom).then {
            $0.setImage(mImage(name: "account_icon_setting"), for: .normal)
        }
        
        let headImageView = UIImageView().then{
            $0.image = mImage(name: "account_pic_portrait")
            $0.layer.cornerRadius = 32
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = true
            $0.rx.tapGesture().when(.recognized)
                .subscribe(onNext:{  _ in
                    if AppUtils.checkLoginStatus() { return }
                     
                    AppUtils.gotoLogin()
                }).disposed(by: rx.disposeBag)
        }
        
        let label = UILabel().then{
            let attrString =  "SignIn" + "/" +  "Register"
            let shadow = NSShadow()
            shadow.shadowColor = UIColor(red: 0.21, green: 0.21, blue: 0.21,alpha:0.5)
            shadow.shadowBlurRadius = 2
            shadow.shadowOffset = CGSize(width: 0, height: 0)
              $0.textAlignment = .center
            if AppUtils.checkLoginStatus() {
                $0.textColor = .white
                $0.text = UserDefaults.AccountInfo.string(forKey: .userName)
            } else {
                $0.attributedText = attrString.color(.white).font(mFont(16)).underline.attributedText
                $0.isUserInteractionEnabled = true
                $0.rx.tapGesture().when(.recognized)
                    .subscribe(onNext:{ _ in
                        
                        AppUtils.gotoLogin()
                    }).disposed(by: rx.disposeBag)
            }
        }
        self.titlelabel = label
       
        
        headBackgroudImageView.addSubview(headImageView)
        headBackgroudImageView .addSubview(setButton);
        headBackgroudImageView.addSubview(label)
        
        self.settingButton = setButton
        // 布局
        setButton.snp.makeConstraints { (make) in
            make.width.equalTo(25)
            make.height.equalTo(26)
            make.top.equalTo(headBackgroudImageView.snp_topMargin).offset(15)
            make.right.equalTo(headBackgroudImageView.snp_rightMargin).offset(-14)
        }
        
        headImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(headBackgroudImageView)
            make.centerY.equalTo(headBackgroudImageView)
            make.height.width.equalTo(64)
        }
       
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(headBackgroudImageView)
            make.width.equalTo(200)
            make.height.equalTo(19)
            make.top.equalTo(headImageView.snp.bottom).offset(8*(mScreenW/360))
        }
        self.addSubview(headBackgroudImageView)
    }
}
