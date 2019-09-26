//
//  DataCleanManager.swift
//
//
//  Created by  on 2018/8/21.
//  Copyright © 2018年  rights reserved.
//

import Foundation

class DataCleanManager {
    class func fileSizeOfCache() -> Float {
        guard let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return 0.0
        }
        guard let fileArr = FileManager.default.subpaths(atPath: cachePath) else {
            return 0.0
        }
        var size = 0
        for file in fileArr {
            do {
                let path = cachePath + "/\(file)"
                let floder = try FileManager.default.attributesOfItem(atPath: path)
                for (attr, value) in floder {
                    if attr == FileAttributeKey.size {
                        size += (value as AnyObject).integerValue
                    }
                }
            } catch {
                return Float(0.00)
            }
           
        }
        
        return Float(size/1024/1024)
    }
    //确保trycatch 包围
    class func clearCache() throws {
        guard let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return
        }
        guard let fileArr = FileManager.default.subpaths(atPath: cachePath) else {
            return
        }
        for file in fileArr {
            let path = cachePath + "/\(file)"
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    
                }
            }
        }
    }
}
