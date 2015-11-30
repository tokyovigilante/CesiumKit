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
    case Zero
    case One
    case SourceColor
    case OneMinusSourceColor
    case SourceAlpha
    case OneMinusSourceAlpha
    case DestinationColor
    case OneMinusDestinationColor
    case DestinationAlpha
    case OneMinusDestinationAlpha
    case SourceAlphaSaturated
    case BlendColor
    case OneMinusBlendColor
    case BlendAlpha
    case OneMinusBlendAlpha
    
    func toMetal() -> MTLBlendFactor {
        return MTLBlendFactor(rawValue: self.rawValue)!
    }

}
