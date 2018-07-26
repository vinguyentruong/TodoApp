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

class LoginViewModel: BaseViewModel {
    
    private let oauthService: OAuthProtocol
    internal var loginSuccess = Variable<Bool>(false)
    
    init(navigator: Navigator, oauthService: OAuthProtocol) {
        self.oauthService = oauthService
        super.init(navigator: navigator)
    }
    
    //MARK: Overide method
    
    override func onDidLoad() {
        super.onDidLoad()
        
        disposeBag = DisposeBag()
    }
    
    //MARK: internal method
    
    internal func login(email: String, password: String) {
        navigator.beginIgnoringEvent()
        oauthService
            .login(email: email, password: password)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] data in guard let sSelf = self else {return}
                    OAuthToken.default.update(oauthToken: data)
                    sSelf.loginSuccess.value = true
                    sSelf.navigator.endIgnoringEvent()
                },
                onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.loginSuccess.value = false
                    sSelf.navigator.endIgnoringEvent()
                    sSelf.navigator.showAlert(title: "Error",
                                              message: error.localizedDescription,
                                              negativeTitle: "Ok")
                }
            ).disposed(by: disposeBag)
    }
}
