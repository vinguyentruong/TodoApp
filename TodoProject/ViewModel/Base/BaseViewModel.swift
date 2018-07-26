//
//  BaseViewModel.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 6/27/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewModel: ViewModel {
    
    internal var disposeBag: DisposeBag!
    
    override func onDestroy() {
        disposeBag = nil
    }
}
