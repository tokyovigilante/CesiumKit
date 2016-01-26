//
//  ImageryLayerUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

class ImageryLayerUniformMap: UniformMap {
    
    var textureDimensions = [Float](count: 2, repeatedValue: 0.0)
    
    var texture : Texture?
    
    let uniforms: [String: UniformFunc] = [
        
        "u_texture": { (map: UniformMap) -> [SIMDType] in
            return [(map as! ImageryLayerUniformMap).texture!]
        },
        
        "u_textureDimensions": { (map: UniformMap) -> [SIMDType] in
            return (map as! ImageryLayerUniformMap).textureDimensions
        }
    ]
    
    func textureForUniform(uniform: UniformSampler) -> Texture? {
        return texture
    }

}