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
    var viewportOrthographic = float4x4()
    var textureDimensions = float2()
}

class ImageryLayerUniformMap: NativeUniformMap {
    
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
        UniformDescriptor(name: "u_viewportOrthographic", type: .FloatMatrix4, count: 1),
        UniformDescriptor(name: "u_textureDimensions", type: .FloatVec2, count: 1)
    ]
    
    private var _uniformStruct = ImageryLayerUniformStruct()
    
    private (set) var uniformUpdateBlock: UniformUpdateBlock! = nil

    init () {
        uniformUpdateBlock = { buffer in
            buffer.write(from: &self._uniformStruct, length: sizeof(ImageryLayerUniformStruct))
            return [self.texture!]
        }
    }

}