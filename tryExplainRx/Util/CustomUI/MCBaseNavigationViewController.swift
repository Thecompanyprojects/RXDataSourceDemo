//
//  MCBaseNavigationViewController.swift
//
//
//  Created by  on 2019/3/2.
//  Copyright © 2019年  rights reserved.
//

import UIKit

class MCBaseNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.setBackgroundImage(UIImage.color(mThemeWhiteColor), for: UIBarPosition.any, barMetrics: .default)
        navigationBar.shadowImage = UIImage()
    }
    
}

