//
//  URL+Extensions.swift
//
//
//  Created 2018/9/29.
//  Copyright © 2018年  rights reserved.
//

import Foundation


extension URL {
    
    func queryParameters(_ name: String) -> String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            return nil
        }
        return queryItems.first(where: { $0.name == name })?.value
    }
    
    func getUTMSource() -> String? {
        return queryParameters("utm_source")
    }
    
    func getUTMMedium() -> String? {
        return queryParameters("utm_medium")
    }
    
    func getUTMCampaign() -> String? {
        return queryParameters("utm_campaign")
    }
    
    func addOrUpdateParameters(name: String, value: String?) -> URL? {
        if var components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            var queryItems = components.queryItems {
            if let val = queryItems.first(where: { $0.name == name }) {
                if let index = queryItems.firstIndex(of: val) {
                    if let v = value {
                       //update value
                        queryItems[index].value = v
                    } else {
                        //remove exits item
                        queryItems.remove(at: index)
                    }
                }
            } else {
                //add value
                if let v = value {
                    queryItems.append(URLQueryItem(name: name, value: v))
                }
            }
            components.queryItems = queryItems
            return  try? components.asURL()
        }
        return self
    }
    
    func delParameters(_ name: String) -> URL? {
        return addOrUpdateParameters(name: name, value: nil)
    }
    
}
