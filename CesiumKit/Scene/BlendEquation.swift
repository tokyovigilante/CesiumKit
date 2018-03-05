//
//  BlendEquation.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 25/10/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

/**
* Determines how two pixels' values are combined.
*
* @namespace
* @alias BlendEquation
*/
enum BlendEquation: UInt {
    /**
    * 0x8006.  Pixel values are added componentwise.  This is used in additive blending for translucency.
    *
    * @type {Number}
    * @constant
    */
    case add // WebGL: FUNC_ADD

    /**
    * 0x800A.  Pixel values are subtracted componentwise (source - destination).  This is used in alpha blending for translucency.
    *
    * @type {Number}
    * @constant
    */
    case subtract // WebGL: FUNC_SUBTRACT

    /**
    * 0x800B.  Pixel values are subtracted componentwise (destination - source).
    *
    * @type {Number}
    * @constant
    */
    case reverseSubtract // WebGL: FUNC_REVERSE_SUBTRACT

    case min
    case max

    // No min and max like in ColladaFX GLES2 profile

    func toMetal() -> MTLBlendOperation {
        return MTLBlendOperation(rawValue: self.rawValue)!
    }
}

