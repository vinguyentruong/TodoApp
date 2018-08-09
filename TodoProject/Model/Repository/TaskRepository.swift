//
//  TaskRepository.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/31/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import RxSwift
import RealmSwift

class TaskRepository: Repository<Task> {
    
    internal func getTasks(by date: Date) -> Observable<[Task]> {
        let dateStart = Calendar.current.startOfDay(for: date)
        let dateEnd: Date = {
            let components = DateComponents(day: 1, second: -1)
            return Calendar.current.date(byAdding: components, to: dateStart)!
        }()
        let predicate = NSPredicate(format: "deadline BETWEEN %@ AND deletedAt == nil", [dateStart, dateEnd])
        return realm
            .objects(Task.self)
            .filter(predicate)
            .sorted(byKeyPath: "deadline", ascending: false)
            .asObservableArray()
    }
    
    internal func deleteTask(task: Task) {
        let realm = self.realm
        try? realm.write {
            if let object = realm.object(ofType: Task.self, forPrimaryKey: task.id), !object.isInvalidated {
                realm.delete(object)
            }
        }
    }

}
