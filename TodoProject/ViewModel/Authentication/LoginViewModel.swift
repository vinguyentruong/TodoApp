//
//  LoginViewModel.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/20/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import SpringIndicator

class LoginViewModel: BaseViewModel {
    
    private let oauthService: OAuthProtocol
    private let appService: TodoAppService!
    internal var inProcessing = Variable<Bool>(false)
    
    init(navigator      : Navigator,
         oauthService   : OAuthProtocol,
         appService     : TodoAppService) {
        self.oauthService = oauthService
        self.appService = appService
        
        super.init(navigator: navigator)
    }
    
    //MARK: Overide method
    
    override func onDidLoad() {
        super.onDidLoad()
        
        disposeBag = DisposeBag()
    }
    
    //MARK: internal method
    
    internal func login(email: String, password: String) {
        navigator.viewController?.view.startAnimation(attribute: SpringIndicator.lagreAndCenter)
        oauthService
            .login(email: email, password: password)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] data in
                    guard let sSelf = self else {
                        return
                    }
                    OAuthToken.default.update(oauthToken: data)
                    sSelf.getUser()
                    sSelf.navigator.viewController?.view.stopAnimation()
                },
                onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.inProcessing.value = false
                    sSelf.navigator.viewController?.view.stopAnimation()
                    sSelf.showError(error: error)
                }
            ).disposed(by: disposeBag)
    }
    
    func getUser() {
        appService.getUser()
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(
                onNext: { [weak self] user in
                    guard let sSelf = self else {
                        return
                    }
                    let userDefault = user
                    userDefault.logined = true
                    User.default = userDefault
                    sSelf.inProcessing.value = true
                },
                onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.inProcessing.value = true
                }
        ).disposed(by: disposeBag)
    }
}
