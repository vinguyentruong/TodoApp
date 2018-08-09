//
//  TaskDetailViewModel.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/25/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RxSwift
import SpringIndicator
import EventBusSwift

class TaskDetailViewModel: BaseViewModel {
    
    //MARK: Property
    internal var task           : Variable<Task>!
    internal let inprogress     = Variable<Bool>(false)
    private let appService      : TodoAppService!
    private let taskRepository  : TaskRepository
    
    //MARK: Construction
    
    init(navigator      : Navigator,
         appService     : TodoAppService,
         taskRepository : TaskRepository) {
        
        self.appService     = appService
        self.taskRepository = taskRepository
        
        super.init(navigator: navigator)
    }
    
    //MARK: Lifecycle
    
    override func onDidLoad() {
        super.onDidLoad()
        
        disposeBag = DisposeBag()
        getTask()
    }
    
    override func onDidReceive(data: Any?) {
        super.onDidReceive(data: data)
        
        if let data = data as? Task {
            if let task = taskRepository.get(withId: data.id) {
                self.task = Variable<Task>(task)
            }
        }
    }
    
    // MARK: Internal methods
    
    internal func getTask() {
        inprogress.value = true
        appService
            .getTaskDetail(taskID: task.value.id)
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(
                onNext: { [weak self] task in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.inprogress.value = false
                    sSelf.task.value = task
                },
                onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.inprogress.value = false
//                    sSelf.showError(error: error)
                }
            ).disposed(by: disposeBag)
    }
    
    internal func updateTask(name: String,
                             deadline: Date,
                             description: String,
                             isDone: Bool) {
        let task = self.task.value.copy() as! Task
        task.updatedAt  = Date()
        task.deadline   = deadline
        task.content    = description
        task.name       = name
        task.rawStatus  = isDone ? Status.done.rawValue : Status.inprogess.rawValue
        SyncManager.default.syncTask(.update, task: task)
    }
}
