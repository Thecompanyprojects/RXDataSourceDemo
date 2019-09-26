//
//  CategoryListBannerCell.swift
//
//
//  Created by  on 2019/3/21.
//  Copyright © 2019年  rights reserved.
//

import UIKit

class CategoryListBannerCell: UITableViewCell {
    private var bannerImageView :UIImageView?
    var model: SubItems? { didSet { setModel() } }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.accessoryType = .none
        initCellUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategoryListBannerCell {
    
    func initCellUI() {
        self.contentView.backgroundColor = mRGBA(248, 248, 248, 1)
        let imageView = UIImageView().then {
            //$0.image = mImage(name: "account_pic_bg_default")
            $0.isUserInteractionEnabled = true
        }
        self.contentView.addSubview(imageView)
        self.bannerImageView = imageView
        imageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(self).offset(8)
            make.right.equalTo(self).offset(-8)
            make.bottom.equalTo(self).offset(-4)
        }
    }
    
    private func setModel() {
        
        if let url = URL(string: "http:" + (model?.name)!) {
            self.bannerImageView!.kf.setImage(with: url,placeholder: mImage(name:"imagePlace"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.bannerImageView?.rx.tapGesture().when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                guard let strongSelf = self else { return }
               
                AppUtils.jumpToWebView(route: (strongSelf.model?.url)!)
        }).disposed(by: rx.disposeBag)
            
    }
}

