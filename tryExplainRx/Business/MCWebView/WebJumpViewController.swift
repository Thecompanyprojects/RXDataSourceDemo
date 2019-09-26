//
//  WebJumpViewController.swift
//
//
//  Created by  on 2019/3/15.
//  Copyright © 2019年  rights reserved.
//

import UIKit

class WebJumpViewController: BaseWebViewController {
    override func viewDidLoad() {
        istabbarVC = false
        super.viewDidLoad()
        showLoading()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        
        super.didMove(toParent: parent)
        if parent == nil {
           ProgressHUD.dismissHUD()
        }
    }
}
