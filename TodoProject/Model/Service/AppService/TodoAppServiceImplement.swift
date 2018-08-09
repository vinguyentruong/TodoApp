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
import SwiftyJSON

class TodoAppServiceImplement: RestService {
    
}

extension TodoAppServiceImplement: TodoAppService {
    
    func creatTask(task: Task) -> Observable<Task> {
        let parameters: [String: Any] = ["id"       : task.id,
                                         "name"     : task.name,
                                         "content"  : task.content,
                                         "deadline" : task.deadline.dateToString(format: DateFormat.yyyy_MM_dd_T_HH_mm_ss_SSS.name)]
        
        return Observable.create({ (e) -> Disposable in
            self.apiHelper.post(
                url             : "\(Configuration.BaseUrl)/api/tasks",
                parameters      : parameters,
                encoding        : JSONEncoding.default,
                headerHander    : { self.defaultHeaders },
                responseHandler : { (json, error) in
                    if let err = error {
                        e.on(.error(err))
                    } else if let json = json?["data"] {
                        let task = Task(json: json)
                        e.on(.next(task))
                    }
                    e.on(.completed)
                }
            )
            return Disposables.create()
        })
    }
    
    func getTasks(page: Int, limit: Int) -> Observable<[Task]> {
        let paremeters = ["limit"   : limit,
                          "page"    : page]
        return Observable.create({ [weak self] (e) -> Disposable in
            self?.apiHelper.get(
                url             : "\(Configuration.BaseUrl)/api/tasks",
                parameters      : paremeters,
                headerHander    : { self?.defaultHeaders },
                responseHandler : { (json, error) in
                    if let err = error {
                        e.on(.error(err))
                        return
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
    
    func getTasks(page: Int, limit: Int, date: Date) -> Observable<[Task]> {
        let paremeters: [String: Any] = ["limit": limit,
                                         "page" : page,
                                         "date" : date.utcDateTimeString]
        return Observable.create({ [weak self] (e) -> Disposable in
            self?.apiHelper.get(
                url             : "\(Configuration.BaseUrl)/api/tasks",
                parameters      : paremeters,
                headerHander    : { self?.defaultHeaders },
                responseHandler : { (json, error) in
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
                            url             : "\(Configuration.BaseUrl)/api/tasks/\(taskID)",
                            parameters      : nil,
                            headerHander    : { self.defaultHeaders },
                            responseHandler : { (json, error) in
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
                        url             : "\(Configuration.BaseUrl)/api/tasks/\(task.id)",
                        parameters      : nil,
                        encoding        : JSONEncoding.default,
                        headerHander    : { self.defaultHeaders },
                        responseHandler : { (json, error) in
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
    
    func deleteTasks(_ tasks: [Task]) -> Observable<Bool> {
        let parameters = ["taskIds": tasks.map{$0.id}]
        return Observable.create({ (e) -> Disposable in
            self.apiHelper.delete(
                url             : "\(Configuration.BaseUrl)/api/tasks",
                parameters      : parameters,
                encoding        : JSONEncoding.default,
                headerHander    : { self.defaultHeaders },
                responseHandler : { (json, error) in
                    if let check = json?["data"].boolValue {
                        e.on(.next(check))
                    }
                    if let error = error {
                        e.on(.error(error))
                    }
                    e.on(.completed)
                }
            )
            return Disposables.create()
        })
    }
    
    func updateTask(_ task: Task) -> Observable<Task> {
        let parameters: [String: Any] = task.toJson()
        return Observable.create({ (e) -> Disposable in
            self.apiHelper.put(
                url             : "\(Configuration.BaseUrl)/api/tasks/\(task.id)",
                parameters      : parameters,
                encoding        : JSONEncoding.default,
                headerHander    : { self.defaultHeaders },
                responseHandler : { (json, error) in
                    if let json = json?["data"] {
                        let task = Task(json: json)
                        e.on(.next(task))
                    }
                    if let error = error {
                        e.on(.error(error))
                    }
                    e.on(.completed)
                }
            )
            return Disposables.create()
        })
    }
    
    func getUser() -> Observable<User> {
        return Observable.create({ (e) -> Disposable in
            self.apiHelper.get(
                url             : "\(Configuration.BaseUrl)/api/users",
                parameters      : nil,
                headerHander    : { self.defaultHeaders },
                responseHandler : { (json, error) in
                    if let json = json?["data"] {
                        let user = User(json: json)
                        e.on(.next(user))
                    }
                    if let error = error {
                        e.on(.error(error))
                    }
//                    e.on(.completed)
                }
            )
            return Disposables.create()
        })
    }
    
    func updateUser(_ user: User) -> Observable<User> {
        let parameters = ["displayName" : user.displayName,
                          "username"    : user.username,
                          "avatar"      : user.avatar]
        return Observable.create({ (e) -> Disposable in
            self.apiHelper.put(
                url             : "\(Configuration.BaseUrl)/api/users",
                parameters      : parameters,
                encoding        : JSONEncoding.default,
                headerHander    : { self.defaultHeaders },
                responseHandler : { (json, error) in
                    if let json = json?["data"] {
                        let user = User(json: json)
                        e.on(.next(user))
                    }
                    if let error = error {
                        e.on(.error(error))
                    }
                    e.on(.completed)
            }
            )
            return Disposables.create()
        })
    }
    
    func changePassword(oldPassword: String, newPassword: String) -> Observable<Bool> {
        let parameters = ["oldPassword": oldPassword,
                          "newPassword": newPassword]
        return Observable.create({ (e) -> Disposable in
            self.apiHelper.put(
                url             : "\(Configuration.BaseUrl)/api/users/change-password",
                parameters      : parameters,
                encoding        : JSONEncoding.default,
                headerHander    : { self.defaultHeaders },
                responseHandler : { (json, error) in
                    if let check = json?["data"].boolValue {
                        e.on(.next(check))
                    }
                    if let error = error {
                        e.on(.error(error))
                    }
//                    e.on(.completed)
                }
            )
            return Disposables.create()
        })
    }
    
    func getAvatar(path: String?) -> Observable<URL?> {
        let path = (path == nil) ? "" : path!
        return Observable.create({ (e) -> Disposable in
            self.apiHelper.post(
                url             : "\(Configuration.BaseUrl)/api/users/avatar/\(path)",
                parameters      : nil,
                encoding        : JSONEncoding.default,
                headerHander    : { self.defaultHeaders },
                responseHandler : { (json, error) in
                    if let error = error {
                        e.on(.error(error))
                    } else {
                        e.on(.next(json?.url))
                    }
                    e.on(.completed)
                }
            )
            return Disposables.create()
        })
    }
}
