//
//  GLEnumerations.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 14/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

enum PixelDatatype: GLint {
    case UnsignedByte = 0x1401,
    UnsignedShort = 0x1403,
    UnsignedInt = 0x1405,
    Float = 0x1406,
    UnsignedInt24_8 = 0x84FA,
    UnsignedShort4444 = 0x8033,
    UnsignedShort5551 = 0x8034,
    UnsignedShort565 = 0x8363
    
    var bytesPerElement: Int {
        get {
            switch self {
            case UnsignedByte:
                return 1
            case UnsignedShort:
                return 2
            case UnsignedInt:
                return 4
            case Float:
                return 4
            case UnsignedInt24_8:
                return 4
            case UnsignedShort4444:
                return 2
            case UnsignedShort5551:
                return 2
            case UnsignedShort565:
                return 2
            }
        }
    }
}



enum PixelFormat: GLint {
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
    
    var byteCount: Int {
        get {
            switch self {
            case .RGB:
                return 3
            case Alpha:
                return 1
            case .RGBA:
                return 4
            case .Luminance:
                return 1
            case .LuminanceAlpha:
                return 2
            default:
                return 0
            }
        }
    }
}
