//
//  BaseTableViewCell.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/18/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

protocol BaseCellDelegate: class {
    
}

class BaseTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    internal weak var delegate: BaseCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layoutIfNeeded()
        let shadowPath = UIBezierPath(rect: containerView.bounds)
        containerView.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowPath = shadowPath.cgPath
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = false
        containerView.layer.cornerRadius = 8
    }
    
    internal func configure(title: String, task: Task) {

    }
    internal func configure(title: String) {
        
    }

}
