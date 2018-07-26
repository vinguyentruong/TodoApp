//
//  BaseTodoViewController.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/23/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BaseTodoViewController: MVVMViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindData()
        bindAction()
    }
    
    @objc
    internal func bindData() {
        //
    }
    
    @objc
    internal func bindAction() {
        //
    }
}
