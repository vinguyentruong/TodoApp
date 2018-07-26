//
//  TaskCell.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/16/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import Material

protocol TaskCellDelegate {
    func taskCell(cell: TaskCell, didSelectDoneButton button: UIButton)
}

class TaskCell: TableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    internal var delegate: TaskCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layoutIfNeeded()
        containerView.backgroundColor = UIColor.clear
        
        let shadowPath = UIBezierPath(rect: containerView.bounds)
        containerView.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.4
        containerView.layer.shadowPath = shadowPath.cgPath
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = false
        containerView.setGradientColors(colors: [UIColor.red.withAlphaComponent(0.8),UIColor.orange.withAlphaComponent(0.8)], cornerRadious: 8)
    }
    
    internal func configUI(name: String, done: Bool) {
        nameLabel.text = name
        doneButton.isSelected = done
    }
    
    internal func configUI(task: Task) {
        nameLabel.text = task.name
        doneButton.isSelected = task.done
    }
    
    @IBAction func checkAction(_ sender: Any) {
        let button = sender as! UIButton
        delegate?.taskCell(cell: self, didSelectDoneButton: button)
    }
}
