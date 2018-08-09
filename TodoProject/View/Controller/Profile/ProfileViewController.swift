//
//  ProfileViewController.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/19/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import Material
import RxSwift

class ProfileViewController: BaseTodoViewController {

    //MARK: Property
    
    internal var viewModel: ProfileViewModel!
    override var delegate: ViewModelDelegate? {
        return viewModel
    }
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var editAvatarButton: UIButton!
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var editButton: RaisedButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var isEditMode = false
    private var cellIdentifies = [OptionCell.className, AccountCell.className]
    private var username: String?
    private var oldPass: String?
    private var newPass: String?
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        disposeBag = DisposeBag()
        
        super.viewDidLoad()

        prepareUI()
        prepareTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.tableHeaderViewSizeToFit()
    }
    
    //MARK: Overide methods
    
    override func bindData() {
        viewModel
            .avatar
            .asDriver()
            .drive(onNext: { [weak self] image in
                guard let sSelf = self else {
                    return
                }
                sSelf.avatarImageView.image = image
            }
        ).disposed(by: disposeBag)
        
        viewModel
            .user
            .asDriver()
            .drive(onNext: { [weak self] user in
                guard let sSelf = self else {
                    return
                }
                sSelf.displayNameLabel.text = user?.displayName
                sSelf.emailLabel.text = user?.username
                sSelf.username = user?.displayName
                sSelf.tableView.reloadData()
            }
        ).disposed(by: disposeBag)
    }
    
    override func bindAction() {
        viewModel
            .logoutSuccess
            .asObservable()
            .subscribe(
                onNext: { value in
                    if value {
                        if
                            let window = AppDelegate.shared().window,
                            let loginView = UIStoryboard.main.getViewController(LoginViewController.self) {
                            UIView.transition(
                                with        : window,
                                duration    : 0.33,
                                options     : .transitionCrossDissolve,
                                animations  : {
                                    window.rootViewController = loginView
                                    window.windowLevel = UIWindowLevelNormal
                            })
                        }
                    }
                }
            ).disposed(by: disposeBag)
        
        viewModel
            .passwordChanged
            .asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let sSelf = self else {
                    return
                }
                if value {
                    sSelf.viewModel.logout()
                }
            }
        ).disposed(by: disposeBag)
    }
    
    //MARK: IBActions
    
    @IBAction func editAction(_ sender: Any) {
        isEditMode.toggle()
        let button = sender as! UIButton
        if isEditMode {
            button.setTitle("Save", for: .normal)
            editAvatarButton.setImage( #imageLiteral(resourceName: "ic_camera"), for: .normal)
            editAvatarButton.tintColor = .white
            cellIdentifies = [OptionCell.className, PasswordCell.className, AccountCell.className]
            tableView.reloadData()
            for textField in getTextfield(view: self.view) {
                textField.isEnabled = isEditMode
            }
        } else {
            saveAction(button: button)
        }
    }
    
    
    private func saveAction(button: UIButton) {
        editAvatarButton.setImage( nil, for: .normal)
        cellIdentifies = [OptionCell.className, AccountCell.className]
        if let name = self.username, let user = self.viewModel.user.value {
            user.displayName = name
            viewModel.navigator.showAlert(title: "Confirm", message: "Are you sure?", negativeTitle: "Ok", positiveTitle: "Cancel", negativeHandler: { [weak self] (_) in
                guard let sSelf = self else {
                    return
                }
                button.setTitle("Edit profile", for: .normal)
                sSelf.viewModel.updateUser(user: user)
                sSelf.tableView.reloadData()
            }) { [weak self] (_) in
                guard let sSelf = self else {
                    return
                }
                button.setTitle("Edit profile", for: .normal)
                sSelf.tableView.reloadData()
            }
        } else {
            self.viewModel.navigator.showAlert(title: "Error", message: "You must fill in all of the fields!", negativeTitle: "Ok")
        }
    }
    
    @IBAction func editAvatarAction(_ sender: Any) {
        if !isEditMode {
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = .photoLibrary;
            imag.allowsEditing = false
            present(imag, animated: true, completion: nil)
        }
    }
    
    private func getTextfield(view: UIView) -> [UITextField] {
        var results = [UITextField]()
        for subview in view.subviews as [UIView] {
            if let textField = subview as? UITextField {
                results += [textField]
            } else {
                results += getTextfield(view: subview)
            }
        }
        return results
    }
}

//MARK: Prepare UI

extension ProfileViewController {
    
    private func prepareNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isTranslucent = false
        title = "Profile"
    }
    
    private func prepareUI() {
        avatarContainerView.clipsToBounds = true
        avatarContainerView.layer.cornerRadius = avatarContainerView.bounds.height/2
        editButton.layer.borderColor = UIColor.orange.cgColor
        editButton.layer.borderWidth = 0.5
        editButton.clipsToBounds = true
        editButton.layer.cornerRadius = editButton.bounds.height/2
    }
    
    private func prepareTableView() {
        tableView.register(OptionCell.nib, forCellReuseIdentifier: OptionCell.className)
        tableView.register(AccountCell.nib, forCellReuseIdentifier: AccountCell.className)
        tableView.register(PasswordCell.nib, forCellReuseIdentifier: PasswordCell.className)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
    }
}

//MARK: TableView Datasource

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellIdentifies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifies[indexPath.row]) as? BaseTableViewCell {
            cell.delegate = self
            if let username = viewModel.user.value?.displayName {
                (cell as? AccountCell)?.configureUI(name: username)
            }
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        self.avatarImageView.image = image
        viewModel.uploadAvatar(image: image)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: AccountCell Delegate

extension ProfileViewController: AccountCellDelegate {
    
    func accountCell(didSelectLogout cell: AccountCell) {
        viewModel.logout()
    }
    
    func accountCell(valueNameDidChange textField: UITextField) {
        username = textField.text
    }
}

extension ProfileViewController: PasswordCellDelegate {
    
    func passwordCell(cell: PasswordCell, didSelectChangeButton button: UIButton) {
        
        if let oldPass = self.oldPass, let newPass = self.newPass {
            viewModel
                .navigator
                .showAlert(
                    title           : "Confirm",
                    message         : "Are you sure?",
                    negativeTitle   : "Ok",
                    positiveTitle   : "Cancel",
                    negativeHandler : { [weak self] (_) in
                        guard let sSelf = self else {
                            return
                        }
                        sSelf.viewModel.changePassword(oldPass: oldPass, newPass: newPass)
                    })
        } else {
            self.viewModel.navigator.showAlert(title            : "Error",
                                               message          : "You must fill in all of the fields!",
                                               negativeTitle    : "Ok")
        }
    }
    
    func passwordCell(cell: PasswordCell, oldPasswordTextDidChange textField: UITextField) {
        oldPass = textField.text
    }
    
    func passwordCell(cell: PasswordCell, newPasswordTextDidChange textField: UITextField) {
        newPass = textField.text
    }
}
