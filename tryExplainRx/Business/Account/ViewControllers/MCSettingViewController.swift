//
//  MCSettingViewController.swift
//
//
//  Created by  on 2019/3/8.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

class MCSettingViewController: BaseViewController {

    var cacheSize:String = "Loading"
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        getCacheSize()
        self.navigationController?.navigationBar.isHidden = false
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationController?.navigationBar.isHidden = false
    }
    // MARK:- UI
    private func initUI() {
        self.title = "Settings"
        initNavigationBackBar()
        initTableView()
        signoutUI()
        initVersionUI()
    }
    
    private func initTableView() {
        self.view.addSubview(self.tableView)
        let showLogout = true
    
        let items = AppUtils.checkLoginStatus() && showLogout  ?  ["Language","Currency","Shipto","ChangePassword","ClearCache"] : ["Language","Currency","Shipto","ClearCache"]
        let sections = Observable.just([settingVCSection(items: items)])
        
        let  dataSource = RxTableViewSectionedReloadDataSource<settingVCSection>(
            //设置单元格
            configureCell: { [weak self ] ds, tv, ip, item in
                guard let strongSelf = self else { return UITableViewCell() }
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "Cell")
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.font = mThemeNormalFont
                cell.textLabel?.text = item
                cell.detailTextLabel?.textColor = mThemeLabelNormalColor
                cell.detailTextLabel?.font = mThemeNormalFont
                if ip.row == items.count - 1{
                    if strongSelf.cacheSize == "Loading" {
                        cell.detailTextLabel?.text = "Loading"
                    } else {
                        cell.detailTextLabel?.text = strongSelf.cacheSize
                    }
                }
                if item == "Shipto" {
                    cell.detailTextLabel?.text = strongSelf.getDefaultCoutryName()
                }
                return cell
                
        })
        //绑定单元格数据
        sections.bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        self.tableView.rx.itemSelected.map { indexPath in
            return (indexPath, dataSource[indexPath])
            }.subscribe(onNext: {[weak self] indexPath in
                guard let strongSelf = self else { return }
                strongSelf.cellClick(row: indexPath.0.row,maxRow: items.count)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func signoutUI() {
        if !AppUtils.checkLoginStatus() {
            return
        }
        let signoutButton = UIButton().then {
            $0.backgroundColor = mThemeLabelNormalColor
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
            let title =  "Signout"
            $0.setTitle(title, for: .normal)
            $0.rx.tap.throttle(2, scheduler: MainScheduler.instance)
                .bind(onNext:{ [weak self] in
                guard let strongSelf = self else { return }
                /// 退出登录
                
                strongSelf.logout()
            }).disposed(by: rx.disposeBag)
        }
        self.tableView.addSubview(signoutButton)
        signoutButton.snp.makeConstraints {(make) in
            make.left.equalTo(self.view).offset(48)
            make.right.equalTo(self.view).offset(-48)
            make.height.equalTo(40)
            make.top.equalTo(self.tableView).offset(312)
        }
    }
    
    private func initVersionUI() {
        let versionLabel = UILabel().then {
            $0.text = "V" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as!String)
            $0.textAlignment = .center
            $0.textColor = mThemeGrayColor
            $0.font = mFont(14)
            $0.bringSubviewToFront(tableView)
        }
        
        self.view.addSubview(versionLabel)
        
        versionLabel.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.width.equalTo(200)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-16 - mSafeBottomH)
        }
        
        
    }

    private func getCacheSize() {
        DispatchQueue.global().async {
            let cache:Float = DataCleanManager.fileSizeOfCache()
            self.cacheSize = "\(cache) M"
            DispatchQueue.main.async { self.tableView.reloadData()}
        }
       

    }
    
    private var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: mScreenW, height: mScreenH - mTabbarH), style: .plain).then({
            $0.showsHorizontalScrollIndicator = false
            $0.tableFooterView = UIView()
            $0.rowHeight = 56
        })
        return tableView
    }()
   
    // MARK:- 点击事件
    private func cellClick(row:NSInteger,maxRow:NSInteger) {
        
        if row < 3 {
            
        }
        switch row {
        case 0:
            let viewController = SelectorViewController()
            viewController.selectorType = .language
            self.navigationController?.pushViewController(viewController, animated: false)
            break
        case 1:
            let viewController = SelectorViewController()
            viewController.selectorType = .currency
            self.navigationController?.pushViewController(viewController, animated: false)
            break
        case 2:
            let viewController = SelectorViewController()
            viewController.selectorType = .shipto
            self.navigationController?.pushViewController(viewController, animated: false)
            break
        default:
            if maxRow - row > 1 {
                
                 
                self.navigationController?.pushViewController(ChangePasswordViewController(), animated: false)
                
            } else {
                
                
                self.clearCache()
            }
            break
        }
    }
    // 退出登录
    private func logout() {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        ProgressHUD.showLoadingIn(self.navigationController!.view)
 
        
    }
    
    // 清理缓存
    private func clearCache() {
        VVAlert.confirmOrCancel(title: "ClearCache", message: "RuclearAll", confirmTitle: "Confirm", cancelTitle: "Cancel", inViewController: self, withConfirmAction: {
            ProgressHUD.showLoadingIn((self.navigationController?.view)!)
            do {
                try DataCleanManager.clearCache()
                self.cacheSize = "0.00 M"
            } catch {
                
            }
            ProgressHUD.dismissHUD()
            ProgressHUD.showSuccess("Cachecleared")
            self.tableView.reloadData()
        }, cancelAction: {})
        
    }
    override func backToLastViewController() {
        
        super.backToLastViewController()
    }
    
    
    private func getDefaultCoutryName()-> String {
        let settingData = AppUtils.getSettingBaseData()
        let result =  settingData.countries.allCountries.filter{ country in country.id ==  Int(AppUtils.getUserCountryCode())
        }
        if result.count > 0 {
            return  (result.last?.name)!
        } else {
            return AppUtils.getUserCountryName()
        }
    }
}




