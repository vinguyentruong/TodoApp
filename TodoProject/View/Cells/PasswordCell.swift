//
//  PasswordCell.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/27/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import Material

protocol PasswordCellDelegate: BaseCellDelegate {
    func passwordCell(cell: PasswordCell, didSelectChangeButton button: UIButton)
    func passwordCell(cell: PasswordCell, oldPasswordTextDidChange textField: UITextField)
    func passwordCell(cell: PasswordCell, newPasswordTextDidChange textField: UITextField)
}

class PasswordCell: BaseTableViewCell {

    @IBOutlet weak var eyeNewPassButton: UIButton!
    @IBOutlet weak var eyeOldPassButton: UIButton!
    @IBOutlet weak var newPasswordTextfield: TextField!
    @IBOutlet weak var oldPasswordTextfield: TextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        newPasswordTextfield.placeholderAnimation = .hidden
        newPasswordTextfield.detailColor = UIColor.red
        oldPasswordTextfield.placeholderAnimation = .hidden
        oldPasswordTextfield.detailColor = UIColor.red
        eyeOldPassButton.setImage(#imageLiteral(resourceName: "ic_eye"), for: .normal)
        eyeOldPassButton.addTarget(self, action: #selector(handleReleaseEventOldPassword(sender:)), for: UIControlEvents.touchUpOutside)
        eyeOldPassButton.addTarget(self, action: #selector(handleReleaseEventOldPassword(sender:)), for: UIControlEvents.touchUpInside)
        eyeOldPassButton.addTarget(self, action: #selector(handleTouchDownEventOldPassword(sender:)), for: UIControlEvents.touchDown)
        
        eyeNewPassButton.setImage(#imageLiteral(resourceName: "ic_eye"), for: .normal)
        eyeNewPassButton.addTarget(self, action: #selector(handleReleaseEventNewPassword(sender:)), for: UIControlEvents.touchUpOutside)
        eyeNewPassButton.addTarget(self, action: #selector(handleReleaseEventNewPassword(sender:)), for: UIControlEvents.touchUpInside)
        eyeNewPassButton.addTarget(self, action: #selector(handleTouchDownEventNewPassword(sender:)), for: UIControlEvents.touchDown)
        
        oldPasswordTextfield.addTarget(self, action: #selector(oldPasswordAction), for: .editingChanged)
        newPasswordTextfield.addTarget(self, action: #selector(newPasswordAction), for: .editingChanged)
    }
    
    override func configure(title: String) {
        //
    }
    
    @IBAction func changePasswordAction(_ sender: Any) {
        let button = sender as? UIButton
        if let text = newPasswordTextfield.text, !text.trimmed.isPasswordValid {
            newPasswordTextfield.detail = "Password at least 8 characters includes 0-9, A-Z, a-z"
        } else {
            newPasswordTextfield.detail = nil
            (delegate as? PasswordCellDelegate)?.passwordCell(cell: self, didSelectChangeButton: button!)
        }
    }
}

extension PasswordCell {
    
    @objc
    private func handleReleaseEventOldPassword(sender: UIButton) {
        sender.setImage(#imageLiteral(resourceName: "ic_eye"), for: .normal)
        oldPasswordTextfield.isSecureTextEntry = true
    }
    
    @objc
    private func handleReleaseEventNewPassword(sender: UIButton) {
        sender.setImage(#imageLiteral(resourceName: "ic_eye"), for: .normal)
        newPasswordTextfield.isSecureTextEntry = true
    }
    
    @objc
    private func handleTouchDownEventOldPassword(sender: UIButton) {
        sender.setImage(#imageLiteral(resourceName: "ic_eye_enable"), for: .normal)
        oldPasswordTextfield.isSecureTextEntry = false
    }
    
    @objc
    private func handleTouchDownEventNewPassword(sender: UIButton) {
        sender.setImage(#imageLiteral(resourceName: "ic_eye_enable"), for: .normal)
        newPasswordTextfield.isSecureTextEntry = false
    }
    
    @objc
    private func oldPasswordAction() {
        (delegate as? PasswordCellDelegate)?.passwordCell(cell: self, oldPasswordTextDidChange: oldPasswordTextfield)
    }
    
    @objc
    private func newPasswordAction() {
        if let text = newPasswordTextfield.text, !text.trimmed.isPasswordValid {
            newPasswordTextfield.detail = "Password at least 8 characters includes 0-9, A-Z, a-z"
        } else {
            newPasswordTextfield.detail = nil
            (delegate as? PasswordCellDelegate)?.passwordCell(cell: self, newPasswordTextDidChange: newPasswordTextfield)
        }
    }
}
