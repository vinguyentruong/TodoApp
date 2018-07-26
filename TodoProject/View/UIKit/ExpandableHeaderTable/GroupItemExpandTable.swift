//
//  GroupItemExpandTable.swift
//  Study
//
//  Created by David Nguyen Truong on 7/4/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation

protocol GroupItemsExpandTable: class {
    
    var rowCount: Int { get }
    var sectionTitle: String { get }
    var isExpand: Bool { get set }
}
