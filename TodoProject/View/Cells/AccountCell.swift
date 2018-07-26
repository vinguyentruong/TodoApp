//
//  AccountCell.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/19/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

protocol AccountCellDelegate: BaseCellDelegate {
    func accountCell(didSelectLogout cell: AccountCell)
}

class AccountCell: BaseTableViewCell {

    //MARK: Property
    
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    //MARK: Overide methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        eyeButton.setImage(#imageLiteral(resourceName: "ic_eye"), for: .normal)
        eyeButton.addTarget(self, action: #selector(handleReleaseEvent(event:)), for: UIControlEvents.touchUpOutside)
        eyeButton.addTarget(self, action: #selector(handleReleaseEvent(event:)), for: UIControlEvents.touchUpInside)
        eyeButton.addTarget(self, action: #selector(handleTouchDownEvent(event:)), for: UIControlEvents.touchDown)
    }

    override func configTitle(title: String) {
        titleLabel.text = title
    }
    
    //MARK: IB Action
    
    @IBAction func logoutAction(_ sender: Any) {
        (delegate as? AccountCellDelegate)?.accountCell(didSelectLogout: self)
    }
}

//MARK: Actions

extension AccountCell {
    
    @objc
    private func handleReleaseEvent(event: UIControlEvents) {
        eyeButton.setImage(#imageLiteral(resourceName: "ic_eye"), for: .normal)
        passwordTextfield.isSecureTextEntry = true
    }
    
    @objc
    private func handleTouchDownEvent(event: UIControlEvents) {
        eyeButton.setImage(#imageLiteral(resourceName: "ic_eye_enable"), for: .normal)
        passwordTextfield.isSecureTextEntry = false
    }
}
