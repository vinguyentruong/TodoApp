//
//  UpdateTaskJob.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 8/7/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RxSwift
import EventBusSwift

class SyncTaskJob: Job {
    
    // MARK: Property
    
    private var task            : Task
    private var taskRepository  : TaskRepository
    private var appService      : TodoAppService
    private var syncAction      : SyncAction
    private var disposeBag      : DisposeBag
    
    // MARK: Construction
    
    init(priority       : JobPriority,
         task           : Task,
         taskRepository : TaskRepository,
         appService     : TodoAppService,
         syncAction     : SyncAction) {
        
        self.task           = task
        self.taskRepository = taskRepository
        self.appService     = appService
        self.syncAction     = syncAction
        disposeBag = DisposeBag()
        
        super.init(priority: priority)
    }
    
    // MARK: Overide methods
    
    override func onRun() throws {
        switch syncAction {
        case .create:
            create()
        case .update:
            update()
        case .delete:
            delete()
        }
    }
    
    // MARK: Private methods
    
    private func create() {
        NSLog("sync create")
        if task.id.trimmed.isEmpty {
            task.id = UUID().uuidString.lowercased()
        }
        taskRepository.add(task, update: true)
        if !Util.isConnectedToNetwork() {
            EventBus.shared.post(name: .CreateTask, object: task)
        }
        appService.creatTask(task: task)
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(
                onNext: { [weak self] task in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.stop()
                    EventBus.shared.post(name: .CreateTask, object: task)
                },onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.saveSyncCache()
                    sSelf.stop()
                    sSelf.onError(error)
                }
            ).disposed(by: disposeBag)
    }
    
    private func update() {
        NSLog("sync update")
        taskRepository.add(task, update: true)
        EventBus.shared.post(name: .UpdateTask, object: task)
        appService
            .updateTask(task)
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(
                onNext: { [weak self] task in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.stop()
                    EventBus.shared.post(name: .UpdateTask, object: task)
                },
                onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.saveSyncCache()
                    sSelf.stop()
                    sSelf.onError(error)
                }
            ).disposed(by: disposeBag)
    }
    
    private func delete() {
        NSLog("sync delete")
        taskRepository.write {
            task.deletedAt = Date()
        }
        EventBus.shared.post(name: .DeleteTask, object: task)
        appService.deleteTask(task)
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(
                onNext: { [weak self] task in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.stop()
                    sSelf.taskRepository.add(task, update: true)
                    EventBus.shared.post(name: .DeleteTask, object: task)
                },onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.saveSyncCache()
                    sSelf.stop()
                    sSelf.onError(error)
                }
            ).disposed(by: disposeBag)
    }
    
    private func saveSyncCache() {
        let syncRepository = SyncCacheRepository()
        let syncCache = SyncCache()
        syncCache.createdAt = Date()
        syncCache.id = UUID().uuidString
        syncCache.rawAction = syncAction.rawValue
        syncCache.taskID = task.id
        syncRepository.add(syncCache, update: false)
    }
}
