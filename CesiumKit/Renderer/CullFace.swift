//
//  CullFace.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 17/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

enum CullFace {
    case none
    case front
    case back

    func toMetal() -> MTLCullMode {
        switch self {
        case .none:
            return .none
        case .front:
            return .front
        case .back:
            return .back
        }
    }
}
