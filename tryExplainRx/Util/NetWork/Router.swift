//
//  Router.swift
//  HttpRequestDemo
//
//  Created by  on 2019/3/11.
//  Copyright © 2019年  rights reserved.
//

import Foundation
import Moya

enum Router {
   
    case register(parameters:[String:Any])
    ///  language currency ship to基础数据
    case baseData
    /// categroy item 基础数据
    case baseUIData
    /// 功能跳转web 基础数据
    case webPageJumpData
    /// accout 初始化数据
    case account
    /// userinfo
    case userInfo
    /// bagList
    case bagList
    /// delCartItem
    case deleteCartItem(parameters:[String:String])
    /// addFavorites
    case addFavorites(parameters:[String:String])
    /// updateCartItem
    case updateCartItem(parameters:[String:Any])
    /// functionUrl
    case functionUrl
    /// getDefaultSearch
    case getDefaultSearch
    /// getHotSearch
    case getHotSearch
    ///  changePassword
    case changePassword(parameters:[String:String])
    /// getVersion
    case getVersion
    /// homedata
    case homeData
    /// bestsell
    case bestSell(page:Int)
    /// alertBanner
    case alertBanner
    case other
}


extension Router:TargetType {
    /// host 配置
    var baseURL: URL {
        switch self {
        case .other:
            return URL(string: "-------")!
        default:
            return URL(string:AppConfig.HOME + AppUtils.getDefaultLangSuffix())!
        }
    }
    
    /// path 配置
    var path: String {
        switch self {
       
        case .getVersion:
            return "api/v1/c1/common/getVersion"
        case .bagList:
            return "api/v1/c0/cart/getList?currency=\(AppUtils.getUserCurrency())&ucid=\(AppUtils.getUserCountryCode())"
        case .account:
            return "api/v1/c1/account/index/"
        case .baseData:
            return "api/v1/c1/common/siderBar/1/"
        case .baseUIData:
            return "api/v1/c0/common/siderBar/2/"
        case .webPageJumpData:
            return "api/v1/c1/common/functionUrl"
        case .userInfo:
            return "api/v1/c0/user/getUserInfo"
        case .functionUrl:
            return "api/v1/c1/common/functionUrl"
        case .getDefaultSearch:
            return "api/v1/c0/common/getDefaultSearch"
        case .getHotSearch:
            return "api/v1/c1/common/getHotSearch"
        case .homeData:
            return "api/v1/c1/index/index?currency=\(AppUtils.getUserCurrency())"
        case .bestSell:
            return "/api/v1/c0/index/bestSell"
        default:
            return ""
        }
    }
    
    // 请求方式配置
    var method: Moya.Method {
        switch self {
        case .deleteCartItem,
             .addFavorites,.updateCartItem,
             .changePassword,.register,.bestSell:
            return .post
        default:
            return .get
        }
    }
    
    // 模拟数据 必须实现 单元测试使用
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case let .deleteCartItem(parameters),
             let .addFavorites(parameters),let .changePassword(parameters):
            return .requestParameters(parameters: parameters, encoding:URLEncoding.default)
        case let .bestSell(page):
            return .requestParameters(parameters: ["page": page], encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    /// 请求头配置
    var headers: [String : String]? {
        let userAgent = UserDefaults.Config.string(forKey: .UserAgent)
        return ["Content-Type":"application/x-www-form-urlencoded","User-Agent":userAgent!]
    }
}
