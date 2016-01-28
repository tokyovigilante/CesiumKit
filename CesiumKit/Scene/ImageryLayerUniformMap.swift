//
//  ImageryLayerUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation
import simd

class ImageryLayerUniformMap: UniformMap {
    
    var textureDimensions = Cartesian2()
    
    var texture : Texture?
    
    let uniforms: [String: UniformFunc] = [
        
        "u_textureDimensions": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! ImageryLayerUniformMap).textureDimensions.floatRepresentation
            memcpy(buffer, [simd], sizeof(float2))
        }
    ]
    
    func textureForUniform(uniform: UniformSampler) -> Texture? {
        return texture
    }

}