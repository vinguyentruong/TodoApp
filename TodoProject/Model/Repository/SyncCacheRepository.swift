//
//  SyncCacheRepository.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 8/8/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation

class SyncCacheRepository: Repository<SyncCache> {
    
    internal override func getAll() -> [SyncCache]? {
        let results = realm.objects(SyncCache.self)
        if results.isEmpty {
            return nil
        }
        return results
            .map{$0}
            .sorted(by: {$0.createdAt! < $1.createdAt!} )
    }
}
