//
//  NetWorkManager.swift
//  HttpRequestDemo
//
//  Created by  on 2019/3/11.
//  Copyright © 2019年  rights reserved.
//

import Foundation
// third
import Moya
import Alamofire
import MoyaMapper
import SwiftyJSON
import RxSwift

/// 超时时长
private var requestTimeOut:Double = 15
///成功数据的回调
typealias successCallback = ((Dictionary<String, Any>) -> (Void))
///失败的回调
typealias failureCallback = ((String,String) -> (Void))

/// 请求回调状态码
public enum VVCODE: Int {
    case SUCCESS = 0
    case PARAM = 1
    case UNKNOWN = 2
    case SERVER = 3
    case EMAIL_EXIEST = 4//邮箱已存在
    case PROVIDE_EMAIL = 5//fb的注册，需要绑定邮箱的错误提示
    case ERROR_EMAIL_FORMAT = 6//邮件格式错误
    case LOGIN_FAIL = 7//登录失败
    case REGISTER_FAIL = 8//注册失败
    case CHANGE_PASSWORD_FAIL = 9//密码修改失败
    case CUSTOM_ERROR = 999 //自定义错误
}

class NetWorkManager:NSObject {
    /// 清除所有缓存
    class func cleanNetWorkCache() {
        MMCache.shared.removeAllJSONCache()
        MMCache.shared.removeAllResponseCache()
    }
    /// 清除指定url缓存
    class func clearNetWorkCache(url : String) {
        MMCache.shared.removeJSONCache(url)
        MMCache.shared.removeResponseCache(url)
    }
    
    class func cacheString(key:String,string:String) {
        MMCache.shared.cacheString(string, key: key, cacheContainer: .hybrid)
    }
    
    class func getCacheString(key:String) -> String {
        if let result  = MMCache.shared.fetchStringCache(key: key, cacheContainer: .hybrid){
            return result
        }
        return ""
    }
    
    // MARK: -取消所有请求
    class func CancelAllRequest() {
        Provider.manager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
    
    class func initProvide() {
        Provider.manager.delegate.taskWillPerformHTTPRedirectionWithCompletion = {session, task, response, request, completion in
             Once.once("hostUrlSet") {
                /// 保存重定向后的 host url
                AppConfig.HOME = request.url?.host ?? AppConfig.HOST
                
                /// 成功拿到国家站信息再去,获取基础信息
                NotificationCenter.default.post(name: .CountryUrlMessageChange, object: nil, userInfo:nil)
            }
        }
        
    }
    
   
}


/// 配置网络请求
private let VVEndpointClosure = {(target:Router) -> Endpoint in
    let url = target.baseURL.absoluteString + target.path 
    var task = target.task
    /*
     在每个请求里都增加相同的参数
     */

    
    var endpoint = Endpoint(
        url: url,
        sampleResponseClosure: { .networkResponse(200, target.sampleData) },
        method: target.method,
        task: task,
        httpHeaderFields: target.headers
    )
    

         requestTimeOut = 35
        return endpoint

}


///网络请求的设置
private let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        //设置请求时长
        request.timeoutInterval = requestTimeOut
        // 打印请求参数
        if let requestData = request.httpBody {
            
        }else{
            
        }
        done(.success(request))
    } catch {
        done(.failure(MoyaError.underlying(error, nil)))
    }
}



struct NetParameter : ModelableParameterType {
    var successValue = "0"
    var statusCodeKey = "code"
    var tipStrKey = "msg"
    var modelKey = "data"
}

////网络请求发送的核心初始化方法，创建网络请求对象
let Provider = MoyaProvider<Router>(endpointClosure: VVEndpointClosure, requestClosure: requestClosure, plugins: [MoyaMapperPlugin(NetParameter())], trackInflights: false)


///  基础网络请求封装(与界面交互式使用)
///
/// - Parameters:
///   - target: 网络请求
///   - success: 成功
///   - failure: 失败
func NetWorkRequest(_ target: Router, success: @escaping successCallback , failure:@escaping failureCallback) {
     /// 先判断网络是否有链接 没有的话直接返回
    if !isNetworkConnect{
        failure("Networkerror","-500")
        return
    }
    request(3, target:target, success: success, failure: failure)
}

//// 暂未理解 retrywhen 写法,先这样写
private func request(_ time:Int,target: Router, success: @escaping successCallback , failure:@escaping failureCallback) {
    
    Provider.request(target) { (result) in
        //隐藏hud
        switch result {
        case let .success(response):
            do {
                let jsonData = try JSONSerialization.jsonObject(with: response.data, options: .mutableContainers) as AnyObject
                
                let dic = jsonData as! Dictionary<String, Any>
                let code = dic["code"] as! NSInteger
                if !dic.isEmpty  {
                    if code == VVCODE.SUCCESS.rawValue {
                        success(dic)
                    } else {
                        if time > 1 {
                            request(time - 1, target: target, success: success, failure: failure)
                        } else {
                            code > 100 && code != 999 ? failure("RequestError","\(dic["code"]!)") :failure(dic["msg"] as! String,"\(dic["code"]!)")
                        }
                    }
                }
            } catch {
                if time > 1 {
                    request(time - 1, target: target, success: success, failure: failure)
                } else {
                    failure("RequestError","\((error as NSError).code)")
                }
            }
            break
        case let .failure(error):
            if time > 1 {
                request(time - 1, target: target, success: success, failure: failure)
            } else {
                failure("RequestError","\((error as NSError).code)")
                break
            }
        }
    }
}



var isNetworkConnect: Bool {
    get{
        let network = NetworkReachabilityManager()
        return network?.isReachable ?? true //无返回就默认网络已连接
    }
}

