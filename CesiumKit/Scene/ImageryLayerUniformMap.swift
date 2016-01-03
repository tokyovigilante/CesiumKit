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
    
    private var _uniforms: [String: UniformFunc] = [
        
        "u_texture": { (map: UniformMap) -> [Any] in
            return [(map as! ImageryLayerUniformMap).texture!]
        }
    ]
        
    let floatUniforms: [String: FloatUniformFunc] = [
        
        "u_textureDimensions": { (map: UniformMap) -> [Float] in
            return (map as! ImageryLayerUniformMap).textureDimensions
        }
    ]
        
    func uniform(name: String) -> UniformFunc? {
        return _uniforms[name]
    }
        
    func textureForUniform(uniform: UniformSampler) -> Texture? {
        return texture
    }

}