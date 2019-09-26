//
//  HelpViewController.swift
//
//
//  Created by  on 2019/3/18.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

class HelpViewController: BaseViewController {
    private var routers: [String]? = [""]

    override func viewDidLoad() {
        super.viewDidLoad()
        initBaseData()
        initUI()
        initNavigationBackBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI相关
    private func initUI() {
        self.navigationItem.title = "Help"
        //self.title =
        self.view.addSubview(self.tableView)
        boundTableViewDataSource()
    }
    
    // MARK: - tableView 数据绑定
    private func boundTableViewDataSource() {
        let items = [helpVCSection(header:"CompanyPolicy",
                                   items :["ReturnPolicy","PaymentMethods",
                                           "ShippingGuide","EsDeliTime",
                                           "TermsandConditions","PrivacyNotice",
                                           "UserSafetyPolicy",]),
                     helpVCSection(header:"CompanyInfo",
                                   items :["AboutUs"])]
        let sections = Observable.just( items)
        let  dataSource = RxTableViewSectionedReloadDataSource<helpVCSection>(
            //设置单元格
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "Cell")
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.font = mThemeNormalFont
                cell.textLabel?.text = item
                return cell
        },
            //设置分区头标题
            titleForHeaderInSection: { ds, index in
                return ds.sectionModels[index].header
        })
        //绑定单元格数据
        sections.bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        self.tableView.rx.itemSelected.map { indexPath in
            return (indexPath, dataSource[indexPath])
            }.subscribe(onNext: {[weak self] indexPath in
                guard let strongSelf = self else { return }
                let urlString = strongSelf.routers![ indexPath.0.row + indexPath.0.section*7]
                
                AppUtils.jumpToWebView(route:urlString )
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    // MARK: - 数据相关
    private func initBaseData(){
         let accoutModel = AccountModel.mapModel(from: NetWorkManager.getCacheString(key: "accountData"))
        routers = [accoutModel.HelpUrl.return_policy,accoutModel.HelpUrl.payment,accoutModel.HelpUrl.shipping,accoutModel.HelpUrl.estimate,accoutModel.HelpUrl.terms,accoutModel.HelpUrl.pricacy,accoutModel.HelpUrl.user_safety,accoutModel.contanctUrl]
        
    }
    
    override func backToLastViewController() {
        super.backToLastViewController()
        
    }
    // MARK: - tableView
    private var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: mScreenW, height: mScreenH - mStatusbarH), style: .plain).then({
            $0.showsHorizontalScrollIndicator = false
            $0.tableFooterView = UIView()
            $0.rowHeight = 48
        })
        return tableView
    }()
}


