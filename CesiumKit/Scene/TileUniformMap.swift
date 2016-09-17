//
//  TileUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import simd

typealias Float4Tuple = (float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4)

var float4Tuple: Float4Tuple = {
    (float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4())
}()

typealias FloatTuple = (Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float)

var floatTuple: FloatTuple = {
    (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
}()

private let MaximumMetalTextureCount = 31

struct TileUniformStruct: UniformStruct {
    // Honestly...
    var dayTextureTexCoordsRectangle = float4Tuple
    var dayTextureTranslationAndScale = float4Tuple
    var dayTextureAlpha = floatTuple
    var dayTextureBrightness = floatTuple
    var dayTextureContrast = floatTuple
    var dayTextureHue = floatTuple
    var dayTextureSaturation = floatTuple
    var dayTextureOneOverGamma = floatTuple
    var minMaxHeight = float2()
    var scaleandBias = float4x4()
    var waterMaskTranslationAndScale = float4()
    var initialColor = float4()
    var tileRectangle = float4()
    var modifiedModelView = float4x4()
    var center3D = float3()
    var southMercatorYAndOneOverHeight = float2()
    var southAndNorthLatitude = float2()
    var lightingFadeDistance = float2()
    var zoomedOutOceanSpecularIntensity = Float(0.0)
}
    
class TileUniformMap: NativeUniformMap {
    
    let maxTextureCount: Int
    
    var initialColor: float4 {
        get {
            return _uniformStruct.initialColor
        }
        set {
            _uniformStruct.initialColor = newValue
        }
    }
    
    var zoomedOutOceanSpecularIntensity: Float {
        get {
            return _uniformStruct.zoomedOutOceanSpecularIntensity
        }
        set {
            _uniformStruct.zoomedOutOceanSpecularIntensity = newValue
        }
    }
    
    var oceanNormalMap: Texture? = nil
    
    var lightingFadeDistance: float2 {
        get {
            return _uniformStruct.lightingFadeDistance
        }
        set {
            _uniformStruct.lightingFadeDistance = newValue
        }
    }
    
    var center3D: float3 {
        get {
            return _uniformStruct.center3D
        }
        set {
            _uniformStruct.center3D = newValue
        }
    }
    
    var modifiedModelView: float4x4 {
        get {
            return _uniformStruct.modifiedModelView
        }
        set {
            _uniformStruct.modifiedModelView = newValue
        }
    }
    
    var tileRectangle: float4 {
        get {
            return _uniformStruct.tileRectangle
        }
        set {
            _uniformStruct.tileRectangle = newValue
        }
    }
    
    var dayTextures: [Texture]
    
    var dayTextureTranslationAndScale: [float4] {
        get {
            var floatArray = [float4](repeating: float4(), count: MaximumMetalTextureCount)
            memcpy(&floatArray, &_uniformStruct.dayTextureTranslationAndScale, MemoryLayout<float4>.size * MaximumMetalTextureCount)
            return floatArray
        }
        set {
            memcpy(&_uniformStruct.dayTextureTranslationAndScale, newValue, MemoryLayout<float4>.size * MaximumMetalTextureCount)
        }
    }
    
    var dayTextureTexCoordsRectangle: [float4] {
        get {
            var floatArray = [float4](repeating: float4(), count: MaximumMetalTextureCount)
            memcpy(&floatArray, &_uniformStruct.dayTextureTexCoordsRectangle, MemoryLayout<float4>.size * MaximumMetalTextureCount)
            return floatArray
        }
        set {
            memcpy(&_uniformStruct.dayTextureTexCoordsRectangle, newValue, MemoryLayout<float4>.size * MaximumMetalTextureCount)
        }
    }
    
    var dayTextureAlpha: [Float]
    var dayTextureBrightness: [Float]
    var dayTextureContrast: [Float]
    var dayTextureHue: [Float]
    var dayTextureSaturation: [Float]
    var dayTextureOneOverGamma: [Float]
    
    var dayIntensity = 0.0
    
    var southAndNorthLatitude: float2 {
        get {
            return _uniformStruct.southAndNorthLatitude
        }
        set {
            _uniformStruct.southAndNorthLatitude = newValue
        }
    }
    
    var southMercatorYAndOneOverHeight: float2 {
        get {
            return _uniformStruct.southMercatorYAndOneOverHeight
        }
        set {
            _uniformStruct.southMercatorYAndOneOverHeight = newValue
        }
    }
    
    var waterMask: Texture? = nil
    
    var waterMaskTranslationAndScale: float4 {
        get {
            return _uniformStruct.waterMaskTranslationAndScale
        }
        set {
            _uniformStruct.waterMaskTranslationAndScale = newValue
        }
    }
    
    var minMaxHeight: float2 {
        get {
            return _uniformStruct.minMaxHeight
        }
        set {
            _uniformStruct.minMaxHeight = newValue
        }
    }
    
    var scaleAndBias: float4x4 {
        get {
            return _uniformStruct.scaleandBias
        }
        set {
            _uniformStruct.scaleandBias = newValue
        }
    }
    
    fileprivate var _uniformStruct = TileUniformStruct()
    
    let uniformDescriptors: [UniformDescriptor] = [
        UniformDescriptor(name:  "u_dayTextureTexCoordsRectangle", type: .floatVec4, count: MaximumMetalTextureCount),
        UniformDescriptor(name:  "u_dayTextureTranslationAndScale", type: .floatVec4, count: MaximumMetalTextureCount),
        UniformDescriptor(name:  "u_dayTextureAlpha", type: .floatVec1, count: MaximumMetalTextureCount),
        UniformDescriptor(name:  "u_dayTextureBrightness", type: .floatVec1, count: MaximumMetalTextureCount),
        UniformDescriptor(name:  "u_dayTextureContrast", type: .floatVec1, count: MaximumMetalTextureCount),
        UniformDescriptor(name:  "u_dayTextureHue", type: .floatVec1, count: MaximumMetalTextureCount),
        UniformDescriptor(name:  "u_dayTextureSaturation", type: .floatVec1, count: MaximumMetalTextureCount),
        UniformDescriptor(name:  "u_dayTextureOneOverGamma", type: .floatVec1, count: MaximumMetalTextureCount),
        UniformDescriptor(name:  "u_minMaxHeight", type: .floatVec2, count: 1),
        UniformDescriptor(name:  "u_scaleAndBias", type: .floatMatrix4, count: 1),
        UniformDescriptor(name:  "u_waterMaskTranslationAndScale", type: .floatVec4, count: 1),
        UniformDescriptor(name:  "u_initialColor", type: .floatVec4, count: 1),
        UniformDescriptor(name:  "u_tileRectangle", type: .floatVec4, count: 1),
        UniformDescriptor(name:  "u_modifiedModelView", type: .floatMatrix4, count: 1),
        UniformDescriptor(name:  "u_center3D", type: .floatVec3, count: 1),
        UniformDescriptor(name:  "u_southMercatorYAndOneOverHeight", type: .floatVec2, count: 1),
        UniformDescriptor(name:  "u_southAndNorthLatitude", type: .floatVec2, count: 1),
        UniformDescriptor(name:  "u_lightingFadeDistance", type: .floatVec2, count: 1),
        UniformDescriptor(name:  "u_zoomedOutOceanSpecularIntensity", type: .floatVec1, count: 1)
    ]
    
    var uniformBufferProvider: UniformBufferProvider! = nil
        
    fileprivate (set) var uniformUpdateBlock: UniformUpdateBlock! = nil
    
    init (maxTextureCount: Int) {
        self.maxTextureCount = maxTextureCount
        
        dayTextures = [Texture]()
        dayTextures.reserveCapacity(maxTextureCount)

        dayTextureAlpha = [Float]()
        dayTextureBrightness = [Float]()
        dayTextureContrast = [Float]()
        dayTextureHue = [Float]()
        dayTextureSaturation = [Float]()
        dayTextureOneOverGamma = [Float]()
        
         uniformUpdateBlock = { buffer in
            buffer.write(from: &self._uniformStruct, length: MemoryLayout<TileUniformStruct>.size)
            var textures = self.dayTextures
            if let waterMask = self.waterMask {
                textures.append(waterMask)
            }
            if let oceanNormalMap = self.oceanNormalMap {
                textures.append(oceanNormalMap)
            }
            return textures
        }
    }
    
    func textureForUniform (_ uniform: UniformSampler) -> Texture? {
        let dayTextureCount = dayTextures.count
        if uniform.textureUnitIndex == dayTextureCount {
            return waterMask
        } else if uniform.textureUnitIndex == dayTextureCount + 1 {
            return oceanNormalMap
        }
        return dayTextures[uniform.textureUnitIndex]
    }

}
