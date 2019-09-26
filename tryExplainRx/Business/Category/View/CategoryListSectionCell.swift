//
//  CategoryListSectionCell.swift
//
//
//  Created by  on 2019/3/21.
//  Copyright © 2019年  rights reserved.
//

import UIKit

fileprivate struct Metric {
    static let rootItemButtonWidth: CGFloat = (mScreenW - 136 - 108)/3
    static let rootItemButtonHeight: CGFloat = (rootItemButtonWidth)/44 * 63
}


class CategoryListSectionCell: UITableViewCell {
    private var backView:UIView?
    private var titleLabel:UILabel?
    var model: SubItems? { didSet { setModel() } }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.accessoryType = .none
        self.contentView.backgroundColor = mRGBA(248, 248, 248, 1)
        initCellUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategoryListSectionCell {
    func initCellUI() {
        let back = UIView().then {
            $0.layer.backgroundColor = mThemeWhiteColor.cgColor
            $0.layer.shadowColor = mRGBA(0, 0, 0, 0.08).cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowOpacity = 1
            $0.layer.shadowRadius = 4
        }
        
        let title = UILabel().then {
            $0.font = UIFont(name: "Roboto Medium", size: 14)
            $0.textAlignment = .left
            $0.textColor = mThemeLabelNormalColor
        }
        self.contentView.addSubview(back)
        //back.addSubview(title)
        //back.addSubview(button)
        
        
        
        back.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(4)
            make.bottom.equalTo(self).offset(-4)
            make.left.equalTo(self).offset(8)
            make.right.equalTo(self).offset(-8)
        }
        self.backView = back
        self.titleLabel = title
    }
    
    private func setModel() {
        for view in self.backView!.subviews {
            view.removeFromSuperview()
        }
        let moreButton = UIButton().then {
            $0.setTitle("All" + " >>", for: .normal)
            $0.titleLabel?.font = mThemeMinFont
            //$0.titleLabel?.sizeToFit()
            $0.setTitleColor(mThemeLabelNormalColor, for: .normal)
        }
        
        self.backView!.addSubview(self.titleLabel!)
        self.backView!.addSubview(moreButton)
        
        if let title = model?.name {
            self.titleLabel?.text = title
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.width.equalTo(("All" + " >>").stringWidthForComment(fontSize: 12))
            make.right.equalTo(self.backView!).offset(2)
            make.height.equalTo(16)
            make.centerY.equalTo(self.titleLabel!)
        }
        self.titleLabel!.snp.makeConstraints { (make) in
            make.top.equalTo(self.backView!).offset(6)
            make.left.equalTo(self.backView!).offset(11)
            make.right.equalTo(moreButton.snp.left).offset(-2)
            make.height.equalTo(20)
        }
       
        moreButton.isHidden = true
        
       
        if let url = model?.url {
            if url.count > 1 {
                moreButton.isHidden = false
                
                moreButton.rx.tap.do(onNext: {
                    AppUtils.jumpToWebView(route: url)
                }).subscribe().disposed(by: rx.disposeBag)
            }
        }
        
        if let rootItems = self.model?.children {
            var currentButton :UIButton?
            var x:CGFloat = 138
            for rootItem in rootItems {
                let itemButton = UIButton().then{
                    $0.kf.setBackgroundImage(with: URL(string: "http:" + rootItem.img), for: .normal, placeholder: mImage(name:"imagePlace"), options: nil, progressBlock: nil, completionHandler: nil)
                 
                    $0.rx.tap.do(onNext: {
                        
                        AppUtils.jumpToWebView(route: rootItem.url)
                    }).subscribe().disposed(by: rx.disposeBag)
                }
                
                let itemTitle = UILabel().then {
                    $0.font = mThemeMinFont
                    $0.textColor = mThemeLabelNormalColor
                    $0.text = rootItem.name
                    $0.textAlignment = .center
                    $0.lineBreakMode = .byWordWrapping
                    $0.numberOfLines = 0
                }
                self.backView?.addSubview(itemButton)
                self.backView?.addSubview(itemTitle)
                
                itemButton.snp.makeConstraints { (make) in
                    make.width.equalTo(Metric.rootItemButtonWidth)
                    make.height.equalTo(Metric.rootItemButtonHeight)
                    if currentButton == nil {
                        x = 138
                        make.left.equalTo(self.backView!).offset(18)
                        make.top.equalTo(self.backView!).offset(32)
                    } else {
                        x +=  Metric.rootItemButtonWidth + 36
                        if x >= mScreenW  {
                            x = 138
                            make.left.equalTo(self.backView!).offset(18)
                            make.top.equalTo((currentButton?.snp.bottom)!).offset(42)
                        }else {
                            make.left.equalTo((currentButton?.snp.right)!).offset(36)
                            make.top.equalTo(currentButton!)
                        }
                    }
                    currentButton = itemButton
                }
                
                itemTitle.snp.makeConstraints { (make) in
                    make.width.equalTo(Metric.rootItemButtonWidth + 20)
                    make.height.equalTo(30)
                    make.top.equalTo(itemButton.snp.bottom).offset(10)
                    make.centerX.equalTo(itemButton)
                }
               
            }
        }
    }
}
