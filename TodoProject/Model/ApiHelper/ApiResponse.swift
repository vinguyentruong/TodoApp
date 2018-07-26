//
//  ApiResponse.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 6/19/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

public class ApiResponse<T>: NSObject {
    
    // MARK: Property
    
    public var error: Error?
    public var data: T?
}
