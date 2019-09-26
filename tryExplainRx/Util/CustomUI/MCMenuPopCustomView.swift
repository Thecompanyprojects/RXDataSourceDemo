//
//  MCMenuPopCustomView.swift
//
//
//  Created by  on 2019/5/20.
//  Copyright © . All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

// MARK:- 常量
fileprivate struct Metric {
    static let width: CGFloat = (mScreenW - 30)/2
    static let height: CGFloat = 60
}

class MCMenuPopCustomView: UITableView {
    ///
    private lazy var dataSour = RxTableViewSectionedReloadDataSource<MCMenuPoppipSection>( configureCell: { [weak self] ds, tv, ip, item in
        guard  let strongSelf = self else { return UITableViewCell()}
        let cell : MCMenuPopViewCell = tv.dequeueReusableCell(for: ip)
        cell.model = item
        return cell
    })
    
    override init(frame: CGRect,style: UITableView.Style) {
        super.init(frame: CGRect(x: 0, y:0, width: Metric.width, height: Metric.height),style: .plain)
        separatorStyle = .none
        register(cellType: MCMenuPopViewCell.self)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        rowHeight = Metric.height / 2
        if #available(iOS 11.0, *) {
           // contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever
            contentInsetAdjustmentBehavior = .never
        }
        
        let items =  Observable.just([
            MCMenuPoppipSection(items: [["Home","home","false"],
                                        ["Favorites","love","true"]])
            ])
        
        items.bind(to: rx.items(dataSource: dataSour))
            .disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



