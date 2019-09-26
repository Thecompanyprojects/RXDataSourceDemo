//
//  MyDataSource.swift
//  tryExplainRx
//
//  Created by Jz D on 2019/6/28.
//  Copyright © 2019 Jz D. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import RxDataSources

final class MyDataSource<S: SectionModelType>: RxTableViewSectionedReloadDataSource<S> {
    private let relay = PublishRelay<Void>()
    var rxRealoded: Signal<Void> {
        return relay.asSignal()
    }
    
    override func tableView(_ tableView: UITableView, observedEvent: Event<[S]>) {
        super.tableView(tableView, observedEvent: observedEvent)
        //Do diff
        //Notify update
        
        relay.accept(())
    }
    
}
