//
//  MCMenuPoppipCell.swift
//
//
//  Created by  on 2019/5/20.
//  Copyright © . All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxDataSources

// MARK:- 常量
fileprivate struct Metric {
    static let valueFontSize: CGFloat = 14
    static let valueLabelHeight: CGFloat = 20
    static let valueLabelWidth: CGFloat = 50
}

class MCMenuPopViewCell: UITableViewCell,Reusable {
    //// ["title","image","showValueLabel"]
    var model: [String]? { didSet { setModel() } }
    
    lazy var valueLabel: UILabel = {
        let label = UILabel().then{
            $0.textAlignment = .center
            $0.textColor = mThemePinkColor
            $0.font = mFont(Metric.valueFontSize)
            let badgeValue =  UserDefaults.AccountInfo.integer(forKey: .favoriteGoodsTotal)
            $0.text = badgeValue! > 0 ? String(badgeValue!) : ""
        }
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(valueLabel)
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        valueLabel.snp.makeConstraints { (make) in
            make.width.equalTo(Metric.valueLabelWidth)
            make.height.equalTo(Metric.valueLabelHeight)
            make.right.equalTo(contentView)
            make.centerY.equalTo(contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MCMenuPopViewCell {
    func setModel(){
        if (model?.count)! > 2 {
            imageView?.image = mImage(name: (model?[1])!)
            textLabel?.textColor = .white
            textLabel?.text = model?.first!
            if let showValue = Bool((model?.last!)!),showValue {
                valueLabel.isHidden = false
                let favoriteGoodsTotal = UserDefaults.AccountInfo.keyString(forKey: .favoriteGoodsTotal)
                let observer = UserDefaults.standard.rx.observe(Int.self, favoriteGoodsTotal!,options: [.new]).debounce(0.01, scheduler: MainScheduler.asyncInstance)
                observer.subscribe(onNext: {[weak self] (value) in
                    guard let strongSelf = self else { return }
                    if value != nil {
                        strongSelf.valueLabel.text = value! > 0 ? String(value!) : ""
                    }
                }).disposed(by: rx.disposeBag)
            } else {
                valueLabel.isHidden = true
            }
        }
    }
}


struct MCMenuPoppipSection {
    var items: [Item]
}

extension MCMenuPoppipSection: SectionModelType {
    typealias Item = [String]
    init(original: MCMenuPoppipSection, items: [Item]) {
        self = original
        self.items = items
    }
}
