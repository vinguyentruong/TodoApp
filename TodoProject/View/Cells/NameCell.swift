//
//  NameCell.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/18/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

protocol NameCellDelegate: BaseCellDelegate {
    func nameCell(nameValueDidEndChange text: String?)
}

class NameCell: BaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextfield: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameTextfield.addTarget(self, action: #selector(nameDidEndChange), for: UIControlEvents.editingChanged)
    }
    
    override func configTitle(title: String) {
        titleLabel.text = title
    }
    
    func configure(name: String?) {
        nameTextfield.placeholder = "Name"
        nameTextfield.text = name
        
    }
}

extension NameCell {
    
    @objc
    private func nameDidEndChange() {
        (delegate as? NameCellDelegate)?.nameCell(nameValueDidEndChange: nameTextfield.text)
    }
}

