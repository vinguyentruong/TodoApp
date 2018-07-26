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
    
    internal var date: Date = Date() {
        didSet {
            dateButton.valueLabel.text = date.dateToString(format: DateFormatter.yyyy_MM_dd)
        }
    }
    
    internal var time: Date = Date() {
        didSet {
            timeButton.valueLabel.text = date.dateToString(format: DateFormatter.hh_mm_aa)
        }
    }
    
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
    
    override func configTitle(title: String) {
        titleLabel.text = title
    }
    
    internal func configure(defaultDate: Date?, defaultTime: Date?) {
        if let date = defaultTime, let time = defaultTime {
            self.date = date
            self.time = time
        }
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
