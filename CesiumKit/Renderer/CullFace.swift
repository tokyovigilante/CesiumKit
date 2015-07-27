//
//  CullFace.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 17/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

enum CullFace {
    case None
    case Front
    case Back
    
    func toMetal() -> MTLCullMode {
        switch self {
        case .None:
            return .None
        case .Front:
            return .Front
        case .Back:
            return .Back
        }
    }
}