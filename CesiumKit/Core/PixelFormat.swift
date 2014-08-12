//
//  PixelFormat.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/07/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

enum PixelFormat: Int {
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
        return self === PixelFormat.DepthComponent ||
            pixelFormat === PixelFormat.DepthStencil
    }
}