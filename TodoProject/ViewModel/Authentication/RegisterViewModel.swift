//
//  RegisterViewModel.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/23/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import SpringIndicator

class RegisterViewModel: BaseViewModel {
    
    //MARK: Property
    
    private let oauthService: OAuthProtocol!
    private let uploadService: UploadService!
    private var imageURL: String? = nil
    internal var registerSuccess = Variable<Bool>(false)

    
    //MARK: Construction
    
    init(navigator: Navigator, oauthService: OAuthProtocol, uploadService: UploadService) {
        self.oauthService = oauthService
        self.uploadService = uploadService
        super.init(navigator: navigator)
    }
    
    //MARK: Overide methods
    
    override func onDidLoad() {
        super.onDidLoad()
        
        disposeBag = DisposeBag()
    }
    
    //MARK: Internal methods
    
    internal func signUp(displayName: String, email: String, password: String) {
        navigator.viewController?.view.startAnimation(attribute: SpringIndicator.lagreAndCenter)
        navigator.beginIgnoringEvent()
        oauthService.resgister(displayName: displayName,
                               email: email,
                               password: password,
                               imageURL: imageURL)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] user in
                    guard let sSelf = self else {
                        return
                    }
                    User.default = user
                    sSelf.registerSuccess.value = true
                    sSelf.navigator.viewController?.view.stopAnimation()
                    sSelf.navigator.endIgnoringEvent()
                },
                onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.registerSuccess.value = false
                    sSelf.navigator.endIgnoringEvent()
                    sSelf.navigator.viewController?.view.stopAnimation()
                    sSelf.navigator.showAlert(title: "Error",
                                              message: error.localizedDescription,
                                              negativeTitle: "Ok")
                }
        ).disposed(by: disposeBag)
    }
    
    internal func uploadAvatar(image: UIImage) {
        let fileName = "IMG_\(Date().timeIntervalSince1970).png"
        let newUrl = FileManager.default.saveImage(from: image, name: fileName)
        guard let url = newUrl else {
            return
        }
        uploadService.uploadFile(url: url, progressHandler: { (progress) in
            //handle progress
        }) { [weak self] (json, error) in
            guard let sSelf = self else {
                return
            }
            do {
                try FileManager.default.removeItem(at: url)
            } catch let err as NSError {
                sSelf.navigator.showAlert(title: "Error", message: err.localizedDescription, negativeTitle: "Ok")
            }
            if let error = error {
                sSelf.navigator.showAlert(title: "Error", message: error.localizedDescription, negativeTitle: "Ok")
            } else {
                guard let json = json?["data"]  else {
                    return
                }
                let imageUrl = json["newName"].stringValue
                print("newName \(imageUrl)")
                self?.imageURL = imageUrl
                sSelf.navigator.showAlert(title: "Upload successful!", message: "", negativeTitle: "Ok")
            }
        }
    }
}
