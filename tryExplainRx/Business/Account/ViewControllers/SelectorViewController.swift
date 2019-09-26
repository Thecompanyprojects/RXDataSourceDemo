//
//  SelectorViewController.swift
//
//
//  Created by  on 2019/3/13.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxDataSources
import RxSwift


enum SelectorType {
    case language
    case currency
    case shipto
}

class SelectorViewController: BaseViewController {
    private var setData :SettingModel?
    private var currentSelected :SettingSelectorCell?
    private var searchVC : UISearchController?
    var selectorType:SelectorType?
    override func viewDidLoad() {
        super.viewDidLoad()
        initBaseData()
        initUI()
    }
    
    // MARK: - UI相关
    private func initUI() {
        initNavigationBackBar()
        self.title = self.selectorType == .language ? "Language":self.selectorType == .currency ? "Currency" : "Shipto"
        self.view.addSubview(self.tableView)
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.isHidden = false
        initSearchBar()
        boundTableviewData()
    }

  
    private func initSearchBar() {
        if self.selectorType != .shipto {
            return
        }
        let a = ShipinSearchViewController()
        let controller = UISearchController(searchResultsController: a).then {
            $0.searchBar.frame = CGRect(x: 0, y: 0, width: 0, height: 44);
            $0.hidesNavigationBarDuringPresentation = true
            $0.dimsBackgroundDuringPresentation = true
            $0.searchBar.searchBarStyle = .minimal
            $0.searchResultsUpdater = a
            $0.searchBar.sizeToFit()
            $0.searchBar.backgroundColor = mThemeWhiteColor
            $0.searchBar.placeholder = "Search"
            $0.searchBar.setValue("Cancel", forKey:"_cancelButtonText")
        }
        controller.searchBar.rx.textDidBeginEditing.subscribe(onNext:{[weak self] _ in
            guard let strongSelf = self else { return }
            if #available(iOS 11.0, *) {
                strongSelf.tableView.contentInset = UIEdgeInsets.init(top: -mNavibarH + 8, left: 0, bottom: 0, right: 0)
            }
            
            strongSelf.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            
        }).disposed(by: rx.disposeBag)
        
        controller.searchBar.rx.textDidEndEditing.subscribe(onNext:{[weak self] _ in
            guard let strongSelf = self else { return }
            controller.isActive = controller.searchBar.text!.count > 0
            if #available(iOS 11.0, *) {
                strongSelf.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
                strongSelf.tableView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
            }
            strongSelf.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }).disposed(by: rx.disposeBag)
        
        controller.searchBar.rx.searchButtonClicked.subscribe(onNext:{[weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }).disposed(by: rx.disposeBag)
        self.definesPresentationContext = true
        self.searchVC = controller
        self.tableView.tableHeaderView = controller.searchBar
    }
    
    // MARK: - tableview 数据绑定
    private func boundTableviewData() {
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        switch self.selectorType {
        case .language?:
            let items = mFilterNullOfArray(self.setData?.languages.showLanguages as Any) as! [Language]
            let sections = Observable.just([selectorLanguageVCSection(items: items)])
            let dataSource = RxTableViewSectionedReloadDataSource<selectorLanguageVCSection>(
                //设置单元格
                configureCell: {[weak self] ds, tv, ip, item in
                    guard let strongSelf = self else { return UITableViewCell() }
                    let cell : SettingSelectorCell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip) as!SettingSelectorCell
                    let  defaltLanguage = AppUtils.getUserLanguage()
                    cell.selectionStyle = .none
                    cell.textLabel?.font = mThemeNormalFont
                    cell.textLabel?.text = item.name
                    cell.isSelected = false
                    cell.selectedIcon?.isHidden = true
                    if item.code == defaltLanguage {
                        cell.isSelected = true
                        cell.selectedIcon?.isHidden = false
                        strongSelf.currentSelected = cell
                    }
                    return cell
                    
            })
            //绑定单元格数据
            sections.bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
            //
            tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                let language = items[indexPath.row]
                if language.code == AppUtils.getUserLanguage() { return }
                let cell = strongSelf.tableView.cellForRow(at: indexPath) as? SettingSelectorCell
                strongSelf.currentSelected?.selectedIcon?.isHidden = true
                strongSelf.currentSelected?.isSelected = false
                cell?.isSelected = true
                cell?.selectedIcon?.isHidden = false
                strongSelf.currentSelected = cell
                AppUtils.setUserLanguage(lang: language.code)
                strongSelf.changeSysConfig()
            }).disposed(by: rx.disposeBag)
            break;
        case .currency? :
            let items = mFilterNullOfArray(self.setData?.currencies.currencies as Any) as! [Currency]
            let sections = Observable.just([selectorCurrencyVCSection(items: items)])
            let  dataSource = RxTableViewSectionedReloadDataSource<selectorCurrencyVCSection>(
                //设置单元格
                configureCell: {[weak self] ds, tv, ip, item in
                    guard let strongSelf = self else { return UITableViewCell() }
                    let cell : SettingSelectorCell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip) as!SettingSelectorCell
                    cell.selectionStyle = .none
                    cell.textLabel?.font = mThemeNormalFont
                    cell.textLabel?.text = item.name
                    cell.isSelected = false
                    cell.selectedIcon?.isHidden = true
                    let  defaltCurrency = AppUtils.getUserCurrency()
                    if item.name == defaltCurrency {
                        cell.isSelected = true
                        cell.selectedIcon?.isHidden = false
                        strongSelf.currentSelected = cell
                    }
                    return cell
                    
            })
            //绑定单元格数据
            sections.bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
            //
            tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                let currency = items[indexPath.row]
                if currency.name == AppUtils.getUserLanguage() {
                    return
                }
                let cell = strongSelf.tableView.cellForRow(at: indexPath) as? SettingSelectorCell
                strongSelf.currentSelected?.selectedIcon?.isHidden = true
                strongSelf.currentSelected?.isSelected = false
                cell?.isSelected = true
                cell?.selectedIcon?.isHidden = false
                strongSelf.currentSelected = cell
                AppUtils.setUserCurrency(currency: currency.name)
                strongSelf.changeSysConfig()
            }).disposed(by: rx.disposeBag)
            break
        default:
            
            /// 整理获取国家数据
            let allItems = mFilterNullOfArray(self.setData?.countries.allCountries as Any) as! [Country]
            var prioritems = mFilterNullOfArray(self.setData?.countries.priorCountries as Any) as! [Country]
            prioritems += allItems
            /// 用户国家数据
            let userCoutryCode = AppUtils.getUserCountryCode()
            var userContry:[Country] = (prioritems.filter{ country in country.id == Int(userCoutryCode) })
            if userContry.count > 1 {
                userContry.removeLast()
            }
            /// 切换国家站后,current显示为 selectCountry
            if userContry.count < 1 {
                var country = Country()
                country.name = (self.setData?.countries.selectCountry)!
                userContry.append(country)
            }
            
            let  items = [selectorCountryVCSection(header: "Current", items: userContry.count > 0 ? userContry : []),selectorCountryVCSection(header: "Popular", items: prioritems)]
            
            let sections = Observable.just( items)
            let  dataSource = RxTableViewSectionedReloadDataSource<selectorCountryVCSection>(
                //设置单元格
                configureCell: { ds, tv, ip, item in
                    let cell : SettingSelectorCell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip) as!SettingSelectorCell
                    cell.selectionStyle = .none
                    cell.textLabel?.font = mThemeNormalFont
                    cell.textLabel?.text = item.name
                    cell.isSelected = false
                    cell.selectedIcon?.isHidden = true
                    if (ip.row == 0 && ip.section == 0){
                         cell.selectedIcon?.isHidden = false
                    }
                    return cell
                },
                //设置分区头标题
                titleForHeaderInSection: { ds, index in
                    return ds.sectionModels[index].header
                }
            )
            //绑定单元格数据
            sections.bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
           
            //
            tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                if(indexPath.row == 0 && indexPath.section == 0) {
                    return;
                }
                let country = items[indexPath.section].items[indexPath.row]
                 
                if country.name == AppUtils.getUserCountryName() {
                    return;
                }
                if ( country.jump.lang.count > 0 ) { AppUtils.setUserLanguage(lang: country.jump.lang ) }
                
                AppUtils.setUserCountryCode(country: "\(country.id)")
                AppUtils.setUserCountryName(country: country.name)
                strongSelf.changeSysConfig()
            }).disposed(by: rx.disposeBag)
            break;
        }
    }
    // MARK: - 数据相关
    private func initBaseData(){
        self.setData = AppUtils.getSettingBaseData()
    }
    private func changeSysConfig() {
        ///
        
       
    }
    
    private var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: mNavibarH, width: mScreenW, height: mScreenH - mNavibarH ), style: .grouped).then({
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.rowHeight = 48
            $0.register(SettingSelectorCell.self, forCellReuseIdentifier: "Cell")
        })
        return tableView
    }()

}


// MARK:- UITableViewDelegate
extension SelectorViewController : UITableViewDelegate {
    
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  self.selectorType != .shipto ? CGFloat.leastNormalMagnitude : 24
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView().then {
            $0.frame = self.selectorType == .shipto  ? CGRect(x: 0, y: 0, width: mScreenW, height: 24) : CGRect.zero
            //$0.backgroundColor =  mRGBA(235, 235, 235, 1)
        }
        if selectorType == .shipto {
            let titleArray = ["Current","Popular"]
            let label =  UILabel().then {
                $0.font = mThemeNormalFont
                $0.text = titleArray[section]
                }
            view .addSubview(label)
            label.snp.makeConstraints { (make) in
                make.left.equalTo(view).offset(16)
                make.centerY .equalTo(view)
                make.width.equalTo(100)
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame:CGRect(x: 0, y: 0, width: mScreenW, height:CGFloat.leastNormalMagnitude))
    }
    
    
}
