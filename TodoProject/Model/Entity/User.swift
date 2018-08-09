//
//  User.swift
//  KeepSafe
//
//  Created by Tran Van Tuat on 7/2/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import SwiftyJSON

enum UserRole: String {
    
    case admin = "admin"
    case normal = "normal"
}

class User: NSObject {
    
    // MARK: Property

    internal var id: String = ""
    internal var displayName: String = ""
    internal var username: String = ""
    internal var role: UserRole = UserRole.normal
    internal var avatar: String?
    internal var createdAt: Date?
    internal var updatedAt: Date?
    internal var deletedAt: Date?
    internal var logined = false
    
    private static var _default: User?
    
    internal static var `default`: User? {
        get {
            if _default == nil {
                if let data = UserDefaults.standard.dictionary(forKey: "user") {
                    _default = User(json: JSON(data))
                }
            }
            return _default
        }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value.toDictionary(), forKey: "user")
            } else {
                UserDefaults.standard.removeObject(forKey: "user")
            }
            _default = newValue
        }
    }
    
    // MARK: Construction
    
    internal init(json: JSON) {
        super.init()
        
        id          = json["id"].stringValue
        createdAt   = json["createdAt"].dateTime
        updatedAt   = json["updatedAt"].dateTime
        deletedAt   = json["deletedAt"].dateTime
        avatar      = json["avatar"].stringValue
        displayName = json["displayName"].stringValue
        username    = json["username"].stringValue
        role        = UserRole(rawValue: json["role"].stringValue) ?? .normal
        logined     = json["logined"].bool ?? false
    }
    
    // MARK: Internal methods
    
    internal func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary["id"]          = id
        dictionary["displayName"] = displayName
        dictionary["username"]    = username
        dictionary["avatar"]      = avatar
        dictionary["role"]        = role.rawValue
        dictionary["createdAt"]   = createdAt
        dictionary["updatedAt"]   = updatedAt
        dictionary["deletedAt"]   = deletedAt
        dictionary["logined"]     = logined
        return dictionary
    }
}
