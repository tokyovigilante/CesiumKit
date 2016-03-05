//
//  LocalStorage.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 1/03/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

/// Functions to store support files on device
class LocalStorage {
    
    // Singleton
    static let sharedInstance = LocalStorage()
    
    func getDocumentFolder () -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] + "/" + getExecutableName()
    }
    
    func getExecutableName () -> String {
        return NSProcessInfo.processInfo().processName
    }
    
}