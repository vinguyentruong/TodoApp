//
//  NameCell.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/18/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import Material

protocol NameCellDelegate: BaseCellDelegate {
    func nameCell(nameValueDidEndChange textField: TextField)
}

class NameCell: BaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextfield: TextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextfield.placeholderAnimation = .hidden
        nameTextfield.placeholder = "Name"
        nameTextfield.detailColor = UIColor.red
        nameTextfield.addTarget(self, action: #selector(nameDidEndChange), for: UIControlEvents.editingChanged)
    }
    
    override func configure(title: String, task: Task) {
        titleLabel.text = title
        nameTextfield.text = task.name
    }
}

extension NameCell {
    
    @objc
    private func nameDidEndChange() {
        if let text = nameTextfield.text,
            text.count > 50 {
            nameTextfield.text = text.subString(from: 0, offset: 50)
            nameTextfield.detail = "Number of character out of limit"
        } else {
            nameTextfield.detail = nil
            (delegate as? NameCellDelegate)?.nameCell(nameValueDidEndChange: nameTextfield)
        }
    }
}

