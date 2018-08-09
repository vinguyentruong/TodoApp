//
//  MainViewModel.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/24/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RxSwift
import SpringIndicator
import SwiftyJSON
import EventBusSwift

class MainViewModel: BaseViewModel {
    
    //MARK: Property
    
    private let appService: TodoAppService!
    private var tasks = [Task]()
    internal var groups = Variable<[TaskGroup]>([])
    private var currentDate = Date()
    private var limit = 20
    private var page = 1
    private var isFulled = false
    internal var inprogress = Variable<Bool>(false)
    internal var taskRepository: TaskRepository!
    
    //MARK: Construction
    
    init(navigator      : Navigator,
         appService     : TodoAppService,
         taskRepository : TaskRepository) {
        self.taskRepository = taskRepository
        self.appService = appService
        
        super.init(navigator: navigator)
    }
    
    //MARK: Overide method
    
    override func onDidLoad() {
        super.onDidLoad()
        
        inprogress.value = false
        disposeBag = DisposeBag()
        registerDeleteTask()
        registerUpdateTask()
    }
    
    override func onWillAppear() {
        super.onWillAppear()
        
        page = 1
        tasks = []
        getTasks(date: currentDate) { [weak self] in
            guard let sSelf = self else {
                return
            }
            if Util.isConnectedToNetwork() {
                sSelf.fetchTasks(date: sSelf.currentDate)
            }
            SyncManager.default.isSync = true
        }
    }
    
    override func onDestroy() {
        super.onDestroy()
        
        unregister(name: .UpdateTask)
        unregister(name: .DeleteTask)
        unregister(name: .CreateTask)
        SyncManager.default.isSync = false
    }
    
    //MARK: Private methods
    
    private func groupTasks() {
        let groups = Dictionary(grouping: tasks, by: { $0.rawStatus})
        self.groups.value = groups
            .sorted(by: {$0.key.compare($1.key) == .orderedAscending})
            .map { TaskGroup(($0.key == Status.done.rawValue) ? "Done" : "In Progressing", tasks: $0.value)}
    }
    
    private func handleDelete(task: Task, completion: @escaping ()->()) {
        SyncManager.default.syncTask(.delete, task: task)
    }
    
    private func handleDelete(tasks: [Task]) {
        navigator.viewController?.view.startAnimation(attribute: SpringIndicator.lagreAndCenter)
        appService
            .deleteTasks(tasks)
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(
                onNext: { [weak self] success in
                    guard let sSelf = self else {
                        return
                    }
                    if success {
                        for task in tasks {
                            if let index = sSelf.tasks.index(where: { $0.id == task.id }) {
                                sSelf.tasks.remove(at: index)
                                SyncManager.default.syncTask(.delete, task: task)
                            }
                        }
                        sSelf.groupTasks()
                    }
                    sSelf.inprogress.value = false
                    sSelf.navigator.viewController?.view.stopAnimation()
                },
                onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.inprogress.value = false
                    sSelf.navigator.viewController?.view.stopAnimation()
                    sSelf.showError(error: error)
                },
                onCompleted: { [weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.inprogress.value = false
                    sSelf.navigator.viewController?.view.stopAnimation()
                }
            ).disposed(by: disposeBag)
    }
    
    // MARK: internal method
    
    internal func fetchTasks(date: Date) {
        appService
            .getTasks(page: page, limit: limit, date: date)
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(
                onNext: { [weak self] tasks in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.page += 1
                    sSelf.inprogress.value = false
                    sSelf.isFulled = tasks.count < sSelf.limit
                    sSelf.taskRepository.add(tasks, update: true)
                    sSelf.getTasks(date: date)
                },onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.inprogress.value = false
                    sSelf.showError(error: error)
                }
            ).disposed(by: disposeBag)
    }
    
    internal func getTasks(date: Date, completion: CompletionHandeler? = nil) {
        currentDate = date
        groups.value = []
        inprogress.value = true
        taskRepository
            .getTasks(by: currentDate)
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(onNext: { [weak self] tasks in
                guard let sSelf = self else {
                    return
                }
                sSelf.tasks = tasks
                sSelf.groupTasks()
                sSelf.inprogress.value = false
                completion?()
            }
        ).disposed(by: disposeBag)
    }
    
    internal func loadMoreForDate() {
        if !inprogress.value, !isFulled  {
            inprogress.value = true
            fetchTasks(date: currentDate)
        }
    }
    
    internal func deleteTask(task: Task, completion: @escaping ()->()) {
        navigator.showAlert(
            title: "Confirm",
            message: "Are you sure to delete task?",
            negativeTitle: "Cancel",
            positiveTitle: "Ok",
            negativeHandler: { (_) in
                return
                
            }) { [weak self] (_) in
                guard let sSelf = self else {
                    return
                }
                if !sSelf.inprogress.value {
                    sSelf.inprogress.value = true
                    sSelf.handleDelete(task: task, completion: completion)
                }
            }
    }
    
    internal func deleteTasks() {
        let tasks = self.tasks.filter({ $0.selected })
        if tasks.isEmpty {
            return
        }
        navigator.showAlert(
            title: "Confirm",
            message: "Are you sure to delete task?",
            negativeTitle: "Cancel",
            positiveTitle: "Ok",
            negativeHandler: { (_) in
                return
                
        }) { [weak self] (_) in
            guard let sSelf = self else {
                return
            }
            if !sSelf.inprogress.value {
                sSelf.inprogress.value = true
                sSelf.handleDelete(tasks: tasks)
            }
        }
    }
    
    // MARK: Register Event
    
    private func registerUpdateTask() {
        register(name: .UpdateTask) { [weak self] (data) in
            guard let sSelf = self else {
                return
            }
            if let task = data as? Task, let index = sSelf.tasks.index(where: { $0.id == task.id }) {
                sSelf.tasks[index] = task
                sSelf.groupTasks()
            }
        }
    }
    
    private func registerDeleteTask() {
        register(name: .DeleteTask) { [weak self] (data) in
            guard let sSelf = self else {
                return
            }
            sSelf.getTasks(date: sSelf.currentDate)
            sSelf.navigator.viewController?.view.stopAnimation()
            sSelf.inprogress.value = false
        }
    }
}
