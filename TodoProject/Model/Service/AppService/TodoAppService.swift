//
//  TodoAppService.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/24/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RxSwift

protocol TodoAppService: class {
    
    func creatTask(task: Task) -> Observable<Task>
    func getTasks(page: Int, limit: Int) -> Observable<[Task]>
    func getTasks(page: Int, limit: Int, date: Date) -> Observable<[Task]>
    func getTaskDetail(taskID: String) -> Observable<Task>
    func updateTask(_ task: Task) -> Observable<Task>
//    func updateTasks(_ tasks: [Task]) -> Observable<[Task]>
    func deleteTask(_ task: Task) -> Observable<Task>
    func deleteTasks(_ tasks: [Task]) -> Observable<Bool>
    
    func getUser() -> Observable<User>
    func updateUser(_ user: User) -> Observable<User>
    func changePassword(oldPassword: String, newPassword: String) -> Observable<Bool>
    func getAvatar(path: String?) -> Observable<URL?>
}
