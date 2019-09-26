//
//  MainTabBarController.swift
//
//
//  Created by  on 2019/2/27.
//  Copyright © 2019年  rights reserved.
//

import UIKit


class MainTabBarController: UITabBarController,UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // tabbar 普通状态下的文字属性
        let tabbarNormalAttrs = [NSAttributedString.Key.foregroundColor : mThemeLabelNormalColor]
        // tabbat 选中状态下的文字属性
        let tabbarSelectedAttrs = [NSAttributedString.Key.foregroundColor : mThemePinkColor]
        UITabBarItem.appearance().setTitleTextAttributes(tabbarNormalAttrs, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(tabbarSelectedAttrs, for: .selected)
        //背景色
        UITabBar.appearance().backgroundColor = mRGBA(255, 255, 255, 0.8)
        // rootviewcontroller 设置
        self.delegate = self
     


        configChild(CategoryViewController(), title: "Category", image: "menu", selectedImage: "menu_selected")
    
        configChild(AccountViewController(), title: "Account", image: "profile", selectedImage: "profile_selected")
        
    }
    

    func configChild(_ vc: UIViewController, title: String, image: String, selectedImage: String){
        
        vc.navigationItem.title = title
        vc.tabBarItem.title = title
        vc.tabBarItem.image = UIImage(named: image)
        vc.tabBarItem.selectedImage = UIImage(named: selectedImage)
        
        let navi = UINavigationController(rootViewController: vc)
        addChild(navi)
    }
    

    
}
