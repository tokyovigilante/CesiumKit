//
//  GLEnumerations.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 14/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

enum CullFace {
    case Front,
    Back,
    FrontAndBack
    
    func toGL() -> GLenum {
        switch self {
        case .Front:
            return GLenum(GL_FRONT)
        case .Back:
            return GLenum(GL_BACK)
        case .FrontAndBack:
            return GLenum(GL_FRONT_AND_BACK)
        }
    }
}

enum BufferUsage: GLenum {
    case StreamDraw = 0x88E0,
    StaticDraw = 0x88E4,
    DynamicDraw = 0x88E8
}

enum PixelDatatype: GLenum {
    case UnsignedByte = 0x1401,
    UnsignedShort = 0x1403,
    UnsignedInt = 0x1405,
    Float = 0x1406,
    UnsignedInt24_8 = 0x84FA,
    UnsignedShort4444 = 0x8033,
    UnsignedShort5551 = 0x8034,
    UnsignedShort565 = 0x8363
}

/**
* Winding order defines the order of vertices for a triangle to be considered front-facing.
*
* @namespace
* @alias WindingOrder
*/
enum WindingOrder: GLenum {
    /**
    * 0x0900. Vertices are in clockwise order.
    *
    * @type {Number}
    * @constant
    */
    case Clockwise = 0x0900, // WebGL: CW
    
    /**
    * 0x0901. Vertices are in counter-clockwise order.
    *
    * @type {Number}
    * @constant
    */
    CounterClockwise = 0x0901 // WebGL: CCW
}

/**
* Determines the function used to compare two depths for the depth test.
*
* @namespace
* @alias DepthFunction
*/
enum DepthFunction: GLenum {
    /**
    * 0x200.  The depth test never passes.
    *
    * @type {Number}
    * @constant
    */
    case Never = 0x0200,
    
    /**
    * 0x201.  The depth test passes if the incoming depth is less than the stored depth.
    *
    * @type {Number}
    * @constant
    */
    Less = 0x201,
    
    /**
    * 0x202.  The depth test passes if the incoming depth is equal to the stored depth.
    *
    * @type {Number}
    * @constant
    */
    Equal = 0x0202,
    
    /**
    * 0x203.  The depth test passes if the incoming depth is less than or equal to the stored depth.
    *
    * @type {Number}
    * @constant
    */
    LessOrEqual = 0x203, // LEQUAL
    
    /**
    * 0x204.  The depth test passes if the incoming depth is greater than the stored depth.
    *
    * @type {Number}
    * @constant
    */
    Greater = 0x0204,
    
    /**
    * 0x0205.  The depth test passes if the incoming depth is not equal to the stored depth.
    *
    * @type {Number}
    * @constant
    */
    NotEqual = 0x0205, // NOTEQUAL
    
    /**
    * 0x206.  The depth test passes if the incoming depth is greater than or equal to the stored depth.
    *
    * @type {Number}
    * @constant
    */
    GreaterOrAlways = 0x0206, // GEQUAL
    
    /**
    * 0x207.  The depth test always passes.
    *
    * @type {Number}
    * @constant
    */
    Always = 0x0207
}

enum PixelFormat: GLenum {
    /**
    * 0x1902.  A pixel format containing a depth value.
    *
    * @type {Number}
    * @constant
    */
    case DepthComponent = 0x1902,
    
    /**
    * 0x84F9.  A pixel format containing a depth and stencil value, most often used with {@link PixelDatatype.UNSIGNED_INT_24_8_WEBGL}.
    *
    * @type {Number}
    * @constant
    */
    DepthStencil = 0x84F9,
    
    /**
    * 0x1906.  A pixel format containing an alpha channel.
    *
    * @type {Number}
    * @constant
    */
    Alpha = 0x1906,
    
    /**
    * 0x1907.  A pixel format containing red, green, and blue channels.
    *
    * @type {Number}
    * @constant
    */
    RGB = 0x1907,
    
    /**
    * 0x1908.  A pixel format containing red, green, blue, and alpha channels.
    *
    * @type {Number}
    * @constant
    */
    RGBA = 0x1908,
    
    /**
    * 0x1909.  A pixel format containing a luminance (intensity) channel.
    *
    * @type {Number}
    * @constant
    */
    Luminance = 0x1909,
    
    /**
    * 0x190A.  A pixel format containing luminance (intensity) and alpha channels.
    *
    * @type {Number}
    * @constant
    * @default 0x190A
    */
    LuminanceAlpha = 0x190A
    
    func isColorFormat() -> Bool {
        return self == PixelFormat.Alpha ||
            self == PixelFormat.RGB ||
            self == PixelFormat.RGBA ||
            self == PixelFormat.Luminance ||
            self == PixelFormat.LuminanceAlpha
    }
    
    func isDepthFormat() -> Bool {
        return self == PixelFormat.DepthComponent ||
            self == PixelFormat.DepthStencil
    }
}