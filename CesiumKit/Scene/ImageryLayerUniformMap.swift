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
    
    let uniforms: [String: UniformFunc] = [
        
        "u_textureDimensions": { (map: UniformMap) -> [UniformSourceType] in
            return [(map as! ImageryLayerUniformMap).textureDimensions]
        }
    ]
    
    func textureForUniform(uniform: UniformSampler) -> Texture? {
        return texture
    }

}