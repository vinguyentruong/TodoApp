//
//  Notification+Extension.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/20/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation

extension Notification.Name {
    internal static let OAuthExpiredEvent   = Notification.Name("OAuthExpiredEvent")
    internal static let CreateTask          = Notification.Name("CreateTask")
    internal static let UpdateTask          = Notification.Name("UpdateTask")
    internal static let DeleteTask          = Notification.Name("DeleteTask")
}
