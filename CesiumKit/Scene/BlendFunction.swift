//
//  BlendFunction.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 25/10/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal
/**
* Determines how blending factors are computed.
*
*/

enum BlendFunction: UInt {
    case zero
    case one
    case sourceColor
    case oneMinusSourceColor
    case sourceAlpha
    case oneMinusSourceAlpha
    case destinationColor
    case oneMinusDestinationColor
    case destinationAlpha
    case oneMinusDestinationAlpha
    case sourceAlphaSaturated
    case blendColor
    case oneMinusBlendColor
    case blendAlpha
    case oneMinusBlendAlpha
    
    func toMetal() -> MTLBlendFactor {
        return MTLBlendFactor(rawValue: self.rawValue)!
    }

}
