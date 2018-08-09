//
//  DateTimeCell.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/18/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

protocol DateTimeCellDelegate: BaseCellDelegate {
    func dateTimeCell(didSelectDateButton button: ValueButton)
    func dateTimeCell(didSelectTimeButton button: ValueButton)
}

class DateTimeCell: BaseTableViewCell {

    //MARK: Property
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateButton: ValueButton!
    @IBOutlet weak var timeButton: ValueButton!
    @IBOutlet weak var alertButton: ValueButton!
    
    //MARK: overide methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateButton.titleLabel.text = "Date"
        dateButton.tagName = "dateButton"
        dateButton.delegate = self
        timeButton.titleLabel.text = "Time"
        timeButton.tagName = "timeButton"
        timeButton.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func configure(title: String) {
        self.titleLabel.text = title
        
    }
    
    override func configure(title: String, task: Task) {
        self.titleLabel.text = title
        dateButton.valueLabel.text = task.deadline.dateToString(format: DateFormatter.yyyy_MM_dd)
        timeButton.valueLabel.text = task.deadline.dateToString(format: DateFormatter.hh_mm_aa)
    }
    
    internal func configure(defaultDate: Date, defaultTime: Date) {
        dateButton.valueLabel.text = defaultDate.dateToString(format: DateFormatter.yyyy_MM_dd)
        timeButton.valueLabel.text = defaultTime.dateToString(format: DateFormatter.hh_mm_aa)
    }
    
}

extension DateTimeCell: ValueButtonDelegate {
    func valueButton(didSelectButton button: ValueButton) {
        if button.tagName == "dateButton" {
            (delegate as? DateTimeCellDelegate)?.dateTimeCell(didSelectDateButton: button)
        } else if button.tagName == "timeButton" {
            (delegate as? DateTimeCellDelegate)?.dateTimeCell(didSelectTimeButton: button)
        }
    }
}
