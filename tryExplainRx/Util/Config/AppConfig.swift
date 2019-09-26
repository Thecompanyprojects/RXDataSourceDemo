//
//  AppConfig.swift
//
//
//  Created 2018/8/6.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import UIKit
 
class AppConfig {

    public static let JS_BRIDGE = "VVJSBridge"
    public static let DEBUG = DEBUG_ENV
    
    public static let HOST = HOST_NAME
    
    //对于第三方页面的判断
    public static let HOST_KEY = "\(De)\(qu)"
    
 
    public static let PROTOCOL = "https"
    
    private static let _home = "\(PROTOCOL)://\(HOST)"

    public static var HOME: String {
        get {
            let home = AppUtils.get("APP_HOST_NAME")
            if home.count > 0, home.caseInsensitiveCompare(_home) != .orderedSame {
                return home
            }
            return _home
        }
        set {
            var value = newValue
            if !newValue.starts(with: PROTOCOL) {
                value = "\(PROTOCOL)://\(newValue)"
            }
            if value.caseInsensitiveCompare(_home) != .orderedSame {
                AppUtils.save("APP_HOST_NAME", value)
            }
        }
    }
    
    public static let AGENT_KEY: String = {
        let version = AppConfig.VERSION == nil ? "1" : AppConfig.VERSION as! String
        let systemVersion = UIDevice.current.systemVersion
        return " Version/\(systemVersion) (lq-App \(ET)\(cA) \(version)) Safari"
    }()
    
    public static let VERSION = Bundle.main.infoDictionary?["CFBundleVersion"]
    
    public static let VERSION_STRING = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
    
    public static let STAGE = STAGE_ENV

    public static var NOTIFICATION_PATH : String? = nil

    

    
}
