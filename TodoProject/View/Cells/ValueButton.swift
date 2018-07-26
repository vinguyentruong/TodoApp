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
    
    internal let delegate: ValueButtonDelegate!
    
    
}
