//
//  api.swift
//
//
//  Created 2018/10/17.
//  Copyright © 2018年  rights reserved.
//

import Foundation
import Alamofire


class API {
    
    private static let API_POINT = "\(AppConfig.HOME)/apis/app/"
    
    @discardableResult public static func post(_ path: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) -> DataRequest {
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let params = wrapParameters(timeStamp, parameters: parameters)
        let wrapheaders = wrapHeaders(timeStamp, headers: headers)
        return Alamofire.request("\(API_POINT)\(path)", method: .post, parameters: params,encoding: JSONEncoding.default, headers: wrapheaders)
    }
    
    @discardableResult public static func get(_ path: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) -> DataRequest {
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let params = wrapParameters(timeStamp, parameters: parameters)
        let wrapheaders = wrapHeaders(timeStamp, headers: headers)
        return Alamofire.request("\(API_POINT)\(path)", method: .get, parameters: params, headers: wrapheaders)
    }
    
    private static func wrapParameters(_ timeStamp: Int, parameters: Parameters? = nil) -> Parameters {
        var params = parameters ?? Parameters()
        params["device_id"] = "111"
        params["device_type"] = "IOS"
        params["app_version"] = AppConfig.VERSION_STRING ?? ""
        params["time_stamp"] = timeStamp
        return params
    }
    
    private static func wrapHeaders(_ timeStamp: Int, headers: HTTPHeaders? = nil) -> HTTPHeaders {
        var wrapHeaders = headers ?? HTTPHeaders()
        wrapHeaders["Accept"] = "application/json"
        let token = "111caCaCa\(timeStamp)".md5()
        wrapHeaders["Authorization"] = "Basic \(token)"
        return wrapHeaders
    }
}
