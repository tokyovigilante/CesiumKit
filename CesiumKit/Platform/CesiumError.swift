//
//  Errors.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 18/06/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

enum CesiumError: Error, CustomDebugStringConvertible {
    
    case invalidProjectionInput
    
    var debugDescription: String {
        switch self {
        case .invalidProjectionInput:
            return "Invalid Cartesian projection point"
        }
    }
    
}
