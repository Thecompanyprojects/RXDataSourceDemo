//
//  AppUtils.swift
//
//
//  Created by  on 2018/8/9.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import UIKit


enum FunctionURLType {
    case forgetPWD
    case search
    case checkOut
    case term
}


class AppUtils {
    // MARK:- deafult config
    /// language
    class func setUserLanguage(lang: String) {
        if(lang.isEmpty){
            return
        }
        
        UserDefaults.AppInfo.set(value: lang, forKey: .language)
    }
    
    class func getUserLanguage() -> String {
        return mFilterNullOfString(UserDefaults.AppInfo.string(forKey: .language) as Any,"en")
    }
    /// currency
    class func setUserCurrency(currency:String) {
         if(currency.isEmpty){
            return
        }
        UserDefaults.AppInfo.set(value: currency, forKey: .currency)
    }
    class func getUserCurrency() -> String {
        return mFilterNullOfString(UserDefaults.AppInfo.string(forKey: .currency) as Any,"USD")
    }
    
    /// countryCode
    class func setUserCountryCode(country:String) {
        if(country.isEmpty){
            return
        }
        UserDefaults.AppInfo.set(value: country, forKey: .contryCode)
    }
    class func getUserCountryCode() -> String {
        return mFilterNullOfString(UserDefaults.AppInfo.string(forKey: .contryCode) as Any,"")
    }
    /// countryName
    class func setUserCountryName(country:String) {
        if(country.isEmpty){
            return
        }
        UserDefaults.AppInfo.set(value: country, forKey: .countryName)
    }
    class func getUserCountryName() -> String {
        let userCountryName = UserDefaults.AppInfo.string(forKey: .countryName)
        return userCountryName == nil ? "United States" : userCountryName!
    }
    
    
    class func getLangSuffix() -> String {
        let lang = getUserLanguage()
        let country = getUserCountryCode()
        let currency = getUserCurrency()
        return "/\(lang)?currency=\(currency)&ucid=\(country)"
    }
    
    class func getDefaultLangSuffix() -> String {
        let lang = getUserLanguage()
        return "/\(lang)/"
    }
    
    class func getUrlWithPath(path: String?) -> URL? {
        guard let path = path else {
            return nil
        }
        var langSuffix = ""
        if path.range(of: "/\\w{2}/", options: .regularExpression) == nil {
            langSuffix = AppUtils.getDefaultLangSuffix()
        }
        return URL(string: "\(AppConfig.HOME)\(langSuffix)\(path)")
    }
    
    
    

    
    // MARK:- userdefault
    class func save(_ name: String, _ value: String) {
        mUserDefaults.set(value, forKey: name)
    }
    
    class func get(_ name: String) -> String {
        let value = mUserDefaults.string(forKey: name)
        return value ?? ""
    }
    
    class func hasFcmToken(status: Bool) {
        let value = status ? "1" : "0"
        save("getFcmToken", value)
    }
    
    class func GetIfHasFcmToken() -> Bool {
        return get("getFcmToken") == "1" ? true : false
    }
    
    class func hasSetTopic(status: Bool) {
        let value = status ? "1" : "0"
        save("hasSetTopic", value)
    }
    
    class func getIfHasSetTopic() -> Bool {
        return get("hasSetTopic") == "1" ? true : false
    }
    
    /// 获取设备剩余存储空间
    ///
    /// - Returns: 剩余空间
    class func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
            else {
                // something failed
                return 0
        }
        return freeSize.int64Value
    }
    
    /// 获取登录状态
    ///
    /// - Returns: true 已登录 false 未登录
    class func checkLoginStatus() ->Bool {
        if let status  =  UserDefaults.LoginInfo.string(forKey: .status),status == "1" {
                return true
        }
        return false
    }
    
    // MARK:-  页面跳转
    /// 去登陆页面
    class func gotoLogin(_ route:String? = "default") {
        let currentVC = getCurrentController()
        let loginVC = LoginRegisterViewController()
        loginVC.route = route!
        currentVC?.navigationController?.pushViewController(loginVC, animated: false)
    }
    class func gotoRegister() {
        let currentVC = getCurrentController()
        let register = LoginRegisterViewController()
        register.jumpStype = "register"
        currentVC?.navigationController?.pushViewController(register, animated: false)
    }
    
    /// 跳转webview route 拼接 host url+ language
    class func jumpToWebView(route:String) {
        if  !route.isEmpty{
            let webViewController = WebJumpViewController()
            webViewController.router = route
            if (self.getCurrentController()?.navigationController) != nil {
                 self.getCurrentController()?.navigationController!.pushViewController(webViewController, animated: false)
            } else {
                self.getCurrentController()?.present(UINavigationController(rootViewController: webViewController), animated: false, completion: nil)
            }
           
        }
    }
    /// 跳转webview 只 拼接 host url
    class func jumpToWebView(path:String) {
        if  !path.isEmpty{
            let webViewController = WebJumpViewController()
            webViewController.path = path
            self.getCurrentController()?.navigationController!.pushViewController(webViewController, animated: false)
        }
    }
     /// 跳转webview 提供完整url
    class func jumpToWebView(url:String) {
        if  !url.isEmpty{
            let webViewController = WebJumpViewController()
            webViewController.jumpUrl = url
            if let viewConteller =  self.getCurrentController(){
                viewConteller.navigationController!.pushViewController(webViewController, animated: false)
            }
            
        }
    }
    
    // MARK:- 基础数据
    /// 获取功能跳转url route
    class func getFunctionUrl(_ funtionType:FunctionURLType) -> String {
        switch funtionType {
        case .checkOut:
            if let urlString = UserDefaults.FunctionURL.string(forKey: .checkOut) {
                return urlString + "&currency=\(getUserCurrency())"
            } else {
                return "/checkout.php?act=checkout_login&currency=\(getUserCurrency())"
            }
        case .forgetPWD:
            if let urlString = UserDefaults.FunctionURL.string(forKey: .forgetPassword) {
                return urlString
            } else {
                return "/forgotpassword.php"
            }
        case .search:
            if let urlString = UserDefaults.FunctionURL.string(forKey: .search) {
                return urlString + "?currency=\(getUserCurrency())&"
            } else {
                return "/search.php?currency=\(getUserCurrency())&"
            }
        case .term:
            if let urlString = UserDefaults.FunctionURL.string(forKey: .terms) {
                return urlString 
            } else {
                return "/about/help.php?page_id=85"
            }
        }
    }
    


    class func getSettingBaseData() ->SettingModel {
        var setting = SettingModel.mapModel(from: NetWorkManager.getCacheString(key: "settingData"))
        UserDefaults.AppInfo.set(value: setting.countries.selectCountry, forKey: .countryName)
        
        if  setting.countries.allCountries.count < 1 {
            
            let dataString : String? = Bundle.main.path(forResource: "VVBaseData", ofType:"plist")
            let dictionary : NSDictionary = NSDictionary(contentsOfFile: dataString!)!
            NetWorkManager.cacheString(key: "settingData", string:dictionary.object(forKey: "settingData") as! String)
            setting = SettingModel.mapModel(from: NetWorkManager.getCacheString(key: "settingData"))
        }
          return setting
    }
    
    /// 获取当前页面视图控制器
    class func getCurrentController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
            if let nav = base as? UINavigationController {
                return getCurrentController(base: nav.visibleViewController)
            }
            if let tab = base as? UITabBarController {
                return getCurrentController(base: tab.selectedViewController)
            }
            if let presented = base?.presentedViewController {
                return getCurrentController(base: presented)
            }
            return base
        }
    

    

 
}
