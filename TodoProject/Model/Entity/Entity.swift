//
//  Entity.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 7/4/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//


import Foundation
import RealmSwift
import SwiftyJSON

class Entity: Object {
    
    // MARK: Property
    
    @objc
    internal dynamic var id: String = ""
    @objc
    internal dynamic var createdAt: Date?
    @objc
    internal dynamic var updatedAt: Date?
    @objc
    internal dynamic var deletedAt: Date?
    
    // MARK: Override method
    
    internal override class func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: Internal method
    
    internal func from(json: JSON) {
        id = json["id"].stringValue
        createdAt = json["createdAt"].dateTime
        updatedAt = json["updatedAt"].dateTime
        deletedAt = json["deletedAt"].dateTime
    }
    
    
    internal static func sortByCreatedAt<T: Entity>(entities: [T]) -> [T] {
        let sorted = entities.sorted(by: { (i1, i2) -> Bool in
            guard
                let createdAt1 = i1.createdAt, let createdAt2 = i2.createdAt else {
                    return false
            }
            return createdAt1 <= createdAt2
        })
        return sorted
    }
}
