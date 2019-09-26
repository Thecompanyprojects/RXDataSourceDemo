//
//  AccountServerCell.swift
//
//
//  Created by  on 2019/3/6.
//  Copyright © 2019年  rights reserved.
//

import UIKit
// MARK:- 常量
fileprivate struct Metric {
    
    static let cellHeight: CGFloat = 56.0
    static let titleFontSize: CGFloat = 14.0
    static let lineHeight: CGFloat = 0.5
    static let titleLabelColor :UIColor = mRGBA(0, 0, 0, 1)
}

class AccountServerCell: UITableViewCell {
    // 下划线
    private var bottomLine: UIView?
    // 左侧图标
    private var leftIcon: UIImageView?
    // title
    private var titleLable: UILabel?
    // 右侧箭头
    private var rightIcon: UIImageView?
    
    var model: AccoutCellModel? { didSet { setModel() } }
    
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

extension AccountServerCell {
    func initCellUI() {
        // 创建组件
        let leftIcon = UIImageView().then {
            $0.contentMode = .scaleAspectFit
        }
        let titleLable = UILabel().then {
            $0.textColor = Metric.titleLabelColor
            $0.font = UIFont.systemFont(ofSize: Metric.titleFontSize)
            $0.textAlignment = .left
        }
        let rightIcon = UIImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = mImage(name: "arrow_right")
        }
        let bottomLine = UIView().then {
            $0.backgroundColor = mRGBA(238, 238, 238, 1)
        }
        self.addSubview(leftIcon)
        self.addSubview(titleLable)
        self.addSubview(rightIcon)
        self.addSubview(bottomLine)
        
        /// 赋值
        self.leftIcon = leftIcon
        self.titleLable = titleLable
        self.rightIcon = rightIcon
        self.bottomLine = bottomLine
        
        // 布局
        leftIcon.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(24)
            make.top.equalTo(self).offset(16)
            make.width.height.equalTo(24)
        }
        titleLable.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(leftIcon.snp.right).offset(24)
            make.width.equalTo(200)
            make.height.equalTo(16)
        }
        rightIcon.snp.makeConstraints { (make) in
            make.width.equalTo(8)
            make.height.equalTo(16)
            make.right.equalTo(self).offset(-16)
            make.centerY.equalTo(self)
        }
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(titleLable)
            make.right.equalTo(self)
            make.height.equalTo(0.5)
            make.bottom.equalTo(self).offset(-0.5)
        }
    }
    
    
    private func setModel() {
        if let leftIcon = model?.leftIcon {
            self.leftIcon?.image = mImage(name:leftIcon)
        }
        if let title = model?.title {
            self.titleLable?.text = title
        }
    }
    
    
}

