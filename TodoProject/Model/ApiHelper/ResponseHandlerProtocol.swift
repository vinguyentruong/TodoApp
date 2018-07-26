//
//  ResponseHandlerProtocol.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 6/19/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Alamofire
import SwiftyJSON

public protocol ResponseHandlerProtocol {
    
    func onResponse(_ response: DataResponse<Any>, responseHandler: ResponseHandler?)
}
