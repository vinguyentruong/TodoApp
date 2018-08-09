//
//  JobModel.swift
//  Study
//
//  Created by David Nguyen Truong on 7/3/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import SwiftyJSON

enum Status: String {
    
    case inprogess = "in_progress"
    case done = "done"
    
    internal var description: Bool {
        switch self {
        case .inprogess:
            return false
        default:
            return true
        }
    }
}

class Task: Entity {
    
    //MARK: Property
    
    @objc
    internal dynamic var userId: String = ""
    @objc
    internal dynamic var name: String = ""
    @objc
    internal dynamic var content: String = ""
    @objc
    internal dynamic var deadline: Date = Date()
    @objc
    internal dynamic var rawStatus: String = Status.inprogess.rawValue
    
    internal var status: Status {
        if let status = Status(rawValue: rawStatus) {
            return status
        }
        return Status.inprogess
    }
    
    internal var selected = false

    override class func indexedProperties() -> [String] {
        return ["selected", "status"]
    }
    
    //MARK: Constructor
 
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    init(json: JSON) {
        super.init()
        id          = json["id"].stringValue
        name        = json["name"].stringValue
        content     = json["content"].stringValue
        deadline    = json["deadline"].dateTime ?? Date()
        rawStatus   = json["status"].stringValue
        userId      = json["userId"].stringValue
        deletedAt   = json["deletedAt"].dateTime
        createdAt   = json["createdAt"].dateTime
        updatedAt   = json["updatedAt"].dateTime
    }
    
    init(name: String, date: Date, time: Date, description: String) {
        super.init()
        
        self.id         = ""
        self.name       = name
        self.deadline   = DateHelper.shared.combineDateWithTime(date: date, time: time) ?? Date()
        self.content    = description
    }
    
    init(id: String, name: String, date: Date, time: Date, description: String, status: Status) {
        super.init()
        
        self.id         = id
        self.name       = name
        self.deadline   = DateHelper.shared.combineDateWithTime(date: date, time: time) ?? Date()
        self.content    = description
    }
    
    //MARK: Internal method
    
    internal func toJson() -> [String: Any] {
        var json = [String: Any]()
        json["id"]          = id
        json["name"]        = name
        json["content"]     = content
        json["deadline"]    = deadline.utcDateTimeString
        json["status"]      = status.rawValue
        json["userId"]      = userId
        return json
    }
    
    // MARK: Overide methods
    
    override func copy() -> Any {
        let task = Task()
        task.id         = id
        task.content    = content
        task.name       = name
        task.deadline   = deadline
        task.userId     = userId
        task.rawStatus  = rawStatus
        task.createdAt  = createdAt
        task.deletedAt  = deletedAt
        task.updatedAt  = updatedAt
        return task
    }
}
