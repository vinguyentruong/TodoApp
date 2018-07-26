//
//  LoginViewController.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/16/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: BaseTodoViewController {
    
    //MARK: Property
    
    internal var viewModel: LoginViewModel!
    override var delegate: ViewModelDelegate? {
        return viewModel
    }
    
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    private var checked = false

    private var isEnableSignInButton = Variable<Bool>(false)
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        disposeBag = DisposeBag()
        prepareUI()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: Overide method
    
    override func bindAction() {
        usernameTextfield.rx
            .controlEvent(UIControlEvents.editingChanged)
            .subscribe { [weak self] (_) in
                guard let sSelf = self else {
                    return
                }
                sSelf.isEnableSignInButton.value = (sSelf.usernameTextfield.text != "") && (sSelf.passwordTextfield.text != "")
            }.disposed(by: disposeBag)
        
        passwordTextfield.rx
            .controlEvent(UIControlEvents.editingChanged)
            .subscribe { [weak self] (_) in
                guard let sSelf = self else {
                    return
                }
                sSelf.isEnableSignInButton.value = (sSelf.usernameTextfield.text != "") && (sSelf.passwordTextfield.text != "")
        }.disposed(by: disposeBag)
        
        isEnableSignInButton
            .asDriver()
            .drive(onNext: { [weak self] value in
                guard let sSelf = self else {
                    return
                }
                sSelf.signInButton.isEnabled = value
                sSelf.signInButton.backgroundColor = value ? .orange : .lightGray
            }
            ).disposed(by: disposeBag)
        
        viewModel.loginSuccess
            .asDriver()
            .drive(onNext: { [weak self] success in
                guard let sSelf = self else {
                    return
                }
                if success {
                    guard let vc = UIStoryboard.main.getViewController(MainViewController.self) else {
                        return
                    }
                    sSelf.navigationController?.pushViewController(vc, animated: true)
                }
            }
            ).disposed(by: disposeBag)
    }
    
    //MARK: IBAction
    
    @IBAction func checkAction(_ sender: Any) {
        let button = sender as! UIButton
        button.setImage(checked ? #imageLiteral(resourceName: "ic_uncheck") : #imageLiteral(resourceName: "ic_checked"), for: .normal)
        checked.toggle()
    }
    
    @IBAction func signInAction(_ sender: Any) {
        viewModel.login(email: usernameTextfield.text!, password: passwordTextfield.text!)
    }
    
    @IBAction func registerAction(_ sender: Any) {
        //
    }
}

//MARK: Prepare UI

extension LoginViewController {
    
    private func prepareUI() {
        signInButton.isEnabled = false
        signInButton.clipsToBounds = true
        signInButton.layer.cornerRadius = 3
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handelTapGesture)))
    }
}

//MARK: Actions

extension LoginViewController {
    
    @objc
    private func handelTapGesture() {
        self.view.endEditing(false)
    }
}
