//
//  Notification+Extension.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/20/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    internal static let AppTimeout      = Notification.Name("AppTimeout")
    internal static let ThemeDidChange  = Notification.Name("ThemeDidChange")
    internal static let OAuthExpiredEvent = Notification.Name("OAuthExpiredEvent")
    internal static let UploadFile      = Notification.Name("UploadFile")
    internal static let SyncAlbum       = Notification.Name("SyncAlbum")
    internal static let CreateAlbum     = Notification.Name("CreateAlbum")
    internal static let UpdateAlbum     = Notification.Name("UpdateAlbum")
    internal static let DeleteAlbum     = Notification.Name("DeleteAlbum")
    internal static let CreateShareAlbum     = Notification.Name("CreateShareAlbum")
    internal static let UpdateShareAlbum     = Notification.Name("UpdateShareAlbum")
    internal static let DeleteShareAlbum     = Notification.Name("DeleteShareAlbum")
}
