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
    case inprogess
    case done
}

class Task: Object {
    
    //MARK: Property
    
    @objc
    internal dynamic var id: String = ""
    @objc
    internal dynamic var userId: String = ""
    @objc
    internal dynamic var name: String = ""
    @objc
    internal dynamic var content: String = ""
    @objc
    internal dynamic var deadline: Date = Date()
    @objc
    internal dynamic var status: String = Status.inprogess.rawValue
    
    
    
    internal var selected = false
    internal var done = false

    override class func indexedProperties() -> [String] {
        return ["isSelected", "done"]
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
        deadline    = json["deadline"].dateTimeValue
        status      = json["status"].stringValue
        done = (status == Status.done.rawValue)
    }
    
    init(name: String, date: Date, time: Date, description: String) {
        super.init()
        self.id = ""
        self.name = name
        self.deadline = DateHelper.shared.combineDateWithTime(date: date, time: time) ?? Date()
        self.content = description
        self.status = Status.inprogess.rawValue
        done = false
    }
    
    //MARK: overide
    internal override class func primaryKey() -> String? {
        return "id"
    }
    
    //MARK: Internal method
    
    internal static func getDefault()-> [Task] {
        if let path = Bundle.main.url(forResource: "Test", withExtension: "plist") {
            if let data = try? Data(contentsOf: path), let dictionary = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: String]{
                var jobs:[Task] = []
                dictionary?.forEach({ (item) in
                    let model = Task()
                    model.name = item.value
                    model.id = UUID().uuidString
                    jobs.append(model)
                })
                return jobs
            }
        }
        return []
    }
}
