//
//  SettingSelectorCell.swift
//
//
//  Created by  on 2019/3/13.
//  Copyright © 2019年  rights reserved.
//

import UIKit

class SettingSelectorCell: UITableViewCell {

    // 选中图片
     var selectedIcon: UIImageView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initCellUI()
        self.accessoryType = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //self.selectedIcon?.isHidden = !selected
    }
    

}

extension SettingSelectorCell {
    func initCellUI() {
        let icon = UIImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = mImage(name: "setting_icon_choose")
            $0.isHidden = true
        }
        self.addSubview(icon)
        /// 赋值
        self.selectedIcon = icon
        // 布局
        icon.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.right.equalTo(self).offset(-16)
            make.centerY.equalTo(self)
        }
       
    }
}
