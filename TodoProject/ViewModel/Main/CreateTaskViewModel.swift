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

class CreateTaskViewModel: BaseViewModel {
    
    //MARK: Property
    private let appService: TodoAppService!
    
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
    
    func createTask(name: String, date: Date?, time: Date?, description: String) {
        if name.trimmed.isEmpty || description.trimmed.isEmpty || date == nil || time == nil {
            navigator.showAlert(title: "Error", message: "You must fill in all of the fields!", negativeTitle: "Ok")
            return
        }
        
        let task = Task(name: name, date: date!, time: time!, description: description)
        navigator.viewController?.view.startAnimation()
        appService.creatTask(task: task)
            .asObservable()
            .subscribe(
                onNext: { [weak self] task in
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
                            }
                        )
                },onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.navigator.viewController?.view.stopAnimation()
                    sSelf.navigator.showAlert(
                            title           : "Error",
                            message         : error.localizedDescription,
                            negativeTitle   : "Ok"
                        )
                }
            ).disposed(by: disposeBag)
    }
}


