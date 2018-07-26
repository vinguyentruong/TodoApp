//
//  TodoCell.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/13/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

class TodoCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var createDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    internal func config(name: String, thumbnail: UIImage, create: Date){
        nameLabel.text = name
        thumbnailImage.image = thumbnail
        createDateLabel.text = create.dateToString(format: DateFormatter.MMM_dd_yyyy_HH_mm_aa)
    }

}
