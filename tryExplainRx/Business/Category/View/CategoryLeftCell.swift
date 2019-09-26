//
//  CategoryLeftCell.swift
//
//
//  Created by  on 2019/3/20.
//  Copyright © 2019年  rights reserved.
//

import UIKit

class CategoryLeftCell: UITableViewCell {
    // 左侧图标
    private var selectedView: UIView?
    // title
    private var titleLable: UILabel?
    
    var model: ParentItem? { didSet { setModel() } }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.accessoryType = .none
        initCellUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectedView?.isHidden = !selected
        self.backgroundColor = selected ? mThemeWhiteColor :mRGBA(235, 235, 235, 1)
    }

}
extension CategoryLeftCell {
    
    func initCellUI() {
        self.backgroundColor = mRGBA(235, 235, 235, 1)
        // 创建组件
        let selectedView = UIView().then {
            $0.backgroundColor = mThemePinkColor
            $0.isHidden = true
        }
        let titleLable = UILabel().then {
            $0.textColor = mThemeLabelNormalColor
            $0.font = mThemeMinFont
            $0.textAlignment = .center
        }
        
        self.addSubview(selectedView)
        self.addSubview(titleLable)
        /// 赋值
        self.selectedView = selectedView
        self.titleLable = titleLable
        // 布局
        selectedView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(0)
            make.top.equalTo(self).offset(0)
            make.width.equalTo(3)
            make.height.equalTo(self)
        }
        titleLable.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(0)
            make.width.equalTo(104)
            make.height.equalTo(14)
        }
     
    }
    
    
    private func setModel() {
        if let title = model?.name {
            self.titleLable?.text = title
        }
    }
    
    
}
