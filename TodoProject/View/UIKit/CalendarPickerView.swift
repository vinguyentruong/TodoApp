//
//  CalendarPickerView.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/27/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

protocol CalendarPickerViewDelegate: class {
    func calendarPickerView(picker: CalendarPickerView, dateDidChange date: Date)
}

class CalendarPickerView: UIView {

    @IBOutlet weak var dateLabel: UILabel!
    internal weak var delegate: CalendarPickerViewDelegate?
    internal var view: UIView!
    internal var currentDate = Date() {
        didSet {
            dateLabel.text = currentDate.dateToString(format: DateFormat.yyyy_MM_dd.name)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initalize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initalize()
    }
    
    // MARK: Private method
    
    private func initalize() {
        view = loadViewFromNib()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        addConstraint(NSLayoutConstraint(
            item        : view,
            attribute   : .top,
            relatedBy   : .equal,
            toItem      : self,
            attribute   : .top,
            multiplier  : 1.0,
            constant    : 0
        ))
        addConstraint(NSLayoutConstraint(
            item        : view,
            attribute   : .bottom,
            relatedBy   : .equal,
            toItem      : self,
            attribute   : .bottom,
            multiplier  : 1.0,
            constant    : 0
        ))
        addConstraint(NSLayoutConstraint(
            item        : view,
            attribute   : .leading,
            relatedBy   : .equal,
            toItem      : self,
            attribute   : .leading,
            multiplier  : 1.0,
            constant    : 0
        ))
        addConstraint(NSLayoutConstraint(
            item        : view,
            attribute   : .trailing,
            relatedBy   : .equal,
            toItem      : self,
            attribute   : .trailing,
            multiplier  : 1.0,
            constant    : 0
        ))
    }
    
    @IBAction func previousAction(_ sender: Any) {
        var dayComp = DateComponents()
        dayComp.day = -1
        guard let date = Calendar.current.date(byAdding: dayComp, to: currentDate) else {
            return
        }
        currentDate = date
        delegate?.calendarPickerView(picker: self, dateDidChange: currentDate)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        var dayComp = DateComponents()
        dayComp.day = 1
        guard let date = Calendar.current.date(byAdding: dayComp, to: currentDate) else {
            return
        }
        currentDate = date
        delegate?.calendarPickerView(picker: self, dateDidChange: currentDate)
    }
    
    @IBAction func showDatePickerAction(_ sender: Any) {
        DatePickerView.show(type: .date, title: "Date", doneHandler: { [weak self] (datePicker, date) in
            guard let sSelf = self else {
                return
            }
            sSelf.currentDate = date
            sSelf.dateLabel.text = date.dateToString(format: DateFormat.yyyy_MM_dd.name)
            sSelf.delegate?.calendarPickerView(picker: sSelf, dateDidChange: date)
        }) { (datePicker) in
            //
        }
    }
}
