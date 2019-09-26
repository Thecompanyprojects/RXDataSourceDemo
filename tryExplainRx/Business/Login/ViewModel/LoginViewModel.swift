//
//  LoginViewModel.swift
//
//
//  Created by  on 2019/3/7.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MoyaMapper

class LoginViewModel: NSObject {
    // 输出
    let usernameValid: Observable<Bool>
    let passwordValid: Observable<Bool>
    let everythingValid: Observable<Bool>
    
    init(username: Observable<String>,password: Observable<String>) {
        usernameValid = username
            .map { $0.checkEmail() }
            .share(replay: 1)
        passwordValid = password
            .map { $0.count > 4 }
            .share(replay: 1)
        everythingValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1}
            .share(replay: 1)
    }

}
