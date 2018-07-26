//
//  RegisterViewController.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/20/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import Material
import RxSwift

class RegisterViewController: BaseTodoViewController {

    //MARK: Property
    
    override var delegate: ViewModelDelegate? {
        return nil
    }
    
    @IBOutlet weak var confirmPasswordTextfield: TextField!
    @IBOutlet weak var passwordTextfield: TextField!
    @IBOutlet weak var emailTextfield: TextField!
    @IBOutlet weak var nameTextfield: TextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var signupButton: RaisedButton!
    @IBOutlet weak var uploadButtonContainerView: UIView!
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        prepareNavigationBar()
        prepareUI()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    
    //MARK: Overide method
    
    override func bindAction() {
        let disposeBag = DisposeBag()
        nameTextfield
            .rx
            .text
            .asDriver()
            .drive(onNext: { [weak self] text in
                guard let sSelf = self else {
                    return
                }
                if !text!.trimmed.isDisplaynameValid {
                    sSelf.nameTextfield.detail = "Display name is no more than 20 characters"
                } else {
                    sSelf.nameTextfield.detail = nil
                }
            }
            )
            .disposed(by: disposeBag)
        
        emailTextfield
            .rx
            .text
            .asDriver()
            .drive(onNext: { [weak self] text in
                guard let sSelf = self else {
                    return
                }
                if !text!.trimmed.isValidEmail {
                    sSelf.emailTextfield.detail = "Email is invalid"
                } else {
                    sSelf.emailTextfield.detail = nil
                }
                }
            )
            .disposed(by: disposeBag)
        
        passwordTextfield
            .rx
            .text
            .asDriver()
            .drive(onNext: { [weak self] text in
                guard let sSelf = self else {
                    return
                }
                if !text!.trimmed.isPasswordValid {
                    sSelf.passwordTextfield.detail = "Password at least 8 characters includes 0-9, A-Z, a-z"
                } else {
                    sSelf.passwordTextfield.detail = nil
                }
                }
            )
            .disposed(by: disposeBag)
        
        confirmPasswordTextfield
            .rx
            .text
            .asDriver()
            .drive(onNext: { [weak self] text in
                guard let sSelf = self else {
                    return
                }
                if text != sSelf.passwordTextfield.text {
                    sSelf.confirmPasswordTextfield.detail = "Password does not match"
                } else {
                    sSelf.confirmPasswordTextfield.detail = nil
                }
            }
            )
            .disposed(by: disposeBag)
        
        self.disposeBag = disposeBag
        
        nameTextfield.detail = nil
        emailTextfield.detail = nil
        passwordTextfield.detail = nil
    }
    
    //MARK: IBActions
    
    @IBAction func uploadAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = .photoLibrary;
            imag.allowsEditing = false
            present(imag, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        let name = nameTextfield.text!.trimmed
        var isValid = true
        if name.isEmpty {
            nameTextfield.detail = "Required field"
            isValid = false
        } else if !name.isDisplaynameValid {
            nameTextfield.detail = "Display name is no more than 20 characters"
            isValid = false
        } else {
            nameTextfield.detail = nil
        }
        
        let email = emailTextfield.text!.trimmed
        if email.isEmpty {
            emailTextfield.detail = "Required field"
            isValid = false
        } else if !email.isValidEmail {
            emailTextfield.detail = "Email is invalid"
            isValid = false
        } else {
            emailTextfield.detail = nil
        }
        let password = passwordTextfield.text!.trimmed
        if password.isEmpty {
            passwordTextfield.detail = "Required field"
            isValid = false
        } else if !password.isPasswordValid {
            passwordTextfield.detail = "Password at least 8 characters includes 0-9, A-Z, a-z"
            isValid = false
        } else {
            passwordTextfield.detail = nil
        }
        if isValid {
//            viewModel.signUp()
        }
    }
    
}

//MARK: Prepare UI

extension RegisterViewController {
    
    private func prepareNavigationBar() {
        navigationController?.navigationBar.tintColor = .orange
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_left_arrow"), style: .plain, target: self, action: #selector(handelBackAction))
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    private func prepareUI() {
        signupButton.clipsToBounds = true
        signupButton.layer.cornerRadius = signupButton.bounds.height/2
        
        uploadButtonContainerView.clipsToBounds = true
        uploadButtonContainerView.layer.cornerRadius = uploadButtonContainerView.bounds.height/2
        
        nameTextfield.detailColor = .red
        emailTextfield.detailColor = .red
        passwordTextfield.detailColor = .red
        confirmPasswordTextfield.detailColor = .red
    }
}

//MARK: Actions

extension RegisterViewController {
    
    @objc
    private func handelBackAction() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        self.avatarImageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
