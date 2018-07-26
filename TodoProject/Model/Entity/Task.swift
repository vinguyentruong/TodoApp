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

class Task: Object {
    
    @objc internal dynamic var id: String = ""
    
    @objc
    internal dynamic var name: String = ""
    internal var selected = false
    internal var done = false

    override class func indexedProperties() -> [String] {
        return ["isSelected", "done"]
    }
 
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
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
