//
//  AccountLandCell.swift
//
//
//  Created by  on 2019/3/6.
//  Copyright © 2019年  rights reserved.
//

import UIKit
// MARK:- 常量
fileprivate struct Metric {
    
    static let buttonWidth: CGFloat = mScreenW/4
   
}
class AccountLandCell: UITableViewCell {
    private var rootVC:UIViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initCellUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension AccountLandCell {
    func initCellUI() {
        let titleArray:[String] = ["Orders","Coupons","Message","Address"]
        let imagesArray:[String] = ["account_icon_orders","account_icon_coupons","account_icon_message","account_icon_address"]
        let lineView = UIView().then {
            $0.backgroundColor = mRGBA(238, 238, 238, 1)
        }
       let accoutModel = AccountModel.mapModel(from: NetWorkManager.getCacheString(key: "accountData"))
        let jumpUrlList: [String]? = ([accoutModel.orderUrl,accoutModel.couponsUrl,accoutModel.messageUrl,accoutModel.addressUrl])
        var currentVIew :UIView?

        for title in titleArray {
            let view = UIView().then {
                $0.backgroundColor = .white
            }
            let index = titleArray.firstIndex(of:title)
            let imageView = UIImageView(image: mImage(name:imagesArray[index!] ))
            let titleLabel = UILabel().then {
                $0.text = title
                $0.font = mThemeNormalFont
                $0.textAlignment = .center
                $0.numberOfLines = 0
                $0.lineBreakMode = .byWordWrapping
            }
           
            let button = UIButton().then {
                $0.rx.tap.subscribe(onNext:{
                    
                    
                    if AppUtils.checkLoginStatus() {
                        guard jumpUrlList != nil else { return }
                        AppUtils.jumpToWebView(route: jumpUrlList![index!])
                        
                    }else {
                       AppUtils.gotoLogin()
                    }
                }).disposed(by: rx.disposeBag)
            }
            
            self.addSubview(view)
            view .addSubview(imageView)
            view.addSubview(titleLabel)
            view.addSubview(button);
            
            view.snp.makeConstraints { (make) in
                if currentVIew != nil {
                    make.left.equalTo(currentVIew!.snp.right)
                } else {
                    make.left.equalTo(self)
                }
                make.top.equalTo(self)
                make.width.equalTo(Metric.buttonWidth)
                make.height.equalTo(96)
            }
            currentVIew = view
            imageView.snp.makeConstraints { (make) in
                make.width.height.equalTo(32)
                make.top.equalTo(view.snp.top).offset(16)
                make.centerX.equalTo(view)
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.width.equalTo(view.snp.width)
                make.top.equalTo(imageView.snp.bottom).offset(8)
                make.centerX.equalTo(view)
            }
            button.snp.makeConstraints { (make) in
                make.left.equalTo(view)
                make.top.equalTo(view)
                make.width.equalTo(view)
                make.height.equalTo(view)
            }
            
        }
        self.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalTo(self.snp.bottom).offset(-8.5)
        }
        
        
    }
}
