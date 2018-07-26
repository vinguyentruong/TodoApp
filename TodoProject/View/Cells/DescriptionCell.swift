//
//  DescriptionCell.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/18/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

protocol DescriptionCellDelegate: BaseCellDelegate {
    
    func descriptionCell(contentDidEndChange text: String?)
}

class DescriptionCell: BaseTableViewCell {

    @IBOutlet weak var descriptionContentView: CustomTextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionContentView.valueChanged = { [weak self] textView in
            guard let sSelf = self else {
                return
            }
            (sSelf.delegate as? DescriptionCellDelegate)?.descriptionCell(contentDidEndChange: textView.text)
        }
    }
    
    override func configTitle(title: String) {
        titleLabel.text = title
    }
    
    func configure(description: String?) {
        descriptionContentView.text = description
    }
}
