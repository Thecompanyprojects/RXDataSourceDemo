//
//  Localizer.swift
//
//
//  Created 2018/8/22.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import UIKit
import CommonCrypto



let BaseBundle = "Base"
let DefaultTable = "Translate"

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }

    func localized(using tableName: String? = DefaultTable) -> String {
        let currtLang = AppUtils.getUserLanguage()
        let resource = self.getResourceName(lang: currtLang)
        let bundle = Bundle.main
        if let path = bundle.path(forResource: resource, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: tableName)
        }
        else if let path = bundle.path(forResource: BaseBundle, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: tableName)
        }
        return self
    }
    
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize(count: digestLen)
        return String(format: hash as String)
    }
   
    private func getResourceName(lang: String) -> String {
        let langMap = [
            "no" : "nn-NO",
            "se" : "sv-SE",
            "uk" : "uk-UA",
            "ru" : "ru-RU"
        ]
        if let resource = langMap[lang] {
            return resource
        }
        return lang
    }
    
    func stringWidthForComment(fontSize: CGFloat, height: CGFloat = 15) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
    
    func stringHeightForComment(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
    
    /// 计算字符串宽度
    func stringHeightForComment(fontSize: CGFloat, width: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)>maxHeight ? maxHeight : ceil(rect.height)
    }
    
    //  正则匹配email
    func checkEmail() ->Bool {
        let string = self.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "/", with: "")
        let pattern = "(|^)([\\w+._]+@\\w+\\.(\\w+\\.){0,3}\\w{2,4})"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        let isMatch:Bool = pred.evaluate(with: string)
        return isMatch;
    }
    
    func checkHostUrl() ->Bool {
        
        let string =  self.replacingOccurrences(of: "//", with: "/").replacingOccurrences(of: "#/", with: "")
        //无语言无参数的情况
        let regex1 = "^https?:/[^.]+\\.\(AppConfig.HOST_KEY)\\.[^/]+/?$"
        //有语言无参数的情况
        let regex2 = "^https?:/[^.]+\\.\(AppConfig.HOST_KEY)\\.[^/]+/[a-z]{2}/?$"
        //无语言有参数
        let regex3 = "^https?:/[^.]+\\.\(AppConfig.HOST_KEY)\\.[^/]+/?\\?.*$"
        //有语言有参数的情况
        let regex4 = "^https?:/[^.]+\\.\(AppConfig.HOST_KEY)\\.[^/]+/[a-z]{2}/?\\?.*$"
        
        
        
        
        
        return DRegex(regex1).match(input: string) || DRegex(regex2).match(input: string) || DRegex(regex3).match(input: string) || DRegex(regex4).match(input: string)
        
    }
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    func checkCartUrl() ->Bool {
        let string =  self.replacingOccurrences(of: "//", with: "/").replacingOccurrences(of: "#/", with: "")
        //无语言无参数的情况
        let regex1 = "https?:/[^.]+\\.\(AppConfig.HOST_KEY)\\.[^/]+/cart.php/?"
        //有语言无参数的情况
        let regex2 = "https?:/[^.]+\\.\(AppConfig.HOST_KEY)\\.[^/]+/[a-z]{2}/cart.php/?"
        //无语言有参数
        let regex3 = "https?:/[^.]+\\.\(AppConfig.HOST_KEY)\\.[^/]+/cart.php\\?.*"
        //有语言有参数的情况
        let regex4 = "https?:/[^.]+\\.\(AppConfig.HOST_KEY)\\.[^/]+/[a-z]{2}/cart.php\\?.*"
        
        return DRegex(regex1).match(input: string) || DRegex(regex2).match(input: string) || DRegex(regex3).match(input: string) || DRegex(regex4).match(input: string)
    }
    
    /// 判断checkout url
    func checkCheckOutUrl() -> Bool {
        let pattern = ".+act=checkout_payment_process.*(#/)?"
        let urlString = self.replacingOccurrences(of: "#/", with: "").replacingOccurrences(of: "//", with: "/")
        return urlString.range(of: pattern, options: .regularExpression) != nil ? true : false
    }
    
    /// 信用卡支付界面 url
    func checkCreditCardPayNowUrl() -> Bool {
        return self.contains("pay_now")
    }
}
