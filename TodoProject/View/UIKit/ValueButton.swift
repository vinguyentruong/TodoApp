//
//  ValueButton.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/18/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import Material

protocol ValueButtonDelegate: class {
    func valueButton(didSelectButton button: ValueButton)
}

class ValueButton: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var button: RaisedButton!
    
    internal var view: UIView!
    internal var tagName: String = ""
    internal var delegate: ValueButtonDelegate? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initalize()
        valueLabel.text = nil
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initalize()
        valueLabel.text = nil
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
    
    @IBAction func buttonAction(_ sender: Any) {
        delegate?.valueButton(didSelectButton: self)
    }
    
}
