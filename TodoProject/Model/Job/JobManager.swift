//
//  JobManager.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 7/4/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation

open class JobManager: NSObject {
    
    // MARK: Property
    
    private var isBusy = false
    private var isStopped = true
    
    public private(set) var jobs = PriorityQueue<Job>()
    
    public var isCompleted: Bool {
        return jobs.isEmpty
    }
    
    // MARK: Public method
    
    public func execute(_ job: Job) {
        jobs.push(job)
        maybeExecuteNextJob()
    }
    
    // MARK: Private method
    
    private func maybeExecuteNextJob() {
        if !jobs.isEmpty && !isBusy {
            isBusy = true
            let job = jobs.peek()
            job?.closure = ({ [weak self] (error) in
                _ = self?.jobs.pop()
                self?.isBusy = false
                self?.maybeExecuteNextJob()
            })
            job?.start()
        }
    }
    
}
