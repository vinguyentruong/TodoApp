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

class TaskDetailViewModel: BaseViewModel {
    
    //MARK: Property
    internal var task = Variable<Task?>(nil)
    private let appService: TodoAppService!
    private var taskID: String!
    
    //MARK: Construction
    
    init(navigator: Navigator, appService: TodoAppService) {
        self.appService = appService
        super.init(navigator: navigator)
    }
    
    //MARK: Lifecycle
    
    override func onDidLoad() {
        super.onDidLoad()
        
        disposeBag = DisposeBag()
    }
    
    override func onDidReceive(data: Any?) {
        super.onDidReceive(data: data)
        
        if let id = data as? String {
            taskID = id
            getTask()
        }
    }
    
    func getTask() {
        navigator.viewController?.view.startAnimation(attribute: SpringIndicator.lagreAndCenter)
        appService.getTaskDetail(taskID: taskID)
            .asObservable()
            .subscribe(
                onNext: { [weak self] task in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.navigator.viewController?.view.stopAnimation()
                    sSelf.task.value = task
                },
                onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.navigator.viewController?.view.stopAnimation()
                    sSelf.navigator.showAlert(title: "Error", message: error.localizedDescription, negativeTitle: "Ok")
                }
            ).disposed(by: disposeBag)
    }
}
