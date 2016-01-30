    //
//  TileUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import simd

class TileUniformMap: UniformMap {
    
    let maxTextureCount: Int
    
    var initialColor = Cartesian4()
    
    var zoomedOutOceanSpecularIntensity: Float = 0.5
    
    var oceanNormalMap: Texture? = nil
    
    var lightingFadeDistance = Cartesian2(x: 6500000, y: 9000000)
    
    var center3D = Cartesian3()
    
    var modifiedModelView = Matrix4()
    
    var tileRectangle = Cartesian4()
    
    var dayTextures: [Texture]
    
    var dayTextureTranslationAndScale: [Cartesian4]
    var dayTextureTexCoordsRectangle: [Cartesian4]
    var dayTextureAlpha: [Float]
    var dayTextureBrightness: [Float]
    var dayTextureContrast: [Float]
    var dayTextureHue: [Float]
    var dayTextureSaturation: [Float]
    var dayTextureOneOverGamma: [Float]
    
    var dayIntensity = 0.0
    
    var southAndNorthLatitude = Cartesian2()
    
    var southMercatorYLowAndHighAndOneOverHeight = Cartesian3()
    
    var waterMask: Texture? = nil
    
    var waterMaskTranslationAndScale = Cartesian4()
    
    let uniforms: [String: UniformFunc] = [
        
        "u_initialColor": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).initialColor.floatRepresentation
            memcpy(buffer, [simd], strideofValue(simd))
        },
        
        "u_zoomedOutOceanSpecularIntensity": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! TileUniformMap).zoomedOutOceanSpecularIntensity], sizeof(Float))
        },
        
        "u_lightingFadeDistance": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).lightingFadeDistance.floatRepresentation
            memcpy(buffer, [simd], sizeof(float2))
        },
        
        "u_center3D": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = vector_float((map as! TileUniformMap).center3D.simdType)
            memcpy(buffer, [simd], sizeof(float3))
        },
        
        "u_tileRectangle": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).tileRectangle.floatRepresentation
            memcpy(buffer, [simd], sizeof(float4x4))
        },
        
        "u_modifiedModelView": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).modifiedModelView.floatRepresentation
            memcpy(buffer, [simd], sizeof(float4x4))
        },

        "u_dayTextureTranslationAndScale": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).dayTextureTranslationAndScale.map { $0.floatRepresentation }
            memcpy(buffer, simd, simd.sizeInBytes)
        },
        
        "u_dayTextureTexCoordsRectangle": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).dayTextureTexCoordsRectangle.map { $0.floatRepresentation }
            memcpy(buffer, simd, simd.sizeInBytes)
        },
        
        "u_dayTextureAlpha": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureAlpha = (map as! TileUniformMap).dayTextureAlpha
            memcpy(buffer, dayTextureAlpha, dayTextureAlpha.sizeInBytes)
        },
        
        "u_dayTextureBrightness": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureBrightness = (map as! TileUniformMap).dayTextureBrightness
            memcpy(buffer, dayTextureBrightness, dayTextureBrightness.sizeInBytes)
        },
        
        "u_dayTextureContrast": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureContrast = (map as! TileUniformMap).dayTextureContrast
            memcpy(buffer, dayTextureContrast, dayTextureContrast.sizeInBytes)
        },
        
        "u_dayTextureHue": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureHue = (map as! TileUniformMap).dayTextureHue
            memcpy(buffer, dayTextureHue, dayTextureHue.sizeInBytes)
        },
        
        "u_dayTextureSaturation": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureSaturation = (map as! TileUniformMap).dayTextureSaturation
            memcpy(buffer, dayTextureSaturation, dayTextureSaturation.sizeInBytes)
        },
        
        "u_dayTextureOneOverGamma": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureOneOverGamma = (map as! TileUniformMap).dayTextureOneOverGamma
            memcpy(buffer, dayTextureOneOverGamma, dayTextureOneOverGamma.sizeInBytes)
        },
        
        "u_dayIntensity": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! TileUniformMap).dayIntensity], sizeof(Float))
        },
        
        "u_southAndNorthLatitude": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).southAndNorthLatitude.floatRepresentation
            memcpy(buffer, [simd], sizeof(float2))
        },
        
        "u_southMercatorYLowAndHighAndOneOverHeight": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = vector_float((map as! TileUniformMap).southMercatorYLowAndHighAndOneOverHeight.simdType)
            memcpy(buffer, [simd], sizeof(float3))
        },

        "u_waterMaskTranslationAndScale": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).waterMaskTranslationAndScale.floatRepresentation
            memcpy(buffer, [simd], sizeof(float4))
        }
    
    ]
    
    init(maxTextureCount: Int) {
        self.maxTextureCount = maxTextureCount
        dayTextures = [Texture]()
        dayTextures.reserveCapacity(maxTextureCount)
        dayTextureTranslationAndScale = [Cartesian4]()
        dayTextureTexCoordsRectangle = [Cartesian4]()
        dayTextureAlpha = [Float]()
        dayTextureBrightness = [Float]()
        dayTextureContrast = [Float]()
        dayTextureHue = [Float]()
        dayTextureSaturation = [Float]()
        dayTextureOneOverGamma = [Float]()
    }
    
    func textureForUniform (uniform: UniformSampler) -> Texture? {
        let dayTextureCount = dayTextures.count
        if uniform.textureUnitIndex == dayTextureCount {
            return waterMask
        } else if uniform.textureUnitIndex == dayTextureCount + 1 {
            return oceanNormalMap
        }
        return dayTextures[uniform.textureUnitIndex]
    }
    
}