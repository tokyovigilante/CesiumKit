//
//  TextureUsage.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 4/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

import Metal

public struct TextureUsage: OptionSet {
    
    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }
    
    static let Unknown = TextureUsage(rawValue: 0)
    static let ShaderRead = TextureUsage(rawValue: 1)
    static let ShaderWrite =  TextureUsage(rawValue: 1 << 1)
    static let RenderTarget = TextureUsage(rawValue: 1 << 2)
    static let PixelFormatView = TextureUsage(rawValue: 1 << 3)
    
    func toMetal () -> MTLTextureUsage {
        return MTLTextureUsage(rawValue: self.rawValue)
    }
}
