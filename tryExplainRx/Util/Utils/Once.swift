//
//  Once.swift
//
//
//  Created 2018/8/21.
//  Copyright © 2018年  rights reserved.
//

import Foundation


class Once {
    private static var signs = [String]()
    
    static func once(_ sign: String, block: () -> Void) {
        if !signs.contains(sign) {
            signs.append(sign)
            block()
        }
    }
    
}
