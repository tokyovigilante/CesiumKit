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

    func getAppSupportURL () -> URL {
        #if os(OSX)
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent(getExecutableName())
        #elseif os(iOS)
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        #endif
    }

    func getExecutableName () -> String {
        return ProcessInfo.processInfo.processName
    }

}
