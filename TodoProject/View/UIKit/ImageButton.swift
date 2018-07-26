//
//  ImageButton.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/17/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import Material

class ImageButton: RaisedButton {
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var frame = super.imageRect(forContentRect: contentRect)
        frame.origin.x = contentRect.maxX - frame.width - imageEdgeInsets.right + imageEdgeInsets.left
        return frame
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var frame = super.titleRect(forContentRect: contentRect)
        frame.origin.x = frame.minX - imageRect(forContentRect: contentRect).width
        return frame
    }
}
