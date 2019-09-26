//
//  UIScrollView+Extensions.swift
//
//
//  Created by  on 2019/5/12.
//  Copyright © . All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum ScrollStatus {
    ///
    case visible
    ///
    case show
    ///
    case threshold
    ///
    case none
}

extension Reactive where Base: UIScrollView  {
    
    //视图滚到底部检测序列
    var reachedBottom: Signal<ScrollStatus> {
        return contentOffset.asDriver()
            .flatMap { [weak base] contentOffset -> Signal<ScrollStatus> in
                guard let scrollView = base else {
                    return Signal.just(.none)
                }
                /// 可视区域高度
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top
                    - scrollView.contentInset.bottom
                /// 滚动条最大位置
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                /// 如果当前位置超出最大位置则发出一个事件
                let y = contentOffset.y + scrollView.contentInset.top
                //return y >
                if y > visibleHeight {
                    /// 预加载需求，滑倒 2/3 位置就开时请求下一页数据
                    return 1.5 * y > threshold ? Signal.just(.threshold): Signal.just(.show)
                }
                
                return Signal.just(.visible)
        }
    }
}
