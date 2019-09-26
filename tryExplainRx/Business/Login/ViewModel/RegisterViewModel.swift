//
//  RegisterViewModel.swift
//
//
//  Created by  on 2019/3/8.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxSwift
import Alamofire

class RegisterViewModel: NSObject {
    // 输出
    let usernameValid: Observable<Bool>
    let passwordValid: Observable<Bool>
    //let enterPasswordValid: Observable<Bool>
    let everythingValid: Observable<Bool>
    
    init(username: Observable<String>,password: Observable<String>) {
        usernameValid = username
            .map { $0.checkEmail() }
            .share(replay: 1)
        passwordValid = password
            .map { $0.count > 4 }
            .share(replay: 1)

        everythingValid = Observable.combineLatest(usernameValid, passwordValid ) { $0 && $1}
            .share(replay: 1)
    }
    
    class func registerSuccess(_ dic:[String : Any]) {
        
      
        UserDefaults.LoginInfo.set(value: "1", forKey: .status)
        UserDefaults.AccountInfo.set(value: dic["shoppingCartGoodsTotal"], forKey: .cartGoodsTotal)
        UserDefaults.AccountInfo.set(value: dic["favoriteGoodsTotal"], forKey: .favoriteGoodsTotal)
        UserDefaults.AccountInfo.set(value: dic["user_name"], forKey: .userName)
        UserDefaults.AccountInfo.set(value: dic["user_email"], forKey: .userEmail)
        /// 更新tabbar
        NotificationCenter.default.post(name: .TabbarNeedUpdate, object: nil, userInfo:nil)
        ///更新 account
        NotificationCenter.default.post(name: .LoginStatusChange, object: nil, userInfo:nil)
        ProgressHUD.dismissHUD()
        ProgressHUD.showSuccess("Success")
        guard let topVC = AppUtils.getCurrentController() else { return }
        if topVC is LoginRegisterViewController {
            let rehisterVc = topVC as! LoginRegisterViewController
            rehisterVc.route = "request"
            rehisterVc.navigationController?.popViewController(animated: false)
        }
        topVC.navigationController?.popViewController(animated: false)
    }
    
}
