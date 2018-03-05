//
//  PixelFormat.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 3/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Metal

public enum PixelFormat: UInt {

    case invalid = 0

    case a8Unorm = 1
    case r8Unorm  = 10

    case rgba8Unorm = 70
    case bgra8Unorm = 80

    case depth32Float = 252
    case stencil8 = 253
    case depth32FloatStencil8 = 260

    public func toMetal () -> MTLPixelFormat {
        return MTLPixelFormat(rawValue: self.rawValue)!
    }
}
