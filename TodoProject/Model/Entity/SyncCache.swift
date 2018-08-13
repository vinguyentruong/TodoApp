//
//  Cache.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 7/10/18.
//  Copyright © 2018 DAD PTE LTD. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import SwinjectStoryboard

class SyncCache: Entity {
    
    @objc
    internal dynamic var rawAction = SyncAction.update.rawValue
    
    @objc
    internal dynamic var taskID: String = ""
    
    internal var action: SyncAction {
        switch rawAction {
        case SyncAction.create.rawValue:
            return SyncAction.create
        case SyncAction.update.rawValue:
            return SyncAction.update
        case SyncAction.delete.rawValue:
            return SyncAction.delete
        default:
            return SyncAction.update
        }
    }
    
    internal var task: Task? {
        return taskRepository.get(withId: taskID)
    }
    
    private var taskRepository: TaskRepository!
    
    // MARK: Construction
    
    required init() {
        super.init()
        
        taskRepository = SwinjectStoryboard.defaultContainer.resolve(TaskRepository.self)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
        
        taskRepository = SwinjectStoryboard.defaultContainer.resolve(TaskRepository.self)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
        
        taskRepository = SwinjectStoryboard.defaultContainer.resolve(TaskRepository.self)
    }
}
