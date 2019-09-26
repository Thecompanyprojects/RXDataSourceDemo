//
//  CategoryModel.swift
//
//
//  Created by  on 2019/3/20.
//  Copyright © 2019年  rights reserved.
//
import SwiftyJSON
import MoyaMapper

struct RootItem: Modelable {
    mutating func mapping(_ json: JSON) {
    }
    
    /// 图片
    var img: String = ""
    /// 跳转地址
    var url: String = ""
    /// 品名
    var name: String = ""
}

struct SubItems: Modelable  {
    mutating func mapping(_ json: JSON) {
        
    }
    
    /// 跳转地址,有的换显示跳转箭头按钮
    var url: String = ""
    /// itemlist
    var children: [RootItem] = []
    /// 模块名称
    var name: String = ""
}

struct ParentItem: Modelable  {
    mutating func mapping(_ json: JSON) {
    
    }
    
    /// top image 点击跳转地址
    var url: String = ""
    /// top image url
    var banner: String = ""
    /// 名称
    var name: String = ""
    /// 模块id
    var cat_id: NSInteger = 0
    /// 子模块
    var subnav:[SubItems]? = []
}
