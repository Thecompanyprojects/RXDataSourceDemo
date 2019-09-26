//
//  PlaceholderView.swift
//
//
//  Created by  on 2019/3/19.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import AttributedTextView


// MARK:- 占位图 通用组件
struct PlaceholderViewItemMetric {
    /// favorite  未登录
    static var noSignIn = PlaceholderViewModel(type: .noSignIn, title: "nofavorite", imageName: "no_favorites", buttonTitle: "SIGNIN", mFrame: CGRect(x: (mScreenW - 58)/2, y: 90 + mStatusbarH, width: 58, height: 71))
    /// 无网络
    static var noNetwork = PlaceholderViewModel(type: .noSignIn, title: "Networkerror", imageName: "noNetwork", buttonTitle: "TRYAGAIN", mFrame: CGRect(x: (mScreenW - 92)/2, y:20, width: 92, height: 102))
    /// bag 未登录
    static var noSignInAndShopping = PlaceholderViewModel(type: .noSignIn, title: "bagNoSign", imageName: "Group", buttonTitle: "CONTINUESHOPPING", mFrame: CGRect(x: (mScreenW - 85)/2, y: 20, width: 85, height: 94))
    
    static var bagEmpty =  PlaceholderViewModel(type: .noSignIn, title: "shoppingbagisempty", imageName: "Group", buttonTitle: "CONTINUESHOPPING", mFrame: CGRect(x: (mScreenW - 85)/2, y: 20, width: 85, height: 94))
    
    /// 请求失败 try
    static var requestError =  PlaceholderViewModel(type: .noSignIn, title: "RequestError", imageName: "noNetwork", buttonTitle: "TRYAGAIN", mFrame: CGRect(x: (mScreenW - 92)/2, y:20, width: 92, height: 102))
}

protocol PlaceholderView {
    
}

// MARK:- 添加到控制器的组件，指定imageView位置即可
extension PlaceholderView where Self : UIViewController {
    // MARK:- 导航栏 通用组件
    func universal(model: PlaceholderViewModel, onNext: @escaping (_ model: PlaceholderViewModel)->Void) {
        
        let imageView = UIImageView().then {
            $0.image = mImage(name: model.imageNamed)
            $0.frame = model.imageFrame
        }
        view.addSubview(imageView)
        
        let label = UILabel().then {
            $0.font = mThemeMinFont
            $0.textColor = mThemeLabelNormalColor
            if model.title == "bagNoSign" {
                $0.attributedText = ( "\("shoppingbagisempty")\n".color(mThemeLabelNormalColor) + "SIGNIN".color(.blue).underline.fontName("Helvetica-Bold") + " ".color(.white) + "Toseethe".color(mThemeLabelNormalColor)).attributedText
                $0.rx.tapGesture().when(.recognized)
                    .subscribe(onNext:{ _ in
                        
                       AppUtils.gotoLogin()
                    }).disposed(by: rx.disposeBag)
            } else {
                $0.text = model.title
            }
          
            $0.textAlignment = .center
            $0.lineBreakMode = .byWordWrapping
            $0.numberOfLines = 0
        }
        let button = UIButton().then{
            $0.setTitle(model.buttonTitle, for: .normal)
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
            $0.backgroundColor = mThemeLabelNormalColor
            $0.rx.tap.do(onNext: {
                onNext(model)
            }).subscribe().disposed(by: rx.disposeBag)
        }
        
        view.addSubview(label)
        view.addSubview(button)
        
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(48)
        }
        button.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(48)
            make.right.equalTo(view).offset(-48)
            make.top.equalTo(label.snp.bottom).offset(16)
            make.height.equalTo(40)
        }
    }
}

// MARK:- 添加到视图的组件，需要自己主动设置位置
extension PlaceholderView where Self : UIView {
    
    // MARK:- 导航栏 通用组件
     func universals(model: PlaceholderViewModel, onNext: @escaping (_ model: PlaceholderViewModel)->Void) -> UIView {
//        let view = UIView().then {
//            $0.frame = CGRect(x: 0, y: 0, width: mScreenW, height: 282)
//        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: mScreenW, height: 282))

        let imageView = UIImageView().then {
            $0.image = mImage(name: model.imageNamed)
            $0.frame = model.imageFrame
        }
        
        
        let label = UILabel().then {
            $0.font = mThemeMinFont
            $0.textColor = mThemeLabelNormalColor
            $0.isUserInteractionEnabled = true
            if model.title == "bagNoSign" {
                
                ///此处 lable .rx.tapGesture 下拉刷新同步,故采用以下写法
                let tapGesture = UITapGestureRecognizer()
                $0.addGestureRecognizer(tapGesture)
                tapGesture.rx.event.bind(onNext: { recognizer in
                    AppUtils.gotoLogin()
                }).disposed(by: rx.disposeBag)
                
                $0.attributedText = (  "\("shoppingbagisempty")\n".color(mThemeLabelNormalColor) + "SIGNIN".color(.blue).underline.fontName("Helvetica-Bold") + " ".color(.white) + "Toseethe".color(mThemeLabelNormalColor)).attributedText
                
            } else {
                $0.text = model.title
            }
            
            $0.textAlignment = .center
            $0.lineBreakMode = .byWordWrapping
            $0.numberOfLines = 0
        }
        let button = UIButton().then{
            $0.setTitle(model.buttonTitle, for: .normal)
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
            $0.backgroundColor = mThemeLabelNormalColor
            $0.rx.tap.do(onNext: {
                onNext(model)
            }).subscribe().disposed(by: rx.disposeBag)
        }
        self.addSubview(view)
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(button)
       
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(48)
        }
        button.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(48)
            make.right.equalTo(view).offset(-48)
            make.top.equalTo(label.snp.bottom).offset(16)
            make.height.equalTo(40)
        }
        return view
    }
}

struct PlaceholderViewModel {
    /// 类型
    enum PlaceholderViewType {
        /// 未登录
        case noSignIn
        /// 无网络
        case noNetwork
        /// 登录&去首页
        case noSignInAndShopping
        ///  Favorite无数据
        case noFavorite
        /// bag无数据
        case bagEmpty
    }
    
    var type: PlaceholderViewType
    var title: String?
    var description: String?
    var imageNamed: String
    var imageFrame: CGRect
    var buttonTitle: String
    
    /// 图片/文字/按钮型
    init(type:PlaceholderViewType,title:String,imageName:String,buttonTitle:String,mFrame:CGRect) {
        self.type = type
        self.title = title
        self.imageNamed = imageName
        self.description = nil
        self.imageFrame = mFrame
        self.buttonTitle = buttonTitle
    }
    
    init(type:PlaceholderViewType,title:String,description:String,imageName:String,buttonTitle:String,mFrame:CGRect) {
        self.type = type
        self.title = title
        self.imageNamed = imageName
        self.description = description
        self.imageFrame = mFrame
        self.buttonTitle = buttonTitle
    }
    
}



