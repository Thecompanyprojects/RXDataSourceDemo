//
//  NavigationViewController2.swift
//
//
//  Created by  on 2018/8/20.
//  Copyright © 2018年  rights reserved.
//

import UIKit

class OtherPageViewController: UIViewController {
    var animatedOnNavigationBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .bottom

//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        //self.navigationController?.setNavigationBarHidden(true, animated: true)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        guard let navigationController = navigationController else {
            return
        }
        
        //navigationController.navigationBar.barTintColor = UIColor.white
        navigationController.navigationBar.backgroundColor = UIColor.white
        //navigationController.navigationBar.tintColor = UIColor.gray
        //navigationController.navigationBar.isTranslucent = true
        //navigationController.navigationBar.barStyle = .default
        //navigationController.navigationBar.topItem?.title = ""
        
        //let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.gray]
        //navigationController.navigationBar.titleTextAttributes = textAttributes
    }
}
