//
//  NumberUtils.swift
//
//
//  Created 2018/12/5.
//  Copyright © 2018年  rights reserved.
//

import Foundation


class NumberUtils {

    static func tryDouble(_ value: Any?) -> Double? {
        guard let val = value else {
            return nil
        }
        if val is NSNumber {
            return (val as? NSNumber)?.doubleValue
        } else if let valStr = val as? String {
            return Double(valStr)
        }
        return nil
    }

}
