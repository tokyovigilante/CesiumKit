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
        
    private var _floatUniforms: [String: FloatUniformFunc] = [
        
        "u_textureDimensions": { (map: UniformMap) -> [Float] in
            return (map as! ImageryLayerUniformMap).textureDimensions
        }
    ]
    
    subscript(name: String) -> UniformFunc? {
        get {
            return uniform(name)
        }
    }
    
    func uniform(name: String) -> UniformFunc? {
        return _uniforms[name]
    }
    
    func floatUniform(name: String) -> FloatUniformFunc? {
        return _floatUniforms[name]
    }
    
    func textureForUniform(uniform: UniformSampler) -> Texture? {
        return texture
    }

}