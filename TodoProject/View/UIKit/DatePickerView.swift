//
//  DatePickerView.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/18/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

typealias DatePickerViewDoneHandler = (DatePickerView, Date) -> ()
typealias DatePickerViewCancelHandler = (DatePickerView) -> ()

class DatePickerView: UIView {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    internal var view: UIView!
    internal var doneHandler: DatePickerViewDoneHandler?
    internal var cancelHandler: DatePickerViewCancelHandler?
    private var showed = false
    
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
    
    internal static func show(type          : UIDatePickerMode,
                              title         : String,
                              doneHandler   : @escaping DatePickerViewDoneHandler,
                              cancelHander  : @escaping DatePickerViewCancelHandler) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        UIApplication.topViewController()?.view.endEditing(true)
        let datePickerView = DatePickerView()
        window.addSubview(datePickerView)
        datePickerView.datePicker.datePickerMode = type
        datePickerView.navigationBar.topItem?.title = title
        datePickerView.backgroundView.backgroundColor = UIColor.black
        datePickerView.backgroundView.alpha = 0
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        datePickerView.leftAnchor.constraint(equalTo: window.leftAnchor).isActive = true
        datePickerView.rightAnchor.constraint(equalTo: window.rightAnchor).isActive = true
        datePickerView.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
        datePickerView.heightAnchor.constraint(equalTo: window.heightAnchor).isActive = true
        datePickerView.pickerView.transform = CGAffineTransform(translationX: 0, y: 250)
        
        datePickerView.cancelHandler = { [weak datePickerView] _ in
            guard let sSelf = datePickerView else {
                return
            }
            UIView.animate(withDuration: 0.33, animations: {
                sSelf.pickerView.transform = CGAffineTransform(translationX: 0, y: 250)
                sSelf.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
            }) { (_) in
                sSelf.removeFromSuperview()
                cancelHander(sSelf)
            }
        }
        datePickerView.doneHandler = { [weak datePickerView] view , date in
            guard let sSelf = datePickerView else {
                return
            }
            UIView.animate(withDuration: 0.33, animations: {
                sSelf.pickerView.transform = CGAffineTransform(translationX: 0, y: 250)
                sSelf.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
            }) { (_) in
                sSelf.removeFromSuperview()
                doneHandler(view, date)
            }
        }
        UIView.animate(withDuration: 0.33) {
            datePickerView.pickerView.transform = CGAffineTransform.identity
            datePickerView.backgroundView.alpha = 0.5
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
          cancelHandler?(self)
    }
    
    @IBAction func doneAction(_ sender: Any) {
          doneHandler?(self, self.datePicker.date)
    }
}
