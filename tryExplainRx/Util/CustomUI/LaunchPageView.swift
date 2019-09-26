//
//  LaunchPageView.swift
//
//
//  Created by  on 2019/3/2.
//  Copyright © 2019年  rights reserved.
//

import UIKit

private let placeholderViewTag = 20180622

public class LaunchPageView: UIView {
    private var adFrame: CGRect = UIScreen.main.bounds  // 广告页显示大小
    private var duration: Int = 3                       // 广告页显示时间，default: 3秒
    private var isHiddenSkipBtn: Bool = false           // 是否隐藏跳过按钮(true 隐藏; false 不隐藏)，default: false
    private var delayAfterTimeOut: Double = 1.0         // 广告页展示完成后的停留时间，default: 1.0秒
    private var placeholderImage: UIImage?              // 在广告页未加载完之前显示的占位图
    
    private lazy var launchImageView: UIImageView = {   // APP启动图片（作用：让在加载广告页时，有个平滑的过度阶段）
        let view = UIImageView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.white
        return view
    }()
    private lazy var placeholderView: UIImageView = {   // 显示APP启动图片（作用：让在加载广告页时，有个平滑的过度阶段）
        let view = UIImageView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.white
        view.tag = placeholderViewTag
        return view
    }()
    private lazy var adImageView: UIImageView = {       // APP广告图片
        let adImageView = UIImageView(frame: UIScreen.main.bounds)
        adImageView.isUserInteractionEnabled = true
        adImageView.alpha = 0
        adImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClickAdView)))
        return adImageView
    }()
    private lazy var skipButton: UIButton = {           // 跳过按钮
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        btn.layer.cornerRadius = 13
        btn.layer.masksToBounds = true
        btn.setTitle("SKIP", for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.titleLabel?.textColor = UIColor.white
        btn.titleLabel?.sizeToFit()
        btn.isHidden = true
        btn.addTarget(self, action: #selector(skipBtnClicked), for: UIControl.Event.touchUpInside)
        return btn
    }()
    private var skipBtnTimer: DispatchSourceTimer?      // 跳过广告按钮定时器
    
    
    // MARK: - life cycle
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// App启动广告页
    ///
    /// - Parameters:
    ///   - duration: 广告页显示时间，default: 3秒
    ///   - placeholderImage: 在广告页未加载完之前显示的占位图，默认显示启动图
    ///   - completion: 用户点击广告事件的或公告展示完成的回调， isGotoDetailView 为ture表示点击了公告详情
    convenience public init(
        duration: Int = 3) {
        self.init(frame: UIScreen.main.bounds)
        self.adFrame = UIScreen.main.bounds
        self.duration = duration
        self.delayAfterTimeOut = 0
        self.isHiddenSkipBtn = false

    }
    
    
    func show(){
        setupSubviews()
        loadDataSource()
        startShowAdImageView()
        addLaunchAdViewToWindow()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup
    private func setupSubviews() {
        launchImageView.image = (placeholderImage != nil) ? placeholderImage : loadLaunchImage()
        placeholderView.image = loadLaunchImage()
        self.addSubview(launchImageView)
        
        adImageView.frame = self.adFrame
        self.addSubview(adImageView)
        
        skipButton.frame = CGRect(x: UIScreen.main.bounds.size.width - 78 , y: 18 , width: 60, height: 26.0)
        let adDuration = self.duration > 0 ? self.duration : 3
        skipButton.setTitle("SKIP" + " \(adDuration)", for: UIControl.State.normal)
        self.addSubview(skipButton)
        
        // "跳过广告"按钮定时器
        skipBtnTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        skipBtnTimer?.schedule(deadline: .now(), repeating: 1.0)
        self.duration = self.duration > 0 ? self.duration : 3
        skipBtnTimer?.setEventHandler(handler: { [weak self] in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                let title = "SKIP" + " \(strongSelf.duration )"
                let strTitle: NSMutableAttributedString = NSMutableAttributedString(string: title)
                strTitle.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 4, length: title.count - 4))
                strongSelf.skipButton.setAttributedTitle(strTitle, for: UIControl.State.normal)
                strongSelf.duration -= 1
                if strongSelf.duration < 0 {
                    strongSelf.skipBtnTimer?.cancel()
                }
            }
        })
    }
    
    // MARK: - load dataSource
    /// 加载资源并展示
    private func loadDataSource() {
        adImageView.image = loadLaunchImage()
    }
    /// 获取项目中的App启动页图片
    ///
    /// - Returns: 返回启动页图片
    private func loadLaunchImage() -> UIImage? {
        let viewSize    = UIScreen.main.bounds.size
        let orientation = UIApplication.shared.statusBarOrientation
        let viewOrientation = (orientation == .landscapeLeft || orientation == .landscapeRight) ? "Landscape" : "Portrait"
        var imageName: UIImage? = nil
        let imagesInfoArray = Bundle.main.infoDictionary!["UILaunchImages"]
        guard imagesInfoArray != nil else {
            return nil
        }
        for dict: Dictionary <String, String> in imagesInfoArray as! Array {
            let imageSize = NSCoder.cgSize(for: dict["UILaunchImageSize"]!)
            if imageSize.equalTo(viewSize) && viewOrientation == dict["UILaunchImageOrientation"]! as String {
                imageName = UIImage(named: dict["UILaunchImageName"]!)
            }
        }
        return imageName
    }
    
    
    
    /// 柔滑的展示广告页，并开始动画
    private func startShowAdImageView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            UIView.animate(withDuration: 0.5, animations: {
                self.adImageView.alpha = 1.0
            }) { (_) in
                self.skipButton.isHidden = self.isHiddenSkipBtn
                self.skipBtnTimer?.resume()
                self.endShowAdImageView()
            }
        }
    }
    
    /// 如果没有点击“跳过广告”按钮，会在展示完后，柔滑的退出
    private func endShowAdImageView() {
        let adDuration: Int = self.duration > 0 ? self.duration : 3
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(adDuration)) {
            self.removeLaunchAdViewFromSuperview(delay: self.delayAfterTimeOut)
          
        }
    }
    
    /// 从App中移除广告页
    ///
    /// - Parameter delay: 界面停留时间
    private func removeLaunchAdViewFromSuperview(delay: Double) {
        UIView.animate(withDuration: 0.5, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.alpha = 0.0
        }) { (_) in
            self.skipBtnTimer?.cancel()
            self.removeFromSuperview()
            NotificationCenter.default.removeObserver(self, name: UIApplication.didFinishLaunchingNotification, object: nil)
        }
    }
    
    /// 点击“跳过广告”按钮事件，立即退出广告页
    @objc private func skipBtnClicked() {
        removeLaunchAdViewFromSuperview(delay: 0.0)
        
    }
    
    /// 点击广告页事件
    @objc private func didClickAdView() {
        removeLaunchAdViewFromSuperview(delay: 0.0)
      
    }
    
    // MARK: - 当App启动完成后，添加到主window中显示
    /// 当接收到 UIApplicationDidFinishLaunching 通知后，添加到 keyWindow 上
    private func addLaunchAdViewToWindow() {
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: nil) { [weak self] (_) in
            guard let strongSelf = self else {
                DispatchQueue.main.async {
                    LaunchPageView.placeholderViewRemoveFromSuperview()
                }
                return
            }
            
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                rootVC.view.addSubview(strongSelf.placeholderView)
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.addSubview(strongSelf)
                LaunchPageView.placeholderViewRemoveFromSuperview()
            }
            
        }
    }
    
    private static func placeholderViewRemoveFromSuperview() {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController,
            let placeholderView = rootVC.view.viewWithTag(placeholderViewTag) {
            placeholderView.removeFromSuperview()
        }
    }
}
