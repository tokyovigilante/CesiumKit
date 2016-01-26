//
//  TileUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

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
    
    var waterMaskTranslationAndScale = Cartesian4(0)
    
    let uniforms: [String: UniformFunc] = [
        
        "u_initialColor": { (map: UniformMap) -> [UniformSourceType] in
            return [(map as! TileUniformMap).initialColor]
        },
        
        "u_zoomedOutOceanSpecularIntensity": { (map: UniformMap) -> [UniformSourceType] in
            return [(map as! TileUniformMap).zoomedOutOceanSpecularIntensity]
        },
        
        "u_lightingFadeDistance": { (map: UniformMap) -> [UniformSourceType] in
            return [(map as! TileUniformMap).lightingFadeDistance]
        },
        
        "u_center3D": { (map: UniformMap) -> [UniformSourceType] in
            return [(map as! TileUniformMap).center3D]
        },
        
        "u_tileRectangle": { (map: UniformMap) -> [UniformSourceType] in
            return [(map as! TileUniformMap).tileRectangle]
        },
        
        "u_modifiedModelView": { (map: UniformMap) -> [UniformSourceType] in
            return [(map as! TileUniformMap).modifiedModelView]
        },

        "u_dayTextureTranslationAndScale": { (map: UniformMap) -> [UniformSourceType] in
            return (map as! TileUniformMap).dayTextureTranslationAndScale.map { $0 }
        },
        
        "u_dayTextureTexCoordsRectangle": { (map: UniformMap) -> [UniformSourceType] in
            return (map as! TileUniformMap).dayTextureTexCoordsRectangle.map { $0 }
        },
        
        "u_dayTextureAlpha": { (map: UniformMap) -> [UniformSourceType]  in
            return (map as! TileUniformMap).dayTextureAlpha.map { $0 }
        },
        
        "u_dayTextureBrightness": { (map: UniformMap) -> [UniformSourceType] in
            return (map as! TileUniformMap).dayTextureBrightness.map { $0 }
        },
        
        "u_dayTextureContrast": { (map: UniformMap) -> [UniformSourceType] in
            return (map as! TileUniformMap).dayTextureContrast.map { $0 }
        },
        
        "u_dayTextureHue": { (map: UniformMap) -> [UniformSourceType] in
            return (map as! TileUniformMap).dayTextureHue.map { $0 }
        },
        
        "u_dayTextureSaturation": { (map: UniformMap) -> [UniformSourceType] in
            return (map as! TileUniformMap).dayTextureSaturation.map { $0 }
        },
        
        "u_dayTextureOneOverGamma": { (map: UniformMap) -> [UniformSourceType] in
            return (map as! TileUniformMap).dayTextureOneOverGamma.map { $0 }
        },
        
        "u_dayIntensity": { (map: UniformMap) -> [UniformSourceType] in
            return [(map as! TileUniformMap).dayIntensity]
        },
        
        "u_southAndNorthLatitude": { (map: UniformMap) -> [UniformSourceType] in
            return [(map as! TileUniformMap).southAndNorthLatitude]
        },
        
        "u_southMercatorYLowAndHighAndOneOverHeight": { (map: UniformMap) -> [UniformSourceType] in
            return [(map as! TileUniformMap).southMercatorYLowAndHighAndOneOverHeight]
        },

        "u_waterMaskTranslationAndScale": { (map: UniformMap) -> [UniformSourceType] in
            return [(map as! TileUniformMap).waterMaskTranslationAndScale]
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