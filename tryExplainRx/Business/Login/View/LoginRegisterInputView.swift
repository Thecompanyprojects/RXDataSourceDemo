//
//  LoginRegisterInputView.swift
//
//
//  Created by  on 2019/3/6.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import AttributedTextView

class LoginRegisterInputView: UIView {
    /// 类型
    enum inputViewType {
        case login
        case register
        case changePassword
    }
    
    var firstTextfield: UITextField!
    var secondTextfield: UITextField!
    var thirdTextFiled: UITextField!
    private var firstLineView: UIView!
    private var secondLineView: UIView!
    private var thirdLineView: UIView!
    private var firstAlertLabel: UILabel!
    private var secondAlertLabel: UILabel!
    private var thirdAlertLabel: UILabel!
    private var clearButton: UIButton!
    private weak var rootVC: UIViewController?
    var registerProtocolAlertLabel : UILabel!
    var agreeButton: UIButton!
    var enterButton: UIButton!
    var forgetPwButton: UIButton!
    
    
    init(style:inputViewType ,rootVC:UIViewController) {
        let y = style == .changePassword ? 56 : 107
        super .init(frame: CGRect(x: 0, y:CGFloat(y), width: mScreenW, height:style == .login ? 280 : 397))
        self.rootVC = rootVC
        initUI(style: style)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoginRegisterInputView{
    func initUI(style:inputViewType) {
        let  isLogin = style == .login ? true :false
        /// 初始化
        let firstTextfield = UITextField().then {
            $0.placeholder =  style == .changePassword ?"Currentpassword" :"E-mail Address"
            $0.font = mThemeNormalFont
        }
        
        let secondTextfield = UITextField().then {
            $0.placeholder = style == .changePassword ? "Newpassword" :"Password"
            $0.font = mThemeNormalFont
            $0.isSecureTextEntry = isLogin
        }
        let firstLineView = UIView().then {
             $0.backgroundColor = mRGBA(209, 208, 208, 1)
        }
        let secondLineView = UIView().then {
             $0.backgroundColor = mRGBA(209, 208, 208, 1)
        }
        let firstAlertLabel = UILabel().then {
            $0.font = mThemeMinFont
            $0.textColor = mThemePinkColor
            $0.text = style == .changePassword ? "passwordtoshort" :"Pleasecheckuemail"
            $0.isHidden = true
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }
        let secondAlertLabel = UILabel().then {
            $0.font = mThemeMinFont
            $0.textColor = mThemePinkColor
            $0.text = "passwordtoshort"
            $0.isHidden = true
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }
       
        let enterButton = UIButton().then {
            $0.backgroundColor = mRGBA(209, 208, 208, 1)
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
            let title = isLogin ? "SIGNIN" : style == .register ? "REGISTER" : "Savechanges"
            $0.setTitle(title, for: .normal)
        }
        self.addSubview(firstTextfield)
        self.addSubview(secondTextfield)
        self.addSubview(firstLineView)
        self.addSubview(secondLineView)
        self.addSubview(firstAlertLabel)
        self.addSubview(secondAlertLabel)
        self.addSubview(enterButton)
        
        ///布局
        firstTextfield.snp.makeConstraints { (make) in
            if style != .changePassword {
                make.left.equalTo(self.snp.left).offset(56)
                make.right.equalTo(self).offset(-76)
            } else {
                make.left.equalTo(self).offset(16)
                make.right.equalTo(self).offset(-16)
            }
           
            make.top.equalTo(self.snp.top).offset(22)
            make.height.equalTo(40)
        }
        firstLineView.snp.makeConstraints {(make) in
             if style != .changePassword {
                make.left.equalTo(self).offset(56)
                make.right.equalTo(self).offset(-56)
             } else {
                make.left.equalTo(self).offset(16)
                make.right.equalTo(self).offset(-16)
            }
            make.height.equalTo(2)
            make.top.equalTo(firstTextfield.snp.bottom).offset(2)
        }
        firstAlertLabel.snp.makeConstraints {(make) in
            if style != .changePassword {
                make.left.equalTo(self).offset(56)
                make.right.equalTo(self).offset(-56)
            } else {
                make.left.equalTo(self).offset(16)
                make.right.equalTo(self).offset(-16)
            }
            make.top.equalTo(firstLineView.snp.bottom).offset(8)
        }
        secondTextfield.snp.makeConstraints { (make) in
            make.left.equalTo(firstTextfield)
            make.right.equalTo(firstTextfield)
            make.top.equalTo(firstLineView.snp.top).offset(30)
            make.height.equalTo(40)
        }
        secondLineView.snp.makeConstraints {(make) in
            make.left.equalTo(firstLineView)
            make.right.equalTo(firstLineView)
            make.height.equalTo(2)
            make.top.equalTo(secondTextfield.snp.bottom).offset(2)
        }
        secondAlertLabel.snp.makeConstraints { (make) in
            make.left.equalTo(firstLineView)
            make.right.equalTo(firstLineView)
            make.top.equalTo(secondLineView.snp.bottom).offset(8)
        }
       
      
        self.enterButton = enterButton
        self.secondAlertLabel = secondAlertLabel
        self.secondLineView = secondLineView
        self.secondTextfield = secondTextfield
       
        self.firstAlertLabel = firstAlertLabel
        self.firstLineView = firstLineView
        self.firstTextfield = firstTextfield
        
        
        ///登录注册才有 clearButton forget
        if style != .changePassword {
            enterButton.snp.makeConstraints {(make) in
                make.left.equalTo(self).offset(48)
                make.right.equalTo(self).offset(-48)
                make.height.equalTo(40)
                make.top.equalTo(secondAlertLabel.snp.bottom).offset(8)
            }
            
            let clearButton = UIButton().then {
                $0.setImage(mImage(name: "login_icon_clear"), for: .normal)
                $0.isHidden = true
                $0.rx.tap.subscribe(onNext:{
                    
                    if (firstTextfield.text?.count)! > 0 {
                        //firstAlertLabel.becomeFirstResponder()
                        firstTextfield.text = ""
                        
                    }
                }).disposed(by: rx.disposeBag)
            }
            let forgetPwButton = UIButton().then {
                let str1 = isLogin ? NSMutableAttributedString(string: "Forgotupassword") :NSMutableAttributedString(string: "TermsandConditions")
                let range1 = NSRange(location: 0, length: str1.length)
                let number = NSNumber(value:NSUnderlineStyle.single.rawValue)
                str1.addAttribute(NSAttributedString.Key.underlineStyle, value: number, range: range1)
                let color : UIColor! = isLogin ? mRGBA(120, 120, 120, 1) :mThemeLabelNormalColor
                str1.addAttribute(NSAttributedString.Key.foregroundColor, value:color, range: range1)
                $0.setAttributedTitle(str1, for: .normal)
                $0.titleLabel?.font = mThemeMinFont
            }
            
            self.addSubview(clearButton)
            self.addSubview(forgetPwButton)
            
            
            clearButton.snp.makeConstraints { (make) in
                make.width.height.equalTo(12)
                make.right.equalTo(self.firstLineView.snp.right).offset(-5)
                make.centerY.equalTo(self.firstTextfield)
            }
            forgetPwButton.snp.makeConstraints {(make) in
                if isLogin {
                    make.top.equalTo(enterButton.snp.bottom).offset(9)
                    make.right.equalTo(enterButton)
                } else {
                    make.top.equalTo(secondLineView.snp.bottom).offset(48)
                    make.left.equalTo(self.snp.left).offset(36)
                }
                make.width.equalTo((forgetPwButton.titleLabel?.text)!.stringWidthForComment(fontSize: 12, height: 14))
                make.height.equalTo(14)
            }
            self.forgetPwButton = forgetPwButton
            self.clearButton = clearButton
        }
        switch style {
        case .login:
            initLoginUI()
            boundLoginViewModel()
            break
        case .register:
            initRegisterUI()
            boundRegisterModel()
            break
        default:
            initChagePassWordUI()
            boundChagePasswordModel()
            break
        }
        
    }
    
    func initLoginUI() {
      
        self.firstTextfield.keyboardType = .emailAddress
        ///self.firstTextfield.becomeFirstResponder()
        
        if let lastAccount = UserDefaults.AccountInfo.string(forKey: .lastAccount),lastAccount.count > 0 {
            self.firstTextfield.text = lastAccount
        }
        self.firstTextfield.rx.controlEvent([.editingDidEnd,.editingChanged,.editingDidBegin]).asObservable()
            .subscribe(onNext: {[weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.clearButton.isHidden = strongSelf.firstTextfield.text!.count < 1
            }).disposed(by: rx.disposeBag)
        let secureButton =  UIButton().then {
            $0.isSelected = false
            $0.setImage(mImage(name: "login_icon_nosee"), for: .normal)
            $0.setImage(mImage(name: "login_icon_see"), for: .selected)
        }
        self.addSubview(secureButton)
        secureButton.snp.makeConstraints { (make) in
            make.centerY.equalTo((self.secondTextfield)!)
            make.width.equalTo(28)
            make.height.equalTo(24)
            make.right.equalTo(self.clearButton.snp.right)
        }
        secureButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let strongSelf = self else { return }
            
            secureButton.isSelected = !secureButton.isSelected
            strongSelf.secondTextfield.isSecureTextEntry = !secureButton.isSelected
            let text = strongSelf.secondTextfield.text
            strongSelf.secondTextfield.text = nil
            strongSelf.secondTextfield.text = text
           
        }).disposed(by: rx.disposeBag)
       
        self.enterButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.enterButton.isEnabled = false
            
            strongSelf.loginReuqest()
        }).disposed(by: rx.disposeBag)
        

    }
    
    func initRegisterUI() {
        
        self.firstTextfield.keyboardType = .emailAddress
        //self.firstTextfield.becomeFirstResponder()
        self.secondTextfield.isSecureTextEntry = true
        self.forgetPwButton.removeFromSuperview()
        self.firstTextfield.rx.controlEvent([.editingDidEnd,.editingChanged]).asObservable()
            .subscribe(onNext: {[weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.clearButton.isHidden = strongSelf.firstTextfield.text!.count < 1
            }).disposed(by: rx.disposeBag)
        
        let secureButton =  UIButton().then {
            $0.isSelected = false
            $0.setImage(mImage(name: "login_icon_nosee"), for: .normal)
            $0.setImage(mImage(name: "login_icon_see"), for: .selected)
        }
        self.addSubview(secureButton)
        secureButton.snp.makeConstraints { (make) in
            make.centerY.equalTo((self.secondTextfield)!)
            make.width.equalTo(28)
            make.height.equalTo(24)
            make.right.equalTo(self.clearButton.snp.right)
        }
        secureButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let strongSelf = self else { return }
            
            secureButton.isSelected = !secureButton.isSelected
            strongSelf.secondTextfield.isSecureTextEntry = !secureButton.isSelected
            let text = strongSelf.secondTextfield.text
            strongSelf.secondTextfield.text = nil
            strongSelf.secondTextfield.text = text
            
        }).disposed(by: rx.disposeBag)
        let registerProtocolLabel = UILabel().then {
            let string = "RegisterIterm".replacingOccurrences(of: "<a>", with: "+").replacingOccurrences(of: "</a>", with: "+")
            let array:[String] = string.components(separatedBy: "+")
            $0.font = mThemeMinFont
            if array.count > 2 {
                $0.attributedText = (array[0].color(mRGBA(120, 120, 120, 1)) + array[1].color(mThemePinkColor).underline + array[2].color(mRGBA(120, 120, 120, 1))).attributedText
            }
            $0.textAlignment = .left
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
            
        }
        registerProtocolLabel.rx.tapGesture().when(.recognized)
            .subscribe(onNext:{ _ in
                AppUtils.jumpToWebView(route: AppUtils.getFunctionUrl(.term))
            }).disposed(by: rx.disposeBag)
        let registerProtocolAlertLabel = UILabel().then {
            $0.text = "RegisterItermAlert"
            $0.textColor = mThemePinkColor
            $0.font = mThemeMinFont
            $0.isHidden = true
            $0.textAlignment = .left
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }
        self.registerProtocolAlertLabel = registerProtocolAlertLabel
        let agreeBtn = UIButton().then {
            $0.setImage(mImage(name: "login_icon_diselected"), for: .normal)
            $0.setImage(mImage(name: "login_icon_selected"), for: .selected)
            $0.imageEdgeInsets = UIEdgeInsets.init(top: -16, left: 16, bottom: 0, right: 0)
            $0.isSelected = true
        }
        agreeBtn.rx.tap.subscribe(onNext:{
            agreeBtn.isSelected = !agreeBtn.isSelected
            registerProtocolAlertLabel.isHidden = agreeBtn.isSelected
        }).disposed(by: rx.disposeBag)
        self.agreeButton = agreeBtn
        let welcomLabel = AttributedLabel().then {
            $0.attributedText = ("WANT".color(mThemeLabelNormalColor) + " 12% OFF".color(mThemePinkColor) + "?".color(mThemeLabelNormalColor) + "REGISTERNOW".color(mThemeLabelNormalColor)).attributedText
            $0.textAlignment = .center
            $0.font = mThemeNormalFont
        }
        self.addSubview(registerProtocolLabel)
        self.addSubview(registerProtocolAlertLabel)
        self.addSubview(agreeBtn)
        self.addSubview(welcomLabel)
     
       
        welcomLabel.snp.makeConstraints {(make) in
            make.left.equalTo(self).offset(16)
            make.right.equalTo(self).offset(-16)
            make.height.equalTo(16)
            make.top.equalTo(self.enterButton.snp.bottom).offset(8)
        }
        agreeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(32)
            make.width.height.equalTo(32)
            make.top .equalTo(welcomLabel.snp.bottom).offset(21)
        }
        registerProtocolLabel.snp.makeConstraints { (make) in
            make.left.equalTo(agreeBtn.snp.right).offset(4)
            make.right.equalTo(self).offset(-56)
            make.top.equalTo(agreeBtn)
        }
        
        registerProtocolAlertLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(56)
            make.right.equalTo(self).offset(-56)
            make.top.equalTo(registerProtocolLabel.snp.bottom).offset(8)
        }

        
    }
    
    func initChagePassWordUI() {
        self.firstTextfield.becomeFirstResponder()
        let thirdTextFeild = UITextField().then {
            $0.placeholder = "Reenternewpassword"
            $0.font = mThemeNormalFont
        }
        //let
        let thirdLineView = UIView().then {
             $0.backgroundColor = mRGBA(209, 208, 208, 1)
        }
        let thirdAlertLabel = UILabel().then {
            $0.font = mThemeMinFont
            $0.textColor = mThemePinkColor
            $0.text = "passwordsnotmatch"
            $0.isHidden = true
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }
        
        self.addSubview(thirdTextFeild)
        self.addSubview(thirdLineView)
        self.addSubview(thirdAlertLabel)
        
        thirdTextFeild.snp.makeConstraints { (make) in
            make.left.equalTo(self.secondTextfield)
            make.right.equalTo(self.secondTextfield)
            make.top.equalTo(self.secondLineView.snp.top).offset(30)
            make.height.equalTo(40)
        }
        thirdLineView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(16)
            make.right.equalTo(self).offset(-16)
            make.height.equalTo(2)
            make.top.equalTo(thirdTextFeild.snp.bottom).offset(2)
        }
        thirdAlertLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(16)
            make.right.equalTo(self).offset(-16)
            make.top.equalTo(thirdLineView.snp.bottom).offset(8)
        }
        
        
        self.thirdTextFiled = thirdTextFeild
        self.thirdLineView = thirdLineView
        self.thirdAlertLabel = thirdAlertLabel
        
        self.enterButton.snp.makeConstraints {(make) in
            make.left.equalTo(self).offset(48)
            make.right.equalTo(self).offset(-48)
            make.height.equalTo(40)
            make.top.equalTo(thirdAlertLabel.snp.bottom).offset(8)
        }
    }
    
    
    
    func boundLoginViewModel() {
        let  viewModel = LoginViewModel(
        username: self.firstTextfield!.rx.text.orEmpty.asObservable(),
        password: self.secondTextfield!.rx.text.orEmpty.asObservable()
        )
        var firstInput: Bool = false
        self.firstTextfield?.rx.controlEvent([.editingDidEnd]).asObservable()
            .subscribe(onNext: { _ in
                firstInput = true
                
            }).disposed(by: rx.disposeBag)
        
        viewModel.usernameValid.bind(onNext: { [weak self] (result) in
            guard let strongSelf = self else { return }
            if firstInput {
                strongSelf.firstAlertLabel.isHidden = result
                if result {
                    strongSelf.firstLineView.backgroundColor = mThemeLabelNormalColor
                } else {
                    strongSelf.firstLineView.backgroundColor = mThemePinkColor
                }
            }
        }).disposed(by:rx.disposeBag)
        
        var secondInput: Bool = false
    self.secondTextfield?.rx.controlEvent([.editingDidEnd]).asObservable() .subscribe(onNext: {  _ in
           secondInput = true
        }).disposed(by: rx.disposeBag)
        
        viewModel.passwordValid.bind(onNext: { [weak self] (result) in
            guard let strongSelf = self else { return }
            if secondInput {
                strongSelf.secondAlertLabel.isHidden = result
                if result {
                    strongSelf.secondLineView.backgroundColor = mThemeLabelNormalColor
                } else {
                    strongSelf.secondLineView.backgroundColor = mThemePinkColor
                }
            }
        }).disposed(by:rx.disposeBag)
        viewModel.everythingValid
            .bind(onNext: { [weak self] (result) in
                guard let strongSelf = self else { return }
                strongSelf.enterButton.isEnabled = result
                if result {
                    strongSelf.enterButton.backgroundColor = mThemeLabelNormalColor
                } else {
                    strongSelf.enterButton.backgroundColor = mRGBA(209, 208, 208, 1)
                }
            }).disposed(by:rx.disposeBag)
      
    }
    
    func boundRegisterModel() {
        let  viewModel = RegisterViewModel(
            username: self.firstTextfield!.rx.text.orEmpty.asObservable(),
            password: self.secondTextfield!.rx.text.orEmpty.asObservable())
        
        var firstInput: Bool = false
        self.firstTextfield?.rx.controlEvent([.editingDidEnd]).asObservable()
            .subscribe(onNext: { _ in
                firstInput = true
            }).disposed(by: rx.disposeBag)
        
        viewModel.usernameValid.bind(onNext: { [weak self] (result) in
            if firstInput {
                guard let strongSelf = self else { return }
                strongSelf.firstAlertLabel.isHidden = result
                if result {
                    strongSelf.firstLineView.backgroundColor = mThemeLabelNormalColor
                } else {
                    strongSelf.firstLineView.backgroundColor = mThemePinkColor
                }
            }
        }).disposed(by:rx.disposeBag)
        
        var secondInput: Bool = false
        self.secondTextfield?.rx.controlEvent([.editingDidEnd]).asObservable() .subscribe(onNext: {  _ in
            secondInput = true
        }).disposed(by: rx.disposeBag)
        
        viewModel.passwordValid.bind(onNext: { [weak self] (result) in
            if secondInput {
                guard let strongSelf = self else { return }
                strongSelf.secondAlertLabel.isHidden = result
                if result {
                    strongSelf.secondLineView.backgroundColor = mThemeLabelNormalColor
                } else {
                    strongSelf.secondLineView.backgroundColor = mThemePinkColor
                }
            }
        }).disposed(by:rx.disposeBag)
        
        viewModel.everythingValid
            .bind(onNext: { [weak self] (result) in
                guard let strongSelf = self else { return }
                strongSelf.enterButton.isEnabled = result
                if result {
                    strongSelf.enterButton.backgroundColor = mThemeLabelNormalColor
                } else {
                    strongSelf.enterButton.backgroundColor = mRGBA(209, 208, 208, 1)
                }
            }).disposed(by:rx.disposeBag)
        
    }
    
    func boundChagePasswordModel()  {
        let  viewModel = ChangePasswordViewModel.init(currentPassword: self.firstTextfield!.rx.text.orEmpty.asObservable(),
                                                      newPassword: self.secondTextfield!.rx.text.orEmpty.asObservable(),
                                                      enterPassword: self.thirdTextFiled!.rx.text.orEmpty.asObservable())
        var firstInput: Bool = false
        self.firstTextfield?.rx.controlEvent([.editingDidEnd]).asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                firstInput = true
                if (strongSelf.firstTextfield.text?.count)! < 1 {
                    strongSelf.firstAlertLabel .text = "Enterupassword"
                } else {
                    strongSelf.firstAlertLabel.text = "passwordtoshort"
                }
            }).disposed(by: rx.disposeBag)
        
        viewModel.currentPasswordValid.bind(onNext: { [weak self] (result) in
            if firstInput {
                guard let strongSelf = self else { return }
                strongSelf.firstAlertLabel.isHidden = result
                if result {
                    strongSelf.firstLineView.backgroundColor = mThemeLabelNormalColor
                } else {
                    strongSelf.firstLineView.backgroundColor = mThemePinkColor
                }
            }
        }).disposed(by:rx.disposeBag)
        
        var secondInput: Bool = false
        self.secondTextfield?.rx.controlEvent([.editingDidEnd]).asObservable() .subscribe(onNext: {  _ in
            secondInput = true
        }).disposed(by: rx.disposeBag)
        
        viewModel.newPasswordValid.bind(onNext: { [weak self] (result) in
            if secondInput {
                guard let strongSelf = self else { return }
                strongSelf.secondAlertLabel.isHidden = result
                if result {
                    strongSelf.secondLineView.backgroundColor = mThemeLabelNormalColor
                } else {
                    strongSelf.secondLineView.backgroundColor = mThemePinkColor
                }
            }
        }).disposed(by:rx.disposeBag)
        
        
        var thirdInput: Bool = false
        self.thirdTextFiled?.rx.controlEvent([.editingDidEnd]).asObservable() .subscribe(onNext: {  _ in
            thirdInput = true
        }).disposed(by: rx.disposeBag)
        
        viewModel.enterPasswordValid.bind(onNext: { [weak self] (result) in
            if thirdInput {
                guard let strongSelf = self else { return }
                strongSelf.thirdAlertLabel.isHidden = result
                if result {
                    strongSelf.thirdLineView.backgroundColor = mThemeLabelNormalColor
                } else {
                    strongSelf.thirdLineView.backgroundColor = mThemePinkColor
                }
            }
        }).disposed(by:rx.disposeBag)
        viewModel.everythingValid
            .bind(onNext: { [weak self] (result) in
                guard let strongSelf = self else { return }
                strongSelf.enterButton.isEnabled = result
                if result {
                    strongSelf.enterButton.backgroundColor = mThemeLabelNormalColor
                } else {
                    strongSelf.enterButton.backgroundColor = mRGBA(209, 208, 208, 1)
                }
            })
            .disposed(by:rx.disposeBag)
    }
   
    
    func loginReuqest() {
        self.rootVC?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        ProgressHUD.showLoadingIn((self.rootVC?.navigationController?.view)!)
        
    }
    
    func loginSuccess(_ dic:[String : Any]) {
        
      
        UserDefaults.LoginInfo.set(value: "1", forKey: .status)
        UserDefaults.AccountInfo.set(value: dic["shoppingCartGoodsTotal"], forKey: .cartGoodsTotal)
        UserDefaults.AccountInfo.set(value: dic["favoriteGoodsTotal"], forKey: .favoriteGoodsTotal)
        UserDefaults.AccountInfo.set(value: dic["user_name"], forKey: .userName)
        UserDefaults.AccountInfo.set(value: dic["user_email"], forKey: .userEmail)

        /// 更新tabbar
        NotificationCenter.default.post(name: .TabbarNeedUpdate, object: nil, userInfo:nil)
        ///更新 account
        NotificationCenter.default.post(name: .LoginStatusChange, object: nil, userInfo:nil)
       
        
        self.rootVC?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        ProgressHUD.dismissHUD()
        self.rootVC?.view.subviews.forEach{$0.removeFromSuperview()}
        if self.rootVC is LoginRegisterViewController {
            let registerLogVC:LoginRegisterViewController  = self.rootVC as! LoginRegisterViewController
            registerLogVC.route = "request"
        }
        self.rootVC?.navigationController?.popViewController(animated: false)
    }
}
