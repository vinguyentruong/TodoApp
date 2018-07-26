//
//  MainViewModel.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/24/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import SpringIndicator
import SwiftyJSON

class MainViewModel: BaseViewModel {
    
    private let appService: TodoAppService!
    internal var tasks = Variable<[Task]>([])
    private var limit = 20
    private var page = 1
    private var isFulled = false
    internal var inprogress = Variable<Bool>(false)
    internal var saveTasks: [Task] = []
    
    init(navigator: Navigator, appService: TodoAppService) {
        self.appService = appService
        super.init(navigator: navigator)
    }
    
    //MARK: Overide method
    
    override func onDidLoad() {
        super.onDidLoad()
        inprogress.value = false
        disposeBag = DisposeBag()
        getTasks()
    }
    
    //MARK: internal method
    
    func getTasks() {
        getTasksWithLimit()
    }
    
    func loadMore() {
        if !inprogress.value, !isFulled  {
            inprogress.value = true
            getTasksWithLimit()
        }
    }
    
    func getTasksWithLimit() {
        print("getTasksWithLimit")
        appService.getTasks(page: page, limit: limit)
            .asObservable()
            .subscribe(
                onNext: { [weak self] tasks in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.page += 1
                    for task in tasks {
                        sSelf.saveTasks.append(task)
                    }
                    sSelf.tasks.value = sSelf.saveTasks
                    sSelf.inprogress.value = false
                    sSelf.isFulled = tasks.count < sSelf.limit
                },onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.inprogress.value = false
                    sSelf.navigator.showAlert(title: "Error", message: error.localizedDescription, negativeTitle: "OK")
                }
            ).disposed(by: disposeBag)
    }
    
    func deleteTask(task: Task, completion: @escaping ()->()) {
        navigator.showAlert(title: "Confirm",
                            message: "Are you sure?",
                            negativeTitle: "Cancel",
                            positiveTitle: "Ok",
                            negativeHandler: { (_) in
                                return
                            }) { [weak self] (_) in
                                guard let sSelf = self else {
                                    return
                                }
                                sSelf.handleDelete(task: task, completion: completion)
                            }
    }
    
    func handleDelete(task: Task, completion: @escaping ()->()) {
        navigator.viewController?.view.startAnimation(attribute: SpringIndicator.lagreAndCenter)
        appService.deleteTask(task)
            .asObservable()
            .subscribe(
                onNext: { [weak self] task in
                    guard let sSelf = self, let index = sSelf.tasks.value.index(where: {$0.id == task.id}) else {
                        return
                    }
                    sSelf.navigator.viewController?.view.stopAnimation()
                    completion()
                    sSelf.tasks.value.remove(at: index)
                    
                },onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.navigator.viewController?.view.stopAnimation()
                    sSelf.navigator.showAlert(title: "Completed", message: error.localizedDescription, negativeTitle: "OK")
                }
            ).disposed(by: disposeBag)
    }
}
