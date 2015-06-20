//
//  Sampler.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

class Sampler {
    let state: MTLSamplerState
    
    init (context: Context, wrapS: TextureWrap = .ClampToEdge, wrapT: TextureWrap  = .ClampToEdge, minFilter: TextureMinMagFilter = .Linear, magFilter: TextureMinMagFilter = .Linear, mipMagFilter: TextureMipFilter = .NotMipmapped, maximumAnisotropy: Int = 1) {
        
        var descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = minFilter.toMetal()
        descriptor.magFilter = magFilter.toMetal()
        descriptor.mipFilter = mipMagFilter.toMetal()
        descriptor.sAddressMode = wrapS.toMetal()
        descriptor.tAddressMode = wrapT.toMetal()
        descriptor.maxAnisotropy = maximumAnisotropy
        
        state = context.createSamplerState(descriptor)
    }
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

