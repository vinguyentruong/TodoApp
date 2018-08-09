//
//  OptionCell.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/19/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

class OptionCell: BaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var themeButton: ValueButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        themeButton.titleLabel.text = "Theme"
        themeButton.valueLabel.text = "Light"
    }
    
    override func configure(title: String) {
        titleLabel.text = title
    }
}
