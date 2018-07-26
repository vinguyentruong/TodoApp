//
//  BaseObject.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 7/2/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import SwiftyJSON

class BaseObject: NSObject {
    
    // MARK: Property

    internal var id: String = ""
    internal var createdAt: Date?
    internal var updatedAt: Date?
    internal var deletedAt: Date?
    
    // MARK: Constructor
    
    override init() {
        super.init()
    }
    
    internal init(json: JSON) {
        super.init()
        
        id = json["id"].stringValue
        createdAt = json["createdAt"].dateTime
        updatedAt = json["updatedAt"].dateTime
        deletedAt = json["deletedAt"].dateTime
    }
}
