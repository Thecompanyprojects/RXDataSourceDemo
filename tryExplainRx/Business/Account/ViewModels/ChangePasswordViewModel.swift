//
//  ChangePasswordViewModel.swift
//
//
//  Created by  on 2019/3/11.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxSwift

class ChangePasswordViewModel: NSObject {
    // 输出
    let currentPasswordValid: Observable<Bool>
    let newPasswordValid: Observable<Bool>
    let enterPasswordValid: Observable<Bool>
    let everythingValid: Observable<Bool>
    
    init(currentPassword: Observable<String>,newPassword: Observable<String>,enterPassword: Observable<String>) {
        currentPasswordValid = currentPassword
            .map { $0.count > 4 }
            .share(replay: 1)
        
        newPasswordValid = newPassword
            .map { $0.count > 4 }
            .share(replay: 1)
        
        enterPasswordValid = Observable.combineLatest(newPassword, enterPassword ) {
            $0 == $1
            }.share(replay: 1)
        
        everythingValid = Observable.combineLatest(currentPasswordValid, newPasswordValid ,enterPasswordValid) { $0 && $1 && $2}
            .share(replay: 1)
    }
}
