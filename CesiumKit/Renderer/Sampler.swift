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
    
    init? (context: Context, wrapS: TextureWrap = .clampToEdge, wrapT: TextureWrap  = .clampToEdge, minFilter: TextureMinMagFilter = .linear, magFilter: TextureMinMagFilter = .linear, mipMagFilter: TextureMipFilter = .notMipmapped, maximumAnisotropy: Int = 1) {
        
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = minFilter.toMetal()
        descriptor.magFilter = magFilter.toMetal()
        descriptor.mipFilter = mipMagFilter.toMetal()
        descriptor.sAddressMode = wrapS.toMetal()
        descriptor.tAddressMode = wrapT.toMetal()
        descriptor.maxAnisotropy = maximumAnisotropy
        
        guard let state = context.createSamplerState(descriptor) else {
            logPrint(.error, "cannot create sampler state")
            return nil
        }
        self.state = state
    }
}

enum TextureWrap: UInt {

    case clampToEdge
    case mirrorClampToEdge
    case `repeat`
    case mirrorRepeat
    case clampToZero
    
    func toMetal() -> MTLSamplerAddressMode {
        return MTLSamplerAddressMode(rawValue: self.rawValue)!
    }
}

enum TextureMinMagFilter: UInt {
    
    case nearest
    case linear
    
    func toMetal() -> MTLSamplerMinMagFilter {
        return MTLSamplerMinMagFilter(rawValue: self.rawValue)!
    }
}

enum TextureMipFilter: UInt {
    
    case notMipmapped
    case nearest
    case linear
    
    func toMetal() -> MTLSamplerMipFilter {
        return MTLSamplerMipFilter(rawValue: self.rawValue)!
    }
}

