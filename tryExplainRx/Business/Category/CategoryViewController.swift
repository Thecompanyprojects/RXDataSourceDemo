//
//  CategoryViewController.swift
//
//
//  Created by  on 2019/2/27.
//  Copyright © 2019年  rights reserved.
//

import UIKit
import RxDataSources
import MJRefresh
import RxSwift

fileprivate struct Metric {
    static let leftMenuWidth: CGFloat = 104
    static let leftMenuHeight: CGFloat = 56.0
}

class CategoryViewController: UIViewController {
    private let viewModel = CategoryViewModel()
    var isTabbar:Bool = true
    private var currentListData :[SubItems]?
    private var currentSelectIndexPath : IndexPath?
    private var currentIndex : NSInteger = 0
    private var lastIndex : NSInteger = 0
    private var vmOutput: CategoryViewModel.MCBoutiqueOutput?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tabBarController?.tabBar.isHidden = !isTabbar
        addOberRequestError()
        self.vmOutput = viewModel.transform(input: CategoryViewModel.MCBoutiqueInput())
        let height = isTabbar ? mScreenH - mTabbarH - mNavibarH : mScreenH  - mNavibarH
         self.leftMenuTableView.frame = CGRect(x: 0, y: 0, width: Metric.leftMenuWidth, height: height);
        self.rightListTableView.frame = CGRect(x: Metric.leftMenuWidth, y: 0, width:mScreenW - Metric.leftMenuWidth, height: height)
        initUI()
        //self.edgesForExtendedLayout = .bottom

        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = !isTabbar
    }

    override func didMove(toParent parent: UIViewController?) {
        
        super.didMove(toParent: parent)
        if parent == nil {
            ProgressHUD.dismissHUD()
        }
    }
    // MARK:- UI相关
    private func initUI() {
        initNavigationBar()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.color(mThemeWhiteColor), for: UIBarPosition.any, barMetrics: .default)
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = "Category"
        if !isNetworkConnect {
            addNoNetworkView()
        } else {
            self.view.addSubview(self.leftMenuTableView)
            self.view.addSubview(self.rightListTableView)
            boundTableViewData()
        }
    }
    
    private func boundTableViewData() {
        
        // left menu 数据源
        let leftDataSource = MyDataSource<CategoryLeftSection>( configureCell: { ds, tv, ip, item in
            let cell : CategoryLeftCell = tv.dequeueReusableCell(withIdentifier: "Cell1", for: ip) as! CategoryLeftCell
            cell.model = item
            return cell
        })
        
        leftDataSource.rxRealoded.emit(onNext: { [weak self] in
            guard let self = self else { return }
            let indexPath = IndexPath(row: 0, section: 0)
            self.leftMenuTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            self.leftMenuTableView.delegate?.tableView?(self.leftMenuTableView, didSelectRowAt: indexPath)
        }).disposed(by: rx.disposeBag)
        
        vmOutput!.sections.asDriver().drive(self.leftMenuTableView.rx.items(dataSource: leftDataSource)).disposed(by: rx.disposeBag)

        
        /// list 数据依赖 左侧点击
        let rightPieceListData = self.leftMenuTableView.rx.itemSelected.distinctUntilChanged().flatMapLatest {
        [weak self](indexPath) ->  Observable<[SubItems]> in
            guard let strongSelf = self else { return Observable.just([]) }
           
            strongSelf.currentIndex = indexPath.row
            if indexPath.row == strongSelf.viewModel.vmDatas.value.count - 1 {
                AppUtils.jumpToWebView(route: strongSelf.viewModel.vmDatas.value[indexPath.row].url)
                strongSelf.leftMenuTableView.selectRow(at: strongSelf.currentSelectIndexPath, animated: false, scrollPosition: .top)
                strongSelf.leftMenuTableView.delegate?.tableView!(strongSelf.leftMenuTableView, didSelectRowAt: strongSelf.currentSelectIndexPath!)
                return Observable.just((strongSelf.currentListData)!)
            }
            if let subItems = strongSelf.viewModel.vmDatas.value[indexPath.row].subnav {
                var fisrtSubItem = SubItems()
                fisrtSubItem.url = strongSelf.viewModel.vmDatas.value[indexPath.row].url
                fisrtSubItem.name = strongSelf.viewModel.vmDatas.value[indexPath.row].banner
                var reult:[SubItems] = subItems
                reult.insert(fisrtSubItem, at: 0)
                strongSelf.currentListData = reult
                strongSelf.currentSelectIndexPath = indexPath
                return Observable.just(reult)
            }
            return Observable.just([])
        }.share(replay: 1)
        
        
        let rightListDataSource =  RxTableViewSectionedReloadDataSource<CategoryRightSection>( configureCell: { [weak self]ds, tv, ip, item in
            guard let strongSelf = self else { return UITableViewCell() }
            if strongSelf.lastIndex != strongSelf.currentIndex {
                tv.scrollToRow(at: ip, at: .top, animated: false)
                strongSelf.lastIndex = strongSelf.currentIndex
            }
            if ip.row == 0 {
                let cell :CategoryListBannerCell = CategoryListBannerCell()
                cell.model = item
                return cell
            } else {
                let cell : CategoryListSectionCell = tv.dequeueReusableCell(withIdentifier: "Cell2", for: ip) as! CategoryListSectionCell
                cell.model = item
                return cell
            }
        })
        
        rightListTableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        rightPieceListData.map{ [CategoryRightSection(items:$0)] }.bind(to: self.rightListTableView.rx.items(dataSource: rightListDataSource))
            .disposed(by: rx.disposeBag)
        
        
        
        
        ProgressHUD.showLoadingIn(self.navigationController!.view)
        self.vmOutput!.requestCommand.onNext(true)
        
    }
    
    func addOberRequestError() {
        //// 网络请求状态的变化
        let obserVerNetWorkStatus = UserDefaults.standard.rx.observe(Bool.self, "categoryVCShowTry",options: [.new]).debounce(0.01, scheduler: MainScheduler.asyncInstance)
        obserVerNetWorkStatus.subscribe(onNext: {[weak self] (value) in
            guard let strongSelf = self else { return }
            if let show = value , show {
                if strongSelf.viewModel.vmDatas.value.count < 1 {
                    strongSelf.view.subviews.forEach{$0.removeFromSuperview()}
                    strongSelf.addRequestErrorView()
                    ProgressHUD.dismissHUD()
                    return
                }
            }
        }).disposed(by: rx.disposeBag)
    }
    
    private var leftMenuTableView:UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width:Metric.leftMenuWidth , height: mScreenH - mTabbarH - mNavibarH), style: .plain).then({
            $0.separatorStyle = .none
            $0.rowHeight = Metric.leftMenuHeight
            $0.tableFooterView = UIView()
            $0.tableHeaderView = UIView()
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = mRGBA(235, 235, 235, 1)
            $0.register(CategoryLeftCell.self, forCellReuseIdentifier: "Cell1")
        })
        return tableView
    }()
    
    private var rightListTableView:UITableView = {
        let height =  mScreenH - mTabbarH - mNavibarH
        let tableView = UITableView(frame: CGRect(x: Metric.leftMenuWidth, y: 0, width:mScreenW - Metric.leftMenuWidth  , height: height ), style: .plain).then({
            $0.separatorStyle = .none
            $0.tableFooterView = UIView()
            $0.tableHeaderView = UIView()
            $0.backgroundColor = mRGBA(248, 248, 248, 1)
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.register(CategoryListSectionCell.self, forCellReuseIdentifier: "Cell2")
            $0.register(CategoryListBannerCell.self, forCellReuseIdentifier: "CellTop")
        })
        return tableView
    }()
}


// MARK:- UITableViewDelegate
extension CategoryViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0 :
            return (mScreenW - 120)/240 * 100;
        default :
            let subItems:SubItems = self.currentListData![indexPath.row]
            if subItems.children.count > 0{
                let lines: NSInteger = (subItems.children.count - 1)/3 + 1
                let buttonHeight = (mScreenW - 136 - 108)/3
                let allButtonHeight = buttonHeight/44 * 63 * CGFloat(lines)
                let other =  (lines - 1)*42 + 56
                let height = allButtonHeight  + CGFloat(other) + 33
                return height
            }
           return 250
        }
    }
}
// MARK:- 初始化协议
extension CategoryViewController: NavUniversalable {
    // MARK:- 协议组件
    private func initNavigationBar() {
        //  search
        let models = isTabbar ? [NavigationBarItemMetric.search]:[NavigationBarItemMetric.search,NavigationBarItemMetric.back]
        self.universals(modelArr: models) { [weak self] (model) in
            guard let strongSelf = self else { return }
          
                strongSelf.navigationController?.popViewController(animated: false)
            
          
        }
    }
}
extension CategoryViewController:PlaceholderView {
    private func addNoNetworkView() {
        let noNetworkModel = PlaceholderViewItemMetric.noNetwork
        universal(model: noNetworkModel) {[weak self] (model) in
            guard let strongSelf = self else { return }
            if isNetworkConnect {
                strongSelf.view.subviews.forEach { $0.removeFromSuperview() }
                ProgressHUD.showLoading()
                strongSelf.view.addSubview(strongSelf.leftMenuTableView)
                strongSelf.view.addSubview(strongSelf.rightListTableView)
                strongSelf.boundTableViewData()
                strongSelf.vmOutput!.requestCommand.onNext(true)
            }
        }
    }
    
    private func addRequestErrorView() {
        let requestErrorModel = PlaceholderViewItemMetric.requestError
        universal(model: requestErrorModel) {[weak self] (model) in
            if isNetworkConnect {
                guard let strongSelf = self else { return }
                /// 重试失败 依旧显示
                UserDefaults.showTryView.set(value: false, forKey: .category)
                strongSelf.view.subviews.forEach { $0.removeFromSuperview() }
                ProgressHUD.showLoading()
                strongSelf.view.addSubview(strongSelf.leftMenuTableView)
                strongSelf.view.addSubview(strongSelf.rightListTableView)
                strongSelf.vmOutput!.requestCommand.onNext(true)
            }
        }
    }
    
}
