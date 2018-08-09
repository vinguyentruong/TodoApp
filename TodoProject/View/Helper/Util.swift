//
//  Util.swift
//  Scan and Translate Assistant
//
//  Created by Bá Anh Nguyễn on 3/8/17.
//  Copyright © 2017 Bá Anh Nguyễn. All rights reserved.
//

import Foundation
import AVFoundation
import SystemConfiguration
import UIKit

class Util {
    
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    static func sizeString(sizeInByte: Int64) -> String {
        return ByteCountFormatter.string(fromByteCount: sizeInByte, countStyle: .file)
    }
    
    static func sizeString(sizeInByte: UInt64) -> String {
        if sizeInByte > UInt64(Int64.max) {
            print("WARNING: UInt64 > Int64 conversion is not safe")
        }
        return sizeString(sizeInByte: Int64(sizeInByte))
    }
    
    static func freeSpaceInBytes() -> Int64 {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
            else {
                return 0
        }
        return freeSize.int64Value
    }
    
    static func applicationFolderURL() -> URL {
        if let folderPath = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            return URL(fileURLWithPath: folderPath.path, isDirectory: true)
        }
        fatalError()
    }
    
    static func filePath(name: String) -> String {
        let path = self.applicationFolderURL().path + "/" + name
        return path
    }
    
    static func randomNumber() -> Int {
        let randomNum:UInt32 = arc4random_uniform(9000) + 1000 // range is 1000 to 9999
        return Int(randomNum)
    }
}

