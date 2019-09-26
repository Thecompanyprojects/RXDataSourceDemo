//
//  MCRefreshable.swift
//
//
//  Created by  on 2019/3/20.
//  Copyright © 2019年  rights reserved.
//



let qu = "voga"
let cA = "Voga"


import UIKit
import RxSwift
import RxCocoa
import MJRefresh


enum MCRefreshStatus {
    case none
    case beingHeaderRefresh
    case endHeaderRefresh
    case beingFooterRefresh
    case endFooterRefresh
    case noMoreData
}

protocol OutputRefreshProtocol {
    
    var refreshStatus : Variable<MCRefreshStatus> { get }
}
extension OutputRefreshProtocol {
    func autoSetRefreshHeaderStatus(header: MJRefreshHeader?, footer: MJRefreshFooter?) -> Disposable {
        return refreshStatus.asObservable().subscribe(onNext: { (status) in
            switch status {
            case .beingHeaderRefresh:
                header?.beginRefreshing()
            case .endHeaderRefresh:
                header?.endRefreshing()
            case .beingFooterRefresh:
                footer?.beginRefreshing()
            case .endFooterRefresh:
                footer?.endRefreshing()
            case .noMoreData:
                footer?.endRefreshingWithNoMoreData()
            default:
                break
            }
        })
    }
}
