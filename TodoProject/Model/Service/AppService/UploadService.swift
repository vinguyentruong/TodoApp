//
//  UploadService.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/23/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

protocol UploadService: class {
    
    func uploadFile(url             : URL,
                    progressHandler : @escaping Request.ProgressHandler,
                    responseHandler : @escaping ResponseHandler)
}
