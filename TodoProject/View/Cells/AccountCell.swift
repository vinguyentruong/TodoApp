//
//  AccountCell.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/19/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import Material

protocol AccountCellDelegate: BaseCellDelegate {
    func accountCell(didSelectLogout cell: AccountCell)
    func accountCell(valueNameDidChange textField: UITextField)
}

class AccountCell: BaseTableViewCell {

    //MARK: Property
    
    @IBOutlet weak var nameTextfield: TextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: Overide methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextfield.placeholderAnimation = .hidden
        nameTextfield.placeholder = "Name"
        nameTextfield.detailColor = UIColor.red
        nameTextfield.addTarget(self, action: #selector(nameTextFieldAction), for: .editingChanged)
    }
    
    override func configure(title: String) {
        titleLabel.text = title
    }
    
    func configureUI(name: String) {
        nameTextfield.text = name
    }
    
    //MARK: IB Action
    
    @IBAction func logoutAction(_ sender: Any) {
        (delegate as? AccountCellDelegate)?.accountCell(didSelectLogout: self)
    }
}

extension AccountCell: UITextFieldDelegate {
    
    @objc
    private func nameTextFieldAction() {
        if let text = nameTextfield.text,
            text.count > 50 {
            nameTextfield.text = text.subString(from: 0, offset: 50)
            nameTextfield.detail = "Number of character out of limit"
        } else {
            nameTextfield.detail = nil
            (delegate as? AccountCellDelegate)?.accountCell(valueNameDidChange: nameTextfield)
        }
    }
}


