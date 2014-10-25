//
//  BlendFunction.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 25/10/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES
/**
* Determines how blending factors are computed.
*
* @namespace
* @alias BlendFunction
*/
enum BlendFunction {
    /**
    * 0.  The blend factor is zero.
    *
    * @type {Number}
    * @constant
    */
    case Zero,
    
    /**
    * 1.  The blend factor is one.
    *
    * @type {Number}
    * @constant
    */
    One,
    
    /**
    * 0x0300.  The blend factor is the source color.
    *
    * @type {Number}
    * @constant
    */
    SourceColor, // WebGL: SRC_COLOR
    
    /**
    * 0x0301.  The blend factor is one minus the source color.
    *
    * @type {Number}
    * @constant
    */
    OneMinusSourceColor, // WebGL: ONE_MINUS_SRC_COLOR
    
    /**
    * 0x0306.  The blend factor is the destination color.
    *
    * @type {Number}
    * @constant
    */
    DestinationColor, // WebGL: DEST_COLOR
    
    /**
    * 0x0307.  The blend factor is one minus the destination color.
    *
    * @type {Number}
    * @constant
    */
    OneMinusDestinationColor, // WebGL: ONE_MINUS_DEST_COLOR
    
    /**
    * 0x0302.  The blend factor is the source alpha.
    *
    * @type {Number}
    * @constant
    */
    SourceAlpha, // WebGL: SRC_ALPHA
    
    /**
    * 0x0303.  The blend factor is one minus the source alpha.
    *
    * @type {Number}
    * @constant
    */
    OneMinusSourceAlpha, // WebGL: ONE_MINUS_SRC_ALPHA
    
    /**
    * 0x0304.  The blend factor is the destination alpha.
    *
    * @type {Number}
    * @constant
    */
    DestinationAlpha, // WebGL: DST_ALPHA
    
    /**
    * 0x0305.  The blend factor is one minus the destination alpha.
    *
    * @type {Number}
    * @constant
    */
    OneMinusDestinationAlpha, // WebGL: ONE_MINUS_DST_ALPHA
    
    /**
    * 0x8001.  The blend factor is the constant color.
    *
    * @type {Number}
    * @constant
    */
    ConstantColor,
    
    /**
    * 0x8002.  The blend factor is one minus the constant color.
    *
    * @type {Number}
    * @constant
    */
    OneMinusConstantColor,
    
    /**
    * 0x8003.  The blend factor is the constant alpha.
    *
    * @type {Number}
    * @constant
    */
    ConstantAlpha,
    
    /**
    * 0x8004.  The blend factor is one minus the constant alpha.
    *
    * @type {Number}
    * @constant
    */
    OneMinusConstantAlpha,
    
    /**
    * 0x0308.  The blend factor is the saturated source alpha.
    *
    * @type {Number}
    * @constant
    */
    SourceAlphaSaturate // WebGL: SRC_ALPHA_SATURATE
    
    func toGL() -> GLenum {
        switch self {
        case .Zero:
            return GLenum(0)
        case .One:
            return GLenum(1)
        case .SourceColor:
            return GLenum(GL_SRC_COLOR)
        case .OneMinusSourceColor:
            return GLenum(GL_ONE_MINUS_SRC_COLOR)
        case .DestinationColor:
            return GLenum(GL_DST_COLOR)
        case .OneMinusDestinationColor:
            return GLenum(GL_ONE_MINUS_DST_COLOR)
        case .SourceAlpha:
            return GLenum(GL_SRC_ALPHA)
        case .OneMinusSourceAlpha:
            return GLenum(GL_ONE_MINUS_SRC_ALPHA)
        case .DestinationAlpha:
            return GLenum(GL_DST_ALPHA)
        case .OneMinusDestinationAlpha:
            return GLenum(GL_ONE_MINUS_DST_ALPHA)
        case .ConstantColor:
            return GLenum(GL_CONSTANT_COLOR)
        case .OneMinusConstantColor:
            return GLenum(GL_ONE_MINUS_CONSTANT_COLOR)
        case .ConstantAlpha:
            return GLenum(GL_CONSTANT_ALPHA)
        case .OneMinusConstantAlpha:
            return GLenum(GL_ONE_MINUS_CONSTANT_ALPHA)
        case .SourceAlphaSaturate:
            return GLenum(GL_SRC_ALPHA_SATURATE)
        }
    }
    
}
