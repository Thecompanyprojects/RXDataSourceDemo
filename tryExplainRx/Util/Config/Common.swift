//
//  Common.swift
//
//
//  Created by  on 2018/8/17.
//  Copyright © 2018年  rights reserved.
//

import UIKit

struct Common {
    static let statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let screenHeight = UIScreen.main.bounds.height
    
    static let tableViewHeaderHeight: CGFloat = 50
    
    static let tableViewCellHeight: CGFloat = 40
    
    static let navigationBarHeight: CGFloat = 44
    
    static let settingVersionFooterHeight: CGFloat = 40
    
    static let sysLang = Locale(identifier: Locale.preferredLanguages.first!).languageCode!
}
