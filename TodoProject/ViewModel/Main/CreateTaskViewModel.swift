//
//  CreateTaskViewModel.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/25/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RxSwift
import SpringIndicator
import EventBusSwift

class CreateTaskViewModel: BaseViewModel {
    
    //MARK: Property
    
    private let appService: TodoAppService!
    private let taskRepository: TaskRepository
    
    //MARK: Construction
    
    init(navigator      : Navigator,
         appService     : TodoAppService,
         taskRepository : TaskRepository) {
        self.appService = appService
        self.taskRepository = taskRepository
        
        super.init(navigator: navigator)
    }
    
    //MARK: Lifecycle
    
    override func onDidLoad() {
        super.onDidLoad()
        
        disposeBag = DisposeBag()
        registerCreate()
    }
    
    override func onDestroy() {
        super.onDestroy()
        
        unregister(name: .CreateTask)
    }
    
    func createTask(name: String, date: Date?, time: Date?, description: String) {
        if name.trimmed.isEmpty || date == nil || time == nil {
            navigator.showAlert(title           : "Error",
                                message         : "You must fill in all of the fields!",
                                negativeTitle   : "Ok")
            return
        }
        let task = Task(name        : name,
                        date        : date!,
                        time        : time!,
                        description : description)
        task.createdAt = Date()
        SyncManager.default.syncTask(.create, task: task)
        navigator.viewController?.view.startAnimation()
    }
    
    // MARK: Private methods
    
    private func registerCreate() {
        register(name: .CreateTask) { [weak self] (data) in
            guard let sSelf = self else {
                return
            }
            sSelf.navigator.viewController?.view.stopAnimation()
            sSelf.navigator.showAlert(
                title           : "Completed",
                message         : "Create successful!",
                negativeTitle   : "Ok",
                negativeHandler : { (_) in
                    sSelf.navigator.popView(animated: true)
            })
        }
    }
    
}


