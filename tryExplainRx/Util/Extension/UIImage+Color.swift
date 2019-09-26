//
//  UIImage+Color.swift
//
//
//  Created by  on 2019/3/2.
//  Copyright © 2019年  rights reserved.
//

import UIKit

extension UIImage {
    public static func color(_ color: UIColor) -> UIImage {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let imageData = image.jpegData(compressionQuality: 1.0)!
        image = UIImage(data: imageData)!
        return image
    }
    
    
    
    
}
