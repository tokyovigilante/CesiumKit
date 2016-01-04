//
//  PixelFormat.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 3/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Metal

public enum PixelFormat: UInt {
    
    case Invalid = 0
    
    case A8Unorm = 1
    case R8Unorm  = 10

    case RGBA8Unorm = 70
    case BGRA8Unorm = 80
    
    case Depth32Float = 252
    case Stencil8 = 253
    case Depth32FloatStencil8 = 260
    
    public func toMetal () -> MTLPixelFormat {
        return MTLPixelFormat(rawValue: self.rawValue)!
    }
}
