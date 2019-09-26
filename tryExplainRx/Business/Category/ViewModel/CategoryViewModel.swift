//
//  CategoryViewModel.swift
//
//
//  Created by  on 2019/3/20.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import MJRefresh

class CategoryViewModel: NSObject {
      let vmDatas = Variable<[ParentItem]>([])
}
extension CategoryViewModel: ViewModelType {
    
    typealias Input = MCBoutiqueInput
    typealias Output = MCBoutiqueOutput
    
    struct MCBoutiqueInput {
        
    }
    
    struct MCBoutiqueOutput: OutputRefreshProtocol {
        ///   告诉外界的tableView当前的刷新状态
        var refreshStatus = Variable<MCRefreshStatus>(.none)
        // tableView的sections数据
        let sections: Driver<[CategoryLeftSection]>
        // 外界通过该属性告诉viewModel加载数据（传入的值是为了标志是否重新加载）
        let requestCommand = PublishSubject<Bool>()
        init(sections: Driver<[CategoryLeftSection]>) {
            self.sections = sections
        }
    }
    
    func transform(input: CategoryViewModel.MCBoutiqueInput) -> CategoryViewModel.MCBoutiqueOutput {
        
        let temp_sections = vmDatas.asObservable().map({ (sections) -> [CategoryLeftSection] in
            return [CategoryLeftSection(items: sections)]
        }).asDriver(onErrorJustReturn: [])
        
        let output = MCBoutiqueOutput(sections: temp_sections)
        output.requestCommand.subscribe(onNext:{[weak self] _ in
                guard let strongSelf = self else { return }
            Provider.rx.cacheRequest(.baseUIData).subscribe( onNext:{ result in
                ProgressHUD.dismissHUD()
                if result.statusCode == 200 || result.statusCode == 230 {
                    UserDefaults.showTryView.set(value: false, forKey: .category)
                    if result.fetchJSONString(keys:["code"]) == "0" {
                        strongSelf.vmDatas.value =   ParentItem.mapModels(from:
                            result.fetchJSONString(keys:["data","data"]))
                    } else {
                        UserDefaults.showTryView.set(value: true, forKey: .category)
                        ProgressHUD.showError(result.fetchJSONString(keys:["msg"]))
                    }
                } else {
                    UserDefaults.showTryView.set(value: true, forKey: .category)
                    ProgressHUD.showError("RequestError")
                }
                
            }).disposed(by: strongSelf.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        return output
    }
    
}

struct CategoryLeftSection {
    var items: [Item]
}

extension CategoryLeftSection: SectionModelType {
    typealias Item = ParentItem
    init(original: CategoryLeftSection, items: [Item]) {
        self = original
        self.items = items
    }
}

struct CategoryRightSection {
    var items: [Item]
}

extension CategoryRightSection: SectionModelType {
    typealias Item = SubItems
    init(original: CategoryRightSection, items: [Item]) {
        self = original
        self.items = items
    }
}
