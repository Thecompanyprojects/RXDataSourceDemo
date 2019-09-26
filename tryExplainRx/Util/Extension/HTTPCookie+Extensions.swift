//
//  HTTPCookie+Extensions.swift
//
//
//  Created 2019/3/20.
//  Copyright © 2019年  rights reserved.
//

import Foundation

extension HTTPCookie {
    //将cookie转化为合法的string
    func toString() -> String {
        var strArr = [String]()
        strArr.append("\(name)=\(value)")
        let date = expiresDate ?? Date(timeIntervalSinceNow: 2592000)
        let dateFormater = DateFormatter()
        dateFormater.timeZone = TimeZone(identifier: "GMT")
        dateFormater.locale = Locale.current
        dateFormater.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        strArr.append("expires=\(dateFormater.string(from: date))")
        if domain.count > 0 {
            strArr.append("domain=\(domain)")
        }
        strArr.append("path=\(path)")
        return strArr.joined(separator: ";")
    }
    
    func isExpire() -> Bool {
        let now = Date()
        let date = expiresDate ?? Date()
        return now.compare(date) == .orderedDescending
    }
    
}
