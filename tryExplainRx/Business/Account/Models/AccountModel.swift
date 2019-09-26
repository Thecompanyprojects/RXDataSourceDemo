//
//  AccountModel.swift
//
//
//  Created by  on 2019/3/15.
//  Copyright © 2019年  rights reserved.
//

import SwiftyJSON
import MoyaMapper

struct AccountModel: Modelable {
    var orderUrl: String = ""
    var couponsUrl: String = ""
    var messageUrl: String = ""
    var addressUrl: String = ""
    var contactUrl: String = ""
    var liveChatUrl: String = ""
    var background: String = ""
    var userName: String = ""
    var trackOrderUrl: String = ""
    var faqUrl: String = ""
    var HelpUrl: VHelpUrl = VHelpUrl()
    var contanctUrl: String = ""
    // model 属性映射 json 字段
    mutating func mapping(_ json: JSON) {
        self.trackOrderUrl = json["TrackOrderUrl"].stringValue
        self.faqUrl = json["FaqUrl"].stringValue
        self.contanctUrl = json["ContanctUrl"].stringValue
    }
}

    
   
struct VHelpUrl: Modelable {
    mutating func mapping(_ json: JSON) {
        
    }
    
    var return_policy: String = ""
    var payment: String = ""
    var shipping: String = ""
    var estimate: String = ""
    var terms: String = ""
    var pricacy: String = ""
    var user_safety: String = ""
}
