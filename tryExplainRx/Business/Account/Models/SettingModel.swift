//
//  SettingModel.swift
//
//
//  Created by  on 2019/3/12.
//  Copyright © 2019年  rights reserved.
//

import SwiftyJSON
import MoyaMapper
import RxDataSources

struct SettingModel: Modelable {
    var countries : Countries = Countries()
    var languages : Languages = Languages()
    var currencies : Currencies = Currencies()
    mutating func mapping(_ json: JSON) {
    }
}





struct Languages : Modelable  {
    var showLanguages :  [Language] = []
    var selectLangName : String = ""
    var selectCode : String = ""
    mutating func mapping(_ json: JSON) {
    }
}

struct Language : Modelable {
    var code : String = ""
    var name: String = ""
    var jump: Jump = Jump()
    mutating func mapping(_ json: JSON) {
    }
}

struct Countries : Modelable{
    var allCountries : [Country] = []
    var priorCountries : [Country] = []
    var priorCountriesDivide : NSInteger = 0
    var selectCountry : String = ""
    mutating func mapping(_ json: JSON) {
    }
   
}

struct Country : Modelable {
    var id : NSInteger = 0
    var name : String = ""
    var jump : Jump = Jump()
    mutating func mapping(_ json: JSON) {
    }
    
}

struct Currencies  : Modelable {
    var currencies : [Currency] = []
    var currencySymbol : String = ""
    mutating func mapping(_ json: JSON) {
    }
    
}

struct Currency : Modelable {
    var id : String = ""
    var name : String = ""
    var symbol : String = ""
    var localSymbol : String = ""
    var exchange : String = ""
    var base : String = ""
    var disabled : String = ""
    var descEn : String = ""
    var jump : Jump = Jump()
    mutating func mapping(_ json: JSON) {
    }
}

struct Jump : Modelable {
    var ucid : String = ""
    var currency : String = ""
    var lang : String = ""
    mutating func mapping(_ json: JSON) {
    }
}


struct helpVCSection {
    var header: String
    var items: [String]
}


