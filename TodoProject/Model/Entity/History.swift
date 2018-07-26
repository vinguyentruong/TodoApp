//
//  History.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 7/4/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RealmSwift

@objc
enum HistoryAction: Int {
    case sync = 0, clean
}

class History: Object {
    
    // MARK: Property
    
    @objc
    internal dynamic var id: String?
    @objc
    internal dynamic var updatedAt: Date?
    @objc
    internal dynamic var action: HistoryAction = .sync
    
    // MARK: Override method
    
    internal override class func primaryKey() -> String? {
        return "id"
    }
    
}
