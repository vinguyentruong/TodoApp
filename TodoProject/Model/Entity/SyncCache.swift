//
//  Cache.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 7/10/18.
//  Copyright © 2018 DAD PTE LTD. All rights reserved.
//

import UIKit

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
        let taskRepository = TaskRepository()
        return taskRepository.get(withId: taskID)
    }
}
