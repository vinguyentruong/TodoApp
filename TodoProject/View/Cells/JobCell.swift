//
//  JobCell.swift
//  Study
//
//  Created by David Nguyen Truong on 7/3/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

class JobCell: UITableViewCell {

    //MARK: properties
    @IBOutlet weak var jobName: UILabel!
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    //MARK: overide method
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: internal method
    
    internal func configure(job: JobModel){
        jobName.text = job.name
    }

}
