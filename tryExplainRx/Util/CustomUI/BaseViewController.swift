//
//  BaseViewController.swift
//
//
//  Created by  on 2019/3/13.
//  Copyright © 2019年  rights reserved.
//

import UIKit

fileprivate struct Metric {
    static let backTopButtonWidth: CGFloat = 45
    static let backTopButtonMargin: CGFloat = 30
}

class BaseViewController: UIViewController {
    lazy var backTopButton: UIButton = {
        let button = UIButton(frame: CGRect(x: mScreenW - Metric.backTopButtonMargin - Metric.backTopButtonWidth, y: mScreenH - Metric.backTopButtonMargin - mTabbarH - Metric.backTopButtonWidth - mNavibarH, width: Metric.backTopButtonWidth, height: Metric.backTopButtonWidth)).then{
            $0.layer.cornerRadius = Metric.backTopButtonWidth / 2
            $0.clipsToBounds = true
            $0.setImage(mImage(name:"backToTop"), for: .normal)
            $0.rx.tap.do(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.backToTop()
            }).subscribe().disposed(by: self.rx.disposeBag)
        }
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.color(mThemeWhiteColor), for: UIBarPosition.any, barMetrics: .default)
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
}

extension BaseViewController:NavUniversalable{
    func initNavigationBackBar() {
        let models = [NavigationBarItemMetric.back]
        self.universals(modelArr: models) { [weak self](model) in
            guard let strongSelf = self else { return }
         strongSelf.backToLastViewController()
        }
    }
    @objc func backToLastViewController() {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: false)
    }
}

extension BaseViewController:PlaceholderView {
    /// 当前页面无网络和数据时
    func addCommonNoNetworkView() {
        let noNetworkModel = PlaceholderViewItemMetric.noNetwork
        universal(model: noNetworkModel) {[weak self] (model) in
            guard let strongSelf = self else { return }
            strongSelf.commonTry()
                //strongSelf.view.subviews.forEach { $0.removeFromSuperview() }
               //ProgressHUD.showLoading()
               //strongSelf.view.addSubview(strongSelf.leftMenuTableView)
               // strongSelf.view.addSubview(strongSelf.rightListTableView)
               // strongSelf.boundTableViewData()
               // strongSelf.vmOutput!.requestCommand.onNext(true)
        }
    }
    /// 请求失败且当前页面无数据时
    func addCommonRequestErrorView() {
        let requestErrorModel = PlaceholderViewItemMetric.requestError
        universal(model: requestErrorModel) {[weak self] (model) in
           guard let strongSelf = self else { return }
           strongSelf.commonTry()
                /// 重试失败 依旧显示
                //UserDefaults.showTryView.set(value: false, forKey: .category)
//                strongSelf.view.subviews.forEach { $0.removeFromSuperview() }
//                ProgressHUD.showLoading()
//                strongSelf.view.addSubview(strongSelf.leftMenuTableView)
//                strongSelf.view.addSubview(strongSelf.rightListTableView)
//                strongSelf.vmOutput!.requestCommand.onNext(true)
        }
    }
    
    /// 重试
    @objc func commonTry() {
        if !isNetworkConnect { return }
    }
    
    /// 回到顶部按钮
    @objc func backToTop() {
        
    }
    
}
