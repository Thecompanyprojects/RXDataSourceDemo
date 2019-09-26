//
//  AccountViewController.swift
//
//
//  Created by  on 2019/2/27.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture
import Result
import Moya

// MARK:- 常量
fileprivate struct Metric {
    static let headerHeight: CGFloat = 180.0 * mScreenW/360
    static let firstRowHeight: CGFloat = 106
    static let normalRowHeight: CGFloat = 56.0
}

class AccountViewController: UIViewController {
    private var accoutModel: AccountModel?
    private var jumpUrlList: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        initUI()
        initBaseData()
        addNotification()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK:- UI相关
    private func initUI() {
        initTableView()
    }
    
    private func initTableView() {
        self.view.addSubview(self.tableView)
        let items = [ AccoutCellModel(leftIcon: "account_icon_contact", title: "ContactUs"),
                      AccoutCellModel(leftIcon: "account_icon_contact", title: "ContactUs"),
//                      AccoutCellModel(leftIcon: "account_icon_chat", title: "LiveChat"),
                      AccoutCellModel(leftIcon: "account_icon_track", title: "TrackuOrder"),
                      AccoutCellModel(leftIcon: "account_icon_faq", title: "FAQ"),
                      AccoutCellModel(leftIcon: "account_icon_help", title: "Help")
        ]
        let sections = Observable.just([AccountVCSection(items: items)])
        let  dataSource = RxTableViewSectionedReloadDataSource<AccountVCSection>(
            //设置单元格
            configureCell: { ds, tv, ip, item in
                
                switch ip.row {
                    case 0  :
                      let cell1:AccountLandCell  = tv.dequeueReusableCell(withIdentifier: "Cell1", for: ip) as!AccountLandCell
                        return cell1
                    default :
                        let cell2:AccountServerCell = tv.dequeueReusableCell(withIdentifier: "Cell2", for: ip) as! AccountServerCell
                        cell2.model = item
                        return cell2
                }
                
        })
        //绑定单元格数据
        sections.bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)

        //设置代理
        ///
        self.tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    private var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: mScreenW, height: mScreenH - mTabbarH), style: .plain)
        tableView.bounces = false
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(AccountLandCell.self, forCellReuseIdentifier: "Cell1")
        tableView.register(AccountServerCell.self, forCellReuseIdentifier: "Cell2")
        return tableView
    }()
    // MARK:- 网络请求
    private func initBaseData() {
        accoutModel = AccountModel.mapModel(from: NetWorkManager.getCacheString(key: "accountData"))
        jumpUrlList = ([accoutModel?.orderUrl,accoutModel?.couponsUrl,accoutModel?.messageUrl,accoutModel?.addressUrl,
                        accoutModel?.contactUrl,accoutModel?.orderUrl,accoutModel?.faqUrl,"help"] as! [String])
        Observable.zip(
            Provider.rx.cacheRequest(.baseData),
            Provider.rx.cacheRequest(.account)
            ).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: {(basedata,account) in
                if basedata.statusCode == 200 || basedata.statusCode == 230 {
                    if  basedata.fetchJSONString(keys: ["code"]) == "0"{
                        NetWorkManager.cacheString(key: "settingData", string: basedata.fetchJSONString(keys:["data"]))
                    }
                }
                
                if account.statusCode == 200 || account.statusCode == 230 {
                    if account.fetchJSONString(keys: ["code"]) == "0"{
                     NetWorkManager.cacheString(key: "accountData", string: account.fetchJSONString(keys:["data"]))
                    }
                }
            }, onError: { error in
                
            }).disposed(by: rx.disposeBag)
    }
    
    
    // notification
    private func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateAccountVC), name: .LoginStatusChange, object: nil)
        
    }
    @objc func updateAccountVC() {
       self.tableView.reloadData()
    }
    
    deinit {
          NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK:- UITableViewDelegate
extension AccountViewController : UITableViewDelegate {
    //返回分区头部视图
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int)
        -> UIView? {
            let headerView = AccountHeaderView(frame: CGRect(x: 0, y: 0, width: mScreenW, height: Metric.headerHeight))
            headerView.settingButton.rx.tap.asObservable()
                .throttle(2, scheduler: MainScheduler.instance)
                .bind { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.navigationController?.pushViewController(MCSettingViewController(), animated: false)
            }.disposed(by: rx.disposeBag)
           return headerView
    }
    
    //返回分区头部高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int)
        -> CGFloat {
            return Metric.headerHeight;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0 :
            return Metric.firstRowHeight;
        default :
            return Metric.normalRowHeight;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            
        }
        if indexPath.row == 2 {
            if !AppUtils.checkLoginStatus() {
                AppUtils.gotoLogin()
                return
            }
        }
        if indexPath.row == 4 {
            /// 进入 help 页面
            self.navigationController?.pushViewController(HelpViewController(), animated: false)
            return
        }
        AppUtils.jumpToWebView(route: jumpUrlList![indexPath.row + 3])
    }
}


//MARK:- UITableViewDelegate

struct AccountVCSection {
    
    var items: [Item]
}

extension AccountVCSection : SectionModelType {
    typealias Item = AccoutCellModel
    
    init(original: AccountVCSection, items: [Item]) {
                self = original
                self.items = items
    }
}

