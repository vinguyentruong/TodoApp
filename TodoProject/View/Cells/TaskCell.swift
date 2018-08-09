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
    func taskCell(cell: TaskCell, didSelectDeleteButton button: UIButton)
}

class TaskCell: TableViewCell {

    // MARK: Property
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    internal var delegate: TaskCellDelegate?
    private var task: Task?
    
    // MARK: Overide methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layoutIfNeeded()
        let shadowPath = UIBezierPath(rect: containerView.bounds)
        containerView.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.4
        containerView.layer.shadowPath = shadowPath.cgPath
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = false
        if task?.rawStatus == Status.inprogess.rawValue, (task?.deadline ?? Date()) < Date() {
            if let index = containerView.layer.sublayers?.index(where: { $0.name == "gradient" }) {
                containerView.layer.sublayers?.remove(at: index)
            }
            containerView.layer.backgroundColor = UIColor.gray.cgColor
            containerView.layer.cornerRadius = 8
        } else {
            containerView.backgroundColor = UIColor.clear
            containerView.setGradientColors(colors: [UIColor.red.withAlphaComponent(0.8),UIColor.orange.withAlphaComponent(0.8)], cornerRadious: 8)
        }
    }
    
    // MARK: Internal methods
    
    internal func configUI(name: String, done: Bool) {
        nameLabel.text = name
        doneButton.isSelected = done
    }
    
    internal func configUI(task: Task) {
        self.task = task
        nameLabel.text = task.name
        dateLabel.text = task.deadline.dateToString(format: DateFormat.hh_mm_aa.name)
        doneButton.isSelected = task.status == .done
    }
    
    // MARK: Actions
    
    @IBAction func checkAction(_ sender: Any) {
//        let button = sender as! UIButton
//        delegate?.taskCell(cell: self, didSelectDoneButton: button)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        let button = sender as! UIButton
        delegate?.taskCell(cell: self, didSelectDeleteButton: button)
    }
}
