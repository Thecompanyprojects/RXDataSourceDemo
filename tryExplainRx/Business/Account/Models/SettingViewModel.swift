//
//  SettingViewModel.swift
//
//
//  Created by  on 2019/3/23.
//  Copyright © 2019年  rights reserved.
//
import RxDataSources

extension helpVCSection : SectionModelType {
    typealias Item = String
    var identity: String {
        return header
    }
    init(original: helpVCSection, items: [String]) {
        self = original
        self.items = items
    }
}

struct settingVCSection {
    
    var items: [String]
}

extension settingVCSection : SectionModelType {
    typealias Item = String
    init(original: settingVCSection, items: [String]) {
        self = original
        self.items = items
    }
}

struct shipinVCSection {
    var items: [Country]
}

extension shipinVCSection : SectionModelType {
    typealias Item = Country
    init(original: shipinVCSection, items: [Country]) {
        self = original
        self.items = items
    }
}



struct selectorLanguageVCSection {
    
    var items: [Language]
}

extension selectorLanguageVCSection : SectionModelType {
    typealias Item = Language
    init(original: selectorLanguageVCSection, items: [Language]) {
        self = original
        self.items = items
    }
}

struct selectorCurrencyVCSection {
    
    var items: [Currency]
}

extension selectorCurrencyVCSection : SectionModelType {
    typealias Item = Currency
    init(original: selectorCurrencyVCSection, items: [Currency]) {
        self = original
        self.items = items
    }
}

struct selectorCountryVCSection {
    var header : String
    
    var items: [Country]
}

extension selectorCountryVCSection : SectionModelType {
    typealias Item = Country
    var identity: String {
        return header
    }
    init(original: selectorCountryVCSection, items: [Country]) {
        self = original
        self.items = items
    }
}
