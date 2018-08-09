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

    @IBOutlet weak var textCountLabel: UILabel!
    @IBOutlet weak var descriptionContentView: CustomTextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionContentView.valueChanged = { [weak self] textView in
            guard let sSelf = self else {
                return
            }
            sSelf.textCountLabel.text = "\(textView.text.count)/80"
            (sSelf.delegate as? DescriptionCellDelegate)?.descriptionCell(contentDidEndChange: textView.text)
        }
    }
    
    override func configure(title: String, task: Task) {
        titleLabel.text = title
        descriptionContentView.text = task.content
    }
}
