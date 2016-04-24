//
//  BufferSyncState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 24/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

enum BufferSyncState: Int {
    case zero = 0, one = 1, two = 2
    
    static let count = 3
    
    func advance() -> BufferSyncState {
        return BufferSyncState(rawValue: (self.rawValue + 1) % 3)!
    }
}