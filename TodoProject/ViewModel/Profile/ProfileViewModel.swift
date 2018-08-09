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
import Kingfisher

class ProfileViewModel: BaseViewModel {
    
    //MARK: Property

    private var oauthService: OAuthProtocol!
    private var uploadService: UploadService!
    private var appService: TodoAppService!
    internal var user = Variable<User?>(nil)
    internal var inprogress = Variable<Bool>(false)
    internal var logoutSuccess = Variable<Bool>(false)
    internal var avatar = Variable<UIImage>(#imageLiteral(resourceName: "image_avatar"))
    internal var passwordChanged = Variable<Bool>(false)
    
    // MARK: Construction
    
    init(navigator      : Navigator,
         oauthService   : OAuthProtocol,
         appService     : TodoAppService,
         uploadService  : UploadService) {
        self.uploadService = uploadService
        self.oauthService = oauthService
        self.appService = appService
        super.init(navigator: navigator)
    }
    
    // MARK: Lifecycle
    
    override func onDidLoad() {
        super.onDidLoad()
        
        disposeBag = DisposeBag()
        if let user = User.default {
            self.user.value = user
        }
        getUser()
        getAvatar { [weak self] (image) in
            guard let sSelf = self else {
                return
            }
            sSelf.avatar.value = image
        }
    }
    
    // MARK: Internal methods
    
    internal func logout() {
        logoutSuccess.value = false
        navigator
            .viewController?
            .view
            .startAnimation(attribute: SpringIndicator.lagreAndCenter)
        oauthService
            .logout()
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(
                onNext: { [weak self] success in
                    guard let sSelf = self else {
                        return
                    }
                    if success {
                        User.default = nil
                        sSelf.navigator
                            .viewController?
                            .view
                            .stopAnimation()
                        sSelf.logoutSuccess.value = true
                    }
                },
                onError: { [weak self] err in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.showError(error: err)
                }
            ).disposed(by: disposeBag)
    }
    
    internal func getUser() {
        inprogress.value = true
        appService
            .getUser()
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(
                onNext: { [weak self] user in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.user.value = user
                    sSelf.inprogress.value = false
                },
                onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.inprogress.value = false
                    sSelf.showError(error: error)
                }
            ).disposed(by: disposeBag)
    }
    
    internal func changePassword(oldPass: String, newPass: String) {
        passwordChanged.value = false
        appService
            .changePassword(oldPassword: oldPass, newPassword: newPass)
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(
                onNext: { [weak self] value in
                    guard let sSelf = self else {
                        return
                    }
                    if value {
                        sSelf.navigator.showAlert(title        : "Success",
                                                  message      : "Change password successful!",
                                                  negativeTitle: "OK") {_ in sSelf.passwordChanged.value = true }
                        User.default = nil
                    }
                },
                onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.showError(error: error)
                }
            ).disposed(by: disposeBag)
    }
    
    internal func updateUser(user: User) {
        user.avatar = User.default?.avatar
        appService
            .updateUser(user)
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(
                onNext: { [weak self] user in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.user.value = user
                },
                onError: { [weak self] error in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.showError(error: error)
                }
            ).disposed(by: disposeBag)
    }
    
    func getAvatar(completion: @escaping (UIImage)->()) {
        guard
            let path = User.default?.avatar,
            let url = URL(string: "\(Configuration.BaseUrl)/api/users/avatar/\(path)") else {
            completion(#imageLiteral(resourceName: "image_avatar"))
            return
        }
        
        let modifier = AnyModifier { request in
            var r = request
            r.setValue("Bearer \(OAuthToken.default.accessToken)", forHTTPHeaderField: "Authorization")
            return r
        }
        
        KingfisherManager.shared
            .retrieveImage(
                with            : url,
                options         : [.requestModifier(modifier)],
                progressBlock   : nil) { (image, _, _, _) in
                    completion(image ?? #imageLiteral(resourceName: "image_avatar"))
                }
    }
    
    internal func uploadAvatar(image: UIImage) {
        let size = Double(min(image.width, image.height))
        let centerCropImage = image.centerCrop(width: size, height: size)
        guard let scaleImage = centerCropImage.resizeImage(targetSize: CGSize(width: 600, height: 600)),
            let compressImage = UIImageJPEGRepresentation(scaleImage, 0.7) else {
            return
        }
        let fileName = "IMG_\(Date().timeIntervalSince1970).png"
        let newUrl = FileManager
                        .default
                        .saveImage(from: compressImage, name: fileName)
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
                sSelf.showError(error: err)
            }
            if let error = error {
                sSelf.showError(error: error)
            } else {
                guard let json = json?["data"]  else {
                    return
                }
                let imageUrl = json["newName"].stringValue
                let user = User.default
                user?.avatar = imageUrl
                User.default = user
                sSelf.navigator.showAlert(title         : "Upload successful!",
                                          message       : "",
                                          negativeTitle : "Ok")
            }
        }
    }
    
}
