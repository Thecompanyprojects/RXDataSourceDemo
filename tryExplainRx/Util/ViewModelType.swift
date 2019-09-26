//
//  ViewModelType.swift
//
//
//  Created by  on 2019/3/14.
//  Copyright © 2019年  rights reserved.
//

import UIKit

protocol ViewModelType {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
