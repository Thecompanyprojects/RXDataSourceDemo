//
//  MCCommon.swift
//
//
//  Created by  on 2019/2/26.
//  Copyright © 2019年  rights reserved.
//

import UIKit

// 屏幕宽度
let mScreenH = UIScreen.main.bounds.height
// 屏幕高度
let mScreenW = UIScreen.main.bounds.width

//适配iPhoneX 及以上
let is_iPhoneX = (UIApplication.shared.statusBarFrame.size.height == 44 ? true : false)
let mNavibarH: CGFloat = is_iPhoneX ? 88.0 : 64.0
let mTabbarH: CGFloat = is_iPhoneX ? 49.0+34.0 : 49.0
let mStatusbarH: CGFloat = is_iPhoneX ? 44.0 : 20.0
let mSafeBottomH: CGFloat = is_iPhoneX ? 34.0 : 0.0
let iPhoneXTopH: CGFloat = 24.0


let mUserDefaults = UserDefaults.standard

// MARK:- 颜色方法
public func mRGBA (_ r:CGFloat, _ g:CGFloat,_ b:CGFloat,_ a:CGFloat) -> UIColor {
    return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

public func mHex(_ hex:String) -> UIColor {
    return UIColor(hexString: hex)
}
/// 图片
public func mImage(name:String) -> UIImage {
    return UIImage(named: name)!
}
// 字体
public func mFont(_ size:CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size)
}
public func mBlodFont(_ size:CGFloat) -> UIFont {
    return UIFont.boldSystemFont(ofSize: size)
}

// MARK:- 主题配色
let mThemeLabelNormalColor = mRGBA(53, 53, 53, 1)
let mThemePinkColor = mRGBA(243, 101, 99, 1)
let mThemeWhiteColor = mRGBA(255, 255, 255, 1)
let mThemeGrayColor = mRGBA(174, 174, 174, 1)

/// font

let mThemeMinFont = mFont(12)
let mThemeNormalFont = mFont(14)




///过滤null对象
public let mFilterNullOfObj:((Any)->Any?) = {(obj: Any) -> Any? in
    if obj is NSNull {
        return nil
    }
    return obj
}

///过滤null的字符串，当nil时返回一个指定的字符串
public let mFilterNullOfString:((Any,String)->String) = {(obj: Any,defaultValue:String) -> String in
    if obj is String {
        return obj as! String
    }
    return  defaultValue
}
///过滤null的字符串，当nil时返回一个初始化的空字符串
public let mFilterNullWithDefalutString:((Any)->String) = {(obj: Any) -> String in
    if obj is String {
        return obj as! String
    }
    return ""
}


/// 过滤null的数组，当nil时返回一个初始化的空数组
public let mFilterNullOfArray:((Any)->Array<Any>) = {(obj: Any) -> Array<Any> in
    if obj is Array<Any> {
        return obj as! Array<Any>
    }
    return Array()
}

/// 过滤null的字典，当为nil时返回一个初始化的字典
public let mFilterNullOfDictionary:((Any) -> Dictionary<AnyHashable, Any>) = {( obj: Any) -> Dictionary<AnyHashable, Any> in
    if obj is Dictionary<AnyHashable, Any> {
        return obj as! Dictionary<AnyHashable, Any>
    }
    return Dictionary()
}
    
