//
//  ProfileViewController.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/19/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import Material

class ProfileViewController: BaseTodoViewController {

    //MARK: Property
    
    internal var viewModel: ProfileViewModel!
    override var delegate: ViewModelDelegate? {
        return viewModel
    }
    
    @IBOutlet weak var editAvatarButton: UIButton!
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var editButton: RaisedButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var isEditMode = false
    private var itemTitlesTable = ["Options", "Account"]
    private var cellIdentifies = [OptionCell.className, AccountCell.className]
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareUI()
        prepareTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareNavigationBar()
    }
    
    //MARK: IBActions
    
    @IBAction func editAction(_ sender: Any) {
        isEditMode.toggle()
        editAvatarButton.setImage(isEditMode ? #imageLiteral(resourceName: "ic_camera") : nil, for: .normal)
        editAvatarButton.tintColor = .white
        let button = sender as! UIButton
        button.setTitle(isEditMode ? "Save" : "Edit profile", for: .normal) 
        for textField in getTextfield(view: self.view) {
            textField.isEnabled = isEditMode
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
    
    func getTextfield(view: UIView) -> [UITextField] {
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
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: TableView Delegate

extension ProfileViewController: UITableViewDelegate {
    
}

//MARK: TableView Datasource

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemTitlesTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifies[indexPath.row]) as? BaseTableViewCell {
            cell.configTitle(title: itemTitlesTable[indexPath.row])
            (cell as? AccountCell)?.delegate = self
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
}
