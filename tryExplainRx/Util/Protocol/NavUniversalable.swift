//
//  NavUniversalable.swift
//
//
//  Created by  on 2019/3/1.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Then

// MARK:- 常量
fileprivate struct Metric {
    static let itemSize: CGFloat = 30.0
}

// MARK:- 导航栏 通用组件
struct NavigationBarItemMetric {
    /// left
    /// 列表
    static let list = NavigationBarItemModel(type: .list,
                                               position: .left,
                                               description: "list",
                                               imageNamed: "list",
                                               mFrame:CGRect(x: 0, y: 0, width: 20, height: 15))
    ///right
    /// 搜索
    static let search = NavigationBarItemModel(type: .search,
                                                 position: .right,
                                                 description: "search",
                                                 imageNamed: "search",
                                                 mFrame:CGRect(x: 0, y: 0, width: 20, height: 20))
    
    ///left
    /// back
    static let back = NavigationBarItemModel(type: .back,
                                               position: .left,
                                               description: "back",
                                               imageNamed: "setting_back",
                                               mFrame:CGRect(x: -20, y: 0, width: 40, height: 30))
    
    ///right
    ///bag
    static let bag = NavigationBarItemModel(type: .bag,
                                            position: .right,
                                            description: "bag",
                                            imageNamed: "shopping_cart_selected",
                                            mFrame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    ///right
    /// menu
    static let menu = NavigationBarItemModel(type: .menu,
                                             position: .right,
                                             description: "menu",
                                             imageNamed: "shopping_cart_selected",
                                             mFrame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
}



protocol NavUniversalable {
    
}

// MARK:- 添加到视图的组件，需要自己主动设置位置
extension NavUniversalable where Self : UIView {
    
    // MARK:- 导航栏 通用组件
    func universal(model: NavigationBarItemModel, onNext: @escaping (_ model: NavigationBarItemModel)->Void) -> UIView {
        // 创建组件
        let view = UIView().then {
            $0.backgroundColor = .clear
        }
        let btn = UIButton().then {
            // 设置属性
            $0.contentMode = .scaleAspectFit
            $0.setTitle(model.title, for: .normal)
            $0.setBackgroundImage(UIImage(named: model.imageNamed), for: .normal)
            $0.rx.tap.subscribe(onNext:{_ in
                onNext(model)
            }).disposed(by: rx.disposeBag)
        }
        
        // 添加组件
        view.addSubview(btn)
        self.addSubview(view)
        // 添加约束
        // 此处必须指定一个大小
        view.snp.makeConstraints { (make) in
            make.width.height.equalTo(Metric.itemSize)
            make.centerY.equalToSuperview()
            switch model.position {
            case .left :
                make.left.equalTo(self.snp_leftMargin).offset(16)
            case.right :
                make.left.equalTo(self.snp_rightMargin).offset(-40)
            case .center: break
            }
        }
        btn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return view
    }
}

// MARK:- 添加到控制器的组件，指定位置即可
extension NavUniversalable where Self : UIViewController {
    // MARK:- 导航栏 通用组件
    func universal(model: NavigationBarItemModel, onNext: @escaping (_ model: NavigationBarItemModel)->Void) {
        
        var item: UIBarButtonItem
        
        if model.title != nil {
            // 标题
            item = UIBarButtonItem(title: model.title, style: .plain, target: nil, action: nil)
            item.rx.tap.do(onNext: {
                onNext(model)
            }).subscribe().disposed(by: rx.disposeBag)
            
        } else {
            // 图标
            var btn = UIButton(type: .custom)

            if model.type == .bag {
                let button = MCBadgeButton(type: .custom).then{
                    $0.anchor = 1
                    let badgeValue =  UserDefaults.AccountInfo.integer(forKey: .cartGoodsTotal)
                    $0.badgeString = badgeValue! > 0 ? String(badgeValue!) : ""
                }
                /// 监听购物车数量变化
                let cartGoodsTotal = UserDefaults.AccountInfo.keyString(forKey: .cartGoodsTotal)
                let observer = UserDefaults.standard.rx.observe(Int.self, cartGoodsTotal!,options: [.new]).debounce(0.01, scheduler: MainScheduler.asyncInstance)
                observer.subscribe(onNext: { (value) in
                    if value != nil {
                        button.badgeString = value! > 0 ? String(value!) : ""
                    }
                }).disposed(by: rx.disposeBag)
                btn = button
            }
            
            btn.frame = model.mFrame
            btn.setImage(UIImage(named: model.imageNamed), for: .normal)
            if model.highlightedImageNamed.utf8CString.count > 0 {
                btn.setImage(UIImage(named: model.highlightedImageNamed), for: .highlighted)
                if model.type == .back {
                    let size = CGSize(width: 11, height: 20)
                    btn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -size.width - 20, bottom: 0, right: 0)
                    btn.imageView?.sizeThatFits(size)
                }
            }
            
            btn.rx.tap.do(onNext: {[weak self] _ in
                guard let strongSelf = self else { return }
                switch model.type {
                case .menu:
                    strongSelf.menuButtonClick(btn:btn)
                    return
                default:
                    break
                }
                onNext(model)
            }).subscribe().disposed(by: rx.disposeBag)
            item = UIBarButtonItem(customView: btn)
        }
        
        switch model.position {
        case .left:
            item.width = -15
            if (navigationItem.leftBarButtonItems?.count ?? 0) == 0 {
                navigationItem.leftBarButtonItems = [item]
            } else {
                var items: [UIBarButtonItem] = [] + navigationItem.leftBarButtonItems!
                items.append(item)
                navigationItem.leftBarButtonItems = items
            }
            break
        case .right:
            
            if (navigationItem.rightBarButtonItems?.count ?? 0) == 0 {
                navigationItem.rightBarButtonItems = [item]
            } else {
                var items: [UIBarButtonItem] = [] + navigationItem.rightBarButtonItems!
                items.append(item)
                navigationItem.rightBarButtonItems = items
            }
            break
        default :
            break
        }
    }
    
    private func menuButtonClick(btn:UIButton) {
       
    }
    
    // MARK:- 导航栏 通用组件
    func universals(modelArr: [NavigationBarItemModel], onNext: @escaping (_ model: NavigationBarItemModel)->Void) {
        modelArr.enumerated().forEach { (index, element) in
            let temp = element
            self.universal(model: temp) { model in
                onNext(model)
            }
        }
    }
}



// MARK:- 导航栏 通用组件 数据模型
struct NavigationBarItemModel {
    /// 位置
    enum NavigationBarItemPosition {
        case left
        case center
        case right
    }
    /// 类型
    enum NavigationBarItemType {
        case list
        case search
        case bag
        case menu
        case back
        case other
    }
    
    var type: NavigationBarItemType
    var position: NavigationBarItemPosition
    var title: String?
    var description: String
    var imageNamed: String
    var highlightedImageNamed: String
    var mFrame: CGRect
  
    
    ///文字型
    init(type: NavigationBarItemType, position: NavigationBarItemPosition, title: String, description: String, mFrame:CGRect) {
        self.type = type
        self.position = position
        self.title = title
        self.description = description
        self.imageNamed = ""
        self.highlightedImageNamed = ""
        self.mFrame = mFrame
    }
    
    /// 图片点击无效果型
    init(type: NavigationBarItemType, position: NavigationBarItemPosition, description: String, imageNamed: String, mFrame:CGRect) {
        self.type = type
        self.position = position
        self.title = nil
        self.description = description
        self.imageNamed = imageNamed
        self.highlightedImageNamed = ""
        self.mFrame = mFrame
    }
    
    
    /// 图片点击有效果型
    init(type: NavigationBarItemType, position: NavigationBarItemPosition, description: String, imageNamed: String, highlightedImageNamed: String, mFrame:CGRect) {
        self.type = type
        self.position = position
        self.title = nil
        self.description = description
        self.imageNamed = imageNamed
        self.highlightedImageNamed = highlightedImageNamed
        self.mFrame = mFrame
    }
}
