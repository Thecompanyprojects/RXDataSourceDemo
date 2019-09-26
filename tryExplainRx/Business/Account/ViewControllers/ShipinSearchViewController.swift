//
//  ShipinSearchViewController.swift
//
//
//  Created by  on 2019/3/14.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

class ShipinSearchViewController: UIViewController,UISearchResultsUpdating{
    private var baseData:[Country]?
    private weak var searchBar: UISearchBar?
    private var searchResult:[Country]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        initBaseData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK:- UI
    private func initUI() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.definesPresentationContext = true
        self.view.addSubview(self.tableView)
        boundTableviewData()
    }
    // MARK: - 数据相关
    private func initBaseData(){
        self.searchResult = []
        let set = AppUtils.getSettingBaseData()
        self.baseData = set.countries.allCountries.count < 1 ? []:set.countries.allCountries
    }
    
    private var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 5, width: mScreenW, height: mScreenH), style: .plain).then({
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.tableFooterView = UIView(frame:CGRect(x: 0, y: 0, width: mScreenW, height: CGFloat.leastNormalMagnitude ))
            $0.rowHeight = 48
            $0.contentInset = UIEdgeInsets(top: 44,left: 0,bottom: 0,right: 0)
            $0.register(SettingSelectorCell.self, forCellReuseIdentifier: "Cell")
        })
        return tableView
    }()
    
    private var alertLabel:UILabel = {
        let label = UILabel().then({
            $0.text = "SearchNoResult"
            //$0.frame = CGRect(x: 16, y: mStatusbarH + 30, width: mScreenW - 32, height: 50)
            $0.font = UIFont.systemFont(ofSize: 16.0)
            $0.textColor = mThemeLabelNormalColor
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        })
        return label
    }()
    
    // MARK: - tableview 数据绑定
    private func boundTableviewData() {
        //let sections = Observable.just( self.searchResult!)
        let  dataSource = RxTableViewSectionedReloadDataSource<shipinVCSection>(
            //设置单元格
            configureCell: {[weak self]ds, tv, ip, item in
                guard let strongSelf = self else { return UITableViewCell() }
                let cell : SettingSelectorCell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip) as!SettingSelectorCell
                cell.selectionStyle = .none
                cell.textLabel?.font = mThemeNormalFont
                cell.textLabel?.attributedText = item.name
                    .matchAll((strongSelf.searchBar?.text?.lowercased())! ).color(mThemePinkColor)
                    .matchAll( (strongSelf.searchBar?.text?.uppercased())!).color(mThemePinkColor)
                    .matchAll(strongSelf.searchBar!.text!).color(mThemePinkColor)
                    .attributedText
                cell.isSelected = false
                return cell
        })
        let searchResult = searchBar!.rx.text.orEmpty.debounce(0.5, scheduler: MainScheduler.instance).distinctUntilChanged().filter{ !$0.isEmpty }.flatMapLatest{
                [weak self] query -> Observable<[Country]> in
            guard let strongSelf = self else { return Observable.just([]) }
            let result = strongSelf.baseData!.filter{ country in country.name.lowercased().contains(query.lowercased())}
            if result.count > 0 {
                strongSelf.alertLabel.removeFromSuperview()
            } else {
                strongSelf.view.addSubview(strongSelf.alertLabel)
                strongSelf.alertLabel.snp.makeConstraints({ (make) in
                    make.left.equalTo(strongSelf.view).offset(16)
                    make.right.equalTo(strongSelf.view).offset(-16)
                    make.top.equalTo((strongSelf.searchBar?.snp.bottom)!).offset(10)
                })
            }
            
            strongSelf.searchResult?.removeAll()
            strongSelf.searchResult = result
            return Observable.just(result)
            }.share(replay: 1)
        //绑定单元格数据
        searchResult.map{ [shipinVCSection(items:$0)] }.bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let strongSelf = self else { return }
            let country = strongSelf.searchResult![indexPath.row]
            if country.name == AppUtils.getUserCountryName() { return  }
            
            AppUtils.setUserCountryCode(country: "\(country.id)")
            AppUtils.setUserCountryName(country: country.name)
            strongSelf.changeSysConfig()
        }).disposed(by: rx.disposeBag)
//        self.tableView.rx.setDelegate(self)
//            .disposed(by: rx.disposeBag)
    }
    
    private func changeSysConfig() {
         
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchBar == nil {
            searchBar = searchController.searchBar
            searchBar!.backgroundColor = mThemeWhiteColor
            initUI()
        }
    }
    
}

//// MARK:- UITableViewDelegate
//extension ShipinSearchViewController : UITableViewDelegate {
//
//    //返回分区头部高度
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int)
//        -> CGFloat {
//            return section > 0 ? 64 : 20
//    }
//}
