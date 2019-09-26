//
//  BindMailViewModel.swift
//
//
//  Created by  on 2019/4/25.
//  Copyright © . All rights reserved.
//

import UIKit
import RxSwift

enum RegisterApiType {
    case emailCheck
    case register
}

class BindMailViewModel: NSObject {
    // 输出
    let emailValid: Observable<Bool>
    init(eamil: Observable<String>) {
        emailValid = eamil
            .map { $0.checkEmail() }
            .share(replay: 1)
    }
   

}
