//
//  ImageryLayerUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

class ImageryLayerUniformMap: UniformMap {
    
    var textureDimensions = Cartesian2()
    
    var texture : Texture?
    
    private var _uniforms: [String: UniformFunc] = [
        
        "u_textureDimensions": { (map: UniformMap) -> [Any] in
            return [(map as! ImageryLayerUniformMap).textureDimensions]
        },
        
        "u_texture": { (map: UniformMap) -> [Any] in
            return [(map as! ImageryLayerUniformMap).texture!]
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
}