//
//  UserDefaults+Extensions.swift
//
//
//  Created by  on 2019/4/30.
//  Copyright © . All rights reserved.
//

import Foundation


extension UserDefaults {
    // 账户信息
    struct AccountInfo: UserDefaultsSettable {
        enum defaultKeys: String {
            /// 收藏数量
            case favoriteGoodsTotal = "favoriteGoodsTotal"
            /// 购物车数量
            case cartGoodsTotal = "shoppingCartGoodsTotal"
            ///
            case userName = "user_name"
            ///
            case userEmail = "user_email"
            ///
            case lastAccount = "lastAccount"
            ///
            case registerAccount = "registerAccount"
            /// Int 账号是否通过App注册 
            case isAppUser = "isAppUser"
        }
    }
    
    // APP 基础信息
    struct AppInfo: UserDefaultsSettable {
        enum defaultKeys: String {
            ///  语言
            case language = "userLanguage"
            /// 货币
            case currency  = "userCurrency"
            /// 国家名称
            case countryName  = "userCountryName"
            /// 国家code
            case contryCode  = "userCountryCode"
        }
    }
    
    // 登录信息
    struct LoginInfo: UserDefaultsSettable {
        enum defaultKeys: String {
            /// 登录状态 string
            case status = "loginStatus"
            /// 登录方式 string
            case loginType = "loginType"
        }
    }
    
    
    // functionUrl
    struct FunctionURL: UserDefaultsSettable {
        enum defaultKeys: String {
            /// string
            case checkOut = "checkoutUrl"
            /// string
            case forgetPassword = "forgetPwUrl"
            /// string
            case search = "searchUrl"
            /// string
            case terms = "termsUrl"
        }
    }
    
    ///config
    struct Config: UserDefaultsSettable {
        enum defaultKeys: String {
            /// string
            case UserAgent = "UserAgent"
            /// int
            case lastImageAlertTime  = "lastImageAlertTime"
        }
    }
    
    /// showTryView
    struct showTryView: UserDefaultsSettable {
        enum defaultKeys: String {
            /// bool
            case bagVC = "bagVCShowNoNetwork"
            /// bool
            case category = "categoryVCShowTry"
        }
    }
    
    /// search
    struct goodsSearch: UserDefaultsSettable {
        enum defaultKeys: String {
            /// string
            case defaults = "defaultSearch"
            /// string array
            case history = "historySearch"
        }
    }
    
    
}

protocol UserDefaultsSettable {
    associatedtype defaultKeys: RawRepresentable
}

extension UserDefaultsSettable where defaultKeys.RawValue == String {
    
    static func set(value: Any?, forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    
    static func string(forKey key: defaultKeys) -> String? {
        let aKey = key.rawValue
        return UserDefaults.standard.string(forKey: aKey)
    }
    
    static func integer(forKey key: defaultKeys) -> Int? {
        let akey = key.rawValue
        return UserDefaults.standard.integer(forKey: akey)
    }
    
    static func array(forKey key: defaultKeys) -> Array<Any>? {
        let akey = key.rawValue
        return UserDefaults.standard.array(forKey: akey)
    }
    
    static func keyString(forKey key: defaultKeys) -> String? {
        return key.rawValue
    }
}
