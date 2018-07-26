//
//  ProfileViewModel.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/24/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RxSwift
import SpringIndicator

class ProfileViewModel: BaseViewModel {
    
    //MARK: Property
    
    private var oauthService: OAuthProtocol!
    private var apiHelper: ApiHelper!
    
    init(navigator: Navigator, oauthService: OAuthProtocol, apiHelper: ApiHelper) {
        self.oauthService = oauthService
        self.apiHelper = apiHelper
        super.init(navigator: navigator)
    }
    
    override func onDidLoad() {
        super.onDidLoad()
        
        disposeBag = DisposeBag()
    }
    
    func logout() {
        navigator.viewController?.view.startAnimation(attribute: SpringIndicator.lagreAndCenter)
        oauthService.logout(email: (User.default?.username)!)
            .asObservable()
            .subscribe(onError: { [weak self] err in
                guard let sSelf = self else {
                    return
                }
                sSelf.navigator.showAlert(title: "Error", message: err.localizedDescription, negativeTitle: "OK")
            }){ [weak self] in
                guard let sSelf = self else {
                    return
                }
                sSelf.navigator.viewController?.view.stopAnimation()
                sSelf.navigator.popViewToRoot(animated: true)
            }.disposed(by: disposeBag)
    }
}
