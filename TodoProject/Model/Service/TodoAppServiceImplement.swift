//
//  TodoAppServiceImplement.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/24/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class TodoAppServiceImplement: RestService {
    
}

extension TodoAppServiceImplement: TodoAppService {
    
    func creatTask(task: Task) -> Observable<Task> {
        let parameters: [String: Any] = ["name": task.name, "content": task.content, "deadline": task.deadline.dateToString(format: DateFormat.yyyy_MM_dd_T_HH_mm_ss_SSS.name)]
        return Observable.create({ (e) -> Disposable in
            self.apiHelper.post(
                url: "\(Configuration.BaseUrl)/api/tasks",
                parameters: parameters,
                encoding: JSONEncoding.default,
                headerHander: { () -> HTTPHeaders? in
                    return self.defaultHeaders
                },
                responseHandler: { (json, error) in
                    if let err = error {
                        e.on(.error(err))
                    }
                    guard let json = json?["data"] else {
                        return
                    }
                    let task = Task(json: json)
                    e.on(.next(task))
                    e.on(.completed)
                }
            )
            
            return Disposables.create()
        })
    }
    
    func getTasks(page: Int, limit: Int) -> Observable<[Task]> {
        let paremeters = ["limit": limit,"page": page]
        return Observable.create({ [weak self] (e) -> Disposable in
            self?.apiHelper.get(
                url: "\(Configuration.BaseUrl)/api/tasks", parameters: paremeters,
                headerHander: { () -> HTTPHeaders? in
                    return self?.defaultHeaders
                },
                responseHandler: { (json, error) in
                    if let err = error {
                        e.on(.error(err))
                    }
                    guard let json = json?["data"].array else {
                        return
                    }
                    
                    var tasks: [Task] = []
                    for taskData in json {
                        tasks.append(Task(json: taskData))
                    }
                    e.on(.next(tasks))
                    e.on(.completed)
                })
            return Disposables.create()
        })
    }
    
    func getTaskDetail(taskID: String) -> Observable<Task> {
        return Observable.create({ (e) -> Disposable in
            self.apiHelper.get(
                            url: "\(Configuration.BaseUrl)/api/tasks/\(taskID)",
                            parameters: nil,
                            headerHander: { () -> HTTPHeaders? in
                                return self.defaultHeaders
                            },
                            responseHandler: { (json, error) in
                                if let err = error {
                                    e.on(.error(err))
                                }
                                guard let json = json?["data"] else {
                                    return
                                }
                                let task = Task(json: json)
                                e.on(.next(task))
                                e.on(.completed)
                            }
                        )
            
            return Disposables.create()
        })
    }
    
    func deleteTask(_ task: Task) -> Observable<Task> {
        return Observable.create({ (e) -> Disposable in
            self.apiHelper.delete(
                        url: "\(Configuration.BaseUrl)/api/tasks/\(task.id)",
                        parameters: nil,
                        encoding: JSONEncoding.default,
                        headerHander: { () -> HTTPHeaders? in
                            return self.defaultHeaders
                        },
                        responseHandler: { (json, error) in
                            if let json = json?["data"] {
                                let task = Task(json: json)
                                e.on(.next(task))
                            } else if let err = error {
                                e.on(.error(err))
                            }
                            e.on(.completed)
                        }
                    )
            return Disposables.create()
        })
    }
}
