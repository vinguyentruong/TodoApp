//
//  HeaderExpandTableView.swift
//  Study
//
//  Created by David Nguyen Truong on 7/4/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

protocol HeaderExpandTableViewDelegate: class {
    func header(_ header: HeaderExpandTableView, toggleSectionArrow toggle: Bool)
}

class HeaderExpandTableView: UIView {
    
    internal lazy var titleLabel = UILabel()
    internal lazy var arrowButton = UIButton()
    
    internal weak var delegate: HeaderExpandTableViewDelegate?
    
    internal var expand: Bool = true
    
    static var identifier: String {
        return String(describing: self)
    }
    
    internal var section: Int = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        
        arrowButton.setTitle("▽", for: .normal)
        arrowButton.addTarget(self, action: #selector(collapseAction(_:)), for: .touchUpInside)
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(arrowButton)
        
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: arrowButton.leftAnchor, constant: 8).isActive = true
        
        arrowButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        arrowButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        arrowButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        arrowButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        backgroundColor = UIColor.gray
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handelTapGeture)))
    }
    
    @objc
    private func handelTapGeture(){
        collapseHandel()
    }
    
    @objc
    private func collapseAction(_ sender: Any) {
        collapseHandel()
    }
    
    private func collapseHandel(){
        expand = !expand
        UIView.animate(withDuration: 0.5) {
            self.arrowButton.layer.setAffineTransform(CGAffineTransform(rotationAngle: self.expand ? 0.0: .pi))
        }
        delegate?.header(self, toggleSectionArrow: expand)
    }
}

extension UIView {
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
    
    static var className: String {
        return String(describing: self)
    }
}
