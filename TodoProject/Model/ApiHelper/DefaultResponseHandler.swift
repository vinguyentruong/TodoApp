//
//  DefaultHandlerProtocol.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 6/19/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Alamofire
import SwiftyJSON

public class DefaultResponseHandler: NSObject {
    
}

extension DefaultResponseHandler: ResponseHandlerProtocol {
    
    public func onResponse(_ response: DataResponse<Any>, responseHandler: ResponseHandler?) {
        switch response.result {
        case .success(let value):
            let json = JSON(value)
            if json["error"].exists() {
                let code = json["error"]["code"].intValue
                let message = json["error"]["message"].stringValue
                responseHandler?(nil, NSError(domain    : "",
                                              code      : code,
                                              userInfo  : [NSLocalizedDescriptionKey: message]))
                return
            }
            responseHandler?(json, nil)
        case .failure:
            if let data = response.data {
                let json = JSON(data)
                print(json)
                if json["error"].exists() {
                    let code = json["error"]["code"].intValue
                    let message = json["error"]["message"].stringValue
                    responseHandler?(nil, NSError(domain    : "",
                                                  code      : code,
                                                  userInfo  : [NSLocalizedDescriptionKey: message]))
                    return
                }
            }
            responseHandler?(nil, NSError(domain    : "",
                                          code      : 0,
                                          userInfo  : [NSLocalizedDescriptionKey: "something_went_wrong_error".localized()]))

        }
    }
}
