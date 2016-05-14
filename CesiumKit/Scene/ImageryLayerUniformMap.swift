//
//  ImageryLayerUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation
import simd

private struct ImageryLayerUniformStruct: UniformStruct {
    var textureDimensions = float2()
    var viewportOrthographic = float4x4()
}

class ImageryLayerUniformMap: UniformMap {
    
    var textureDimensions: Cartesian2 {
        get {
            return Cartesian2(simd: vector_double(_uniformStruct.textureDimensions))
        }
        set {
            _uniformStruct.textureDimensions = newValue.floatRepresentation
        }
    }
    
    var viewportOrthographic: Matrix4 {
        get {
            return Matrix4(simd: double4x4([
                vector_double(_uniformStruct.viewportOrthographic[0]),
                vector_double(_uniformStruct.viewportOrthographic[1]),
                vector_double(_uniformStruct.viewportOrthographic[2]),
                vector_double(_uniformStruct.viewportOrthographic[3])
            ]))
        }
        set {
            _uniformStruct.viewportOrthographic = newValue.floatRepresentation
        }
    }
    
    var texture : Texture?
 
    var uniformBufferProvider: UniformBufferProvider! = nil

    let uniformDescriptors: [UniformDescriptor] = [
        UniformDescriptor(name: "u_textureDimensions", type: .FloatVec2, count: 1),
        UniformDescriptor(name: "u_viewportOrthographic", type: .FloatMatrix4, count: 1)
    ]
    
    private var _uniformStruct = ImageryLayerUniformStruct()
    
    var metalUniformUpdateBlock: ((buffer: Buffer) -> [Texture])! = nil
    
    /*
    let uniforms: [String: UniformFunc] = [
        
        "u_textureDimensions": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! ImageryLayerUniformMap).textureDimensions.floatRepresentation
            memcpy(buffer, [simd], sizeof(float2))
        },
        
        "u_viewportOrthographic": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! ImageryLayerUniformMap).viewportOrthographic.floatRepresentation
            memcpy(buffer, [simd], sizeof(float4x4))
        }

    ]*/
    
    func textureForUniform(uniform: UniformSampler) -> Texture? {
        return texture
    }

}