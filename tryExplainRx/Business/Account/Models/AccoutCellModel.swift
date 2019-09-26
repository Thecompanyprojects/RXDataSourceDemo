//
//  AccoutCellModel.swift
//
//
//  Created by  on 2019/3/6.
//  Copyright © 2019年  rights reserved.
//

import UIKit

class AccoutCellModel: NSObject {
    var leftIcon: String?
    // title
    var title: String?
    override init() {
        super.init()
    }
    
    init(leftIcon:String?,title:String?) {
        self.leftIcon = leftIcon
        self.title = title
    }
}


