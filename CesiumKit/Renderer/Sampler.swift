//
//  Sampler.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

class Sampler {
    let wrapS: TextureWrap = .ClampToEdge
    let wrapT: TextureWrap  = .ClampToEdge
    let minFilter: TextureMinMagFilter = .Linear
    let magFilter: TextureMinMagFilter = .Linear
    let mipMagFilter: TextureMipFilter = .NotMipmapped
    let maximumAnisotropy: Int = 1
}

enum TextureWrap: UInt {

    case ClampToEdge
    case Repeat
    case MirrorRepeat
    case ClampToZero
    
    func toMetal() -> MTLSamplerAddressMode {
        return MTLSamplerAddressMode(rawValue: self.rawValue)!
    }
}

enum TextureMinMagFilter: UInt {
    
    case Nearest
    case Linear
    
    func toMetal() -> MTLSamplerMinMagFilter {
        return MTLSamplerMinMagFilter(rawValue: self.rawValue)!
    }
}

enum TextureMipFilter: UInt {
    
    case NotMipmapped
    case Nearest
    case Linear
    
    func toMetal() -> MTLSamplerMipFilter {
        return MTLSamplerMipFilter(rawValue: self.rawValue)!
    }
}

