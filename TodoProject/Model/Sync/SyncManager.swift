//
//  SyncManager.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/31/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import EventBusSwift
import SwinjectStoryboard
import Swinject
import Reachability

public enum SyncAction: String {
    case create
    case update
    case delete
}

class SyncManager {
    
    // MARK: Property
    
    private var taskRepository  : TaskRepository
    private var appService      : TodoAppService
    private var jobManager      : JobManager
    private var reachability    : Reachability!
    internal var isSync         = false {
        didSet {
            if isSync {
                do {
                    try reachability?.startNotifier()
                } catch {
                    print("Unable to start notifier")
                }
            } else {
                reachability.stopNotifier()
            }
        }
    }
    
    internal static var `default`: SyncManager {
        let container   = SwinjectStoryboard.defaultContainer
        let syncManager = container.resolve(SyncManager.self)!
        return syncManager
    }
    
    //MARK: Construction
    
    init(taskRepository: TaskRepository, appService: TodoAppService, jobManager: JobManager) {
        self.taskRepository = taskRepository
        self.appService     = appService
        self.jobManager     = jobManager
        
        reachability = Reachability()
        
        reachability?.whenReachable = { reachability in
            if reachability.connection != .none {
               self.autoSync()
            }
        }
        reachability?.whenUnreachable = { reachability in
            print("Unconnected")
        }
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    deinit {
        reachability.stopNotifier()
    }
    
    // MARK: Internal methods
    
    internal func getJobs() -> [Job] {
        var jobs = [Job]()
        jobs = jobManager.jobs.map{$0}
        return jobs
    }
    
    internal func syncTask(_ action: SyncAction, task: Task) {
        let job = SyncTaskJob(priority          : .medium,
                              task              : task,
                              taskRepository    : taskRepository,
                              appService        : appService,
                              syncAction        : action)
        jobManager.addJob(job)
        jobManager.execute()
    }
    
    internal func autoSync() {
        let syncRepository = SyncCacheRepository()
        guard let syncCaches = syncRepository.getAll() else {
            return
        }
        for sync in syncCaches {
            if let task = sync.task {
                self.syncTask(sync.action, task: task)
            }
        }
        syncRepository.delete(syncCaches)
    }
    
    internal func clean() {
        guard let tasks = taskRepository.getAll() else {
            return
        }
        taskRepository.delete( tasks.filter{$0.deletedAt != nil} )
    }
    
}
