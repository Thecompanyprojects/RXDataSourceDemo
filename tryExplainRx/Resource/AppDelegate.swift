//
//  AppDelegate.swift
//
//
//  Created 2018/8/4.
//  Copyright © 2018年  rights reserved.
//

import UIKit
import UserNotifications

import Alamofire

import RxSwift



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //rootViewcontroller
        configUA()
        let launchPage = LaunchPageView(duration: 3)
        launchPage.show()
        
        NetWorkManager.initProvide()
        self.window = UIWindow()
        self.window?.frame  = UIScreen.main.bounds
        self.window?.rootViewController = MainTabBarController()
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        

        // 光标颜色
        UITextField.appearance().tintColor = mThemePinkColor
      
        self.configThirdServer(application, launchOptions: launchOptions)
        return true
    }
    

  
    



    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    
    /// 全局配置UA
    /// 配置后all webivew 不需要再customUA
    ///
    private func configUA() {
        let webview = UIWebView()
        let currentUA = webview.stringByEvaluatingJavaScript(from: "navigator.userAgent")
        let newUA = currentUA! + AppConfig.AGENT_KEY
        let dictionary: [String:String] = ["UserAgent":newUA]
        mUserDefaults.register(defaults: dictionary)
    }
  
}
