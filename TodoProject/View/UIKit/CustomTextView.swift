//
//  CustomTextView.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/18/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextView: UITextView {
    
    @IBInspectable
    internal var placeholder: String = "" {
        didSet {
            text = placeholder
            textColor = .lightGray
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.delegate = self
    }
    
    internal var valueChanged: ((UITextView) -> ())?
}

extension CustomTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            valueChanged?(self)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = .lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text, text.count > 80 {
            textView.text = text.subString(from: 0, offset: 80)
        }
        valueChanged?(self)
    }
}
