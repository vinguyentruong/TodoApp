//
//  RestApi.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 6/19/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import SwiftyJSON
import Alamofire

class RestService: NSObject {
    
    // MARK: Property
    
    internal let apiHelper: ApiHelper

    internal var defaultHeaders: HTTPHeaders {
        var headers = HTTPHeaders()
        headers["Authorization"] = "Bearer \(OAuthToken.default.accessToken)"
        return headers
    }
    
    // MARK: Constructor
    
    internal init(apiHelper: ApiHelper) {
        self.apiHelper = apiHelper
        
        super.init()
    }
}
