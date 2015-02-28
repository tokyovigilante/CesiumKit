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
    
    var northLatitude: Float = 0.0
    
    var southLatitude: Float = 0.0
    
    var southMercatorYHigh: Float = 0.0
    
    var southMercatorYLow: Float = 0.0
    
    var oneOverMercatorHeight: Float = 0.0
    
    private var _uniforms: [String: UniformFunc] = [
        
        "u_textureDimensions": { (map: UniformMap) -> [UniformValue] in
            return [UniformValue.FloatVec2((map as! ImageryLayerUniformMap).textureDimensions)]
        },
        
        "u_texture": { (map: UniformMap) -> [UniformValue] in
            return [UniformValue.Sampler2D((map as! ImageryLayerUniformMap).texture!)]
        },
        
        "u_northLatitude": { (map: UniformMap) -> [UniformValue] in
            return [UniformValue.FloatVec1((map as! ImageryLayerUniformMap).northLatitude)]
        },
        
        "u_southLatitude": { (map: UniformMap) -> [UniformValue] in
            return [UniformValue.FloatVec1((map as! ImageryLayerUniformMap).southLatitude)]
        },
        
        "u_southMercatorYLow": { (map: UniformMap) -> [UniformValue] in
            return [UniformValue.FloatVec1((map as! ImageryLayerUniformMap).southMercatorYLow)]
        },
        
        "u_southMercatorYHigh": { (map: UniformMap) -> [UniformValue] in
            return [UniformValue.FloatVec1((map as! ImageryLayerUniformMap).southMercatorYHigh)]
        },
        
        "u_oneOverMercatorHeight": { (map: UniformMap) -> [UniformValue] in
            return [UniformValue.FloatVec1((map as! ImageryLayerUniformMap).oneOverMercatorHeight)]
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