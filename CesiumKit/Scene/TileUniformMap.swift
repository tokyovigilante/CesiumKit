//
//  TileUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

class TileUniformMap: UniformMap {
    
    let maxTextureCount: Int
    
    var initialColor = [Float](count: 4, repeatedValue: 0.0) // Cartesian4
    
    var zoomedOutOceanSpecularIntensity: Float = 0.5
    
    var oceanNormalMap: Texture? = nil
    
    var lightingFadeDistance: [Float] = [6500000, 9000000]
    
    var center3D = [Float](count: 3, repeatedValue: 0.0) // Cartesian3
    
    var modifiedModelView = [Float](count: 16, repeatedValue: 0.0) // Matrix4
    
    var tileRectangle = [Float](count: 4, repeatedValue: 0.0) // Cartesian4
    
    var dayTextures: [Texture]
    
    var dayTextureTranslationAndScale: [Float]
    var dayTextureTexCoordsRectangle: [Float]
    var dayTextureAlpha: [Float]
    var dayTextureBrightness: [Float]
    var dayTextureContrast: [Float]
    var dayTextureHue: [Float]
    var dayTextureSaturation: [Float]
    var dayTextureOneOverGamma: [Float]
    
    var dayIntensity = 0.0
    
    var southAndNorthLatitude = [Float](count: 2, repeatedValue: 0.0) // Cartesian2
    
    var southMercatorYLowAndHighAndOneOverHeight = [Float](count: 3, repeatedValue: 0.0) // = Cartesian3()
    
    var waterMask: Texture? = nil
    
    var waterMaskTranslationAndScale = [Float](count: 4, repeatedValue: 0.0)// Cartesian4()
    
    private var _uniforms: [String: UniformFunc] = [
        
       /* "u_initialColor": { (map: UniformMap) -> [Float] in
            return [(map as! TileUniformMap).initialColor]
        },
        
        "u_zoomedOutOceanSpecularIntensity": { (map: UniformMap) -> [Any] in
        return [(map as! TileUniformMap).zoomedOutOceanSpecularIntensity]
        },*/
        
        "u_oceanNormalMap": { (map: UniformMap) -> [Any] in
        return [(map as! TileUniformMap).oceanNormalMap]
        },
        /*
        "u_lightingFadeDistance": { (map: UniformMap) -> [Any] in
        return [(map as! TileUniformMap).lightingFadeDistance]
        },
        
        "u_center3D": { (map: UniformMap) -> [Any] in
            return [(map as! TileUniformMap).center3D]
        },
        
        "u_tileRectangle": { (map: UniformMap) -> [Any] in
        return [(map as! TileUniformMap).tileRectangle]
        },
        
        "u_modifiedModelView": { (map: UniformMap) -> [Any] in
            return [(map as! TileUniformMap).modifiedModelView]
        },
        */
        "u_dayTextures": { (map: UniformMap) -> [Any] in
            return (map as! TileUniformMap).dayTextures.map({ $0 as Any })
        },
        /*
        "u_dayTextureTranslationAndScale": { (map: UniformMap) -> [Any] in
            return (map as! TileUniformMap).dayTextureTranslationAndScale.map({ $0 as Any })
        },
        
        "u_dayTextureTexCoordsRectangle": { (map: UniformMap) -> [Any] in
            return (map as! TileUniformMap).dayTextureTexCoordsRectangle.map({ $0 as Any })
        },
        
        "u_dayTextureAlpha": { (map: UniformMap) -> [Any]  in
            return (map as! TileUniformMap).dayTextureAlpha
        },
        
        "u_dayTextureBrightness": { (map: UniformMap) -> [Any] in
            return (map as! TileUniformMap).dayTextureBrightness
        },
        
        "u_dayTextureContrast": { (map: UniformMap) -> [Any] in
            return (map as! TileUniformMap).dayTextureContrast
        },
        
        "u_dayTextureHue": { (map: UniformMap) -> [Any] in
            return (map as! TileUniformMap).dayTextureHue
        },
        
        "u_dayTextureSaturation": { (map: UniformMap) -> [Any] in
            return (map as! TileUniformMap).dayTextureSaturation
        },
        
        "u_dayTextureOneOverGamma": { (map: UniformMap) -> [Any] in
            return (map as! TileUniformMap).dayTextureOneOverGamma
        },
        
        "u_dayIntensity": { (map: UniformMap) -> [Any] in
            return [(map as! TileUniformMap).dayIntensity]
        },
        
        "u_southAndNorthLatitude": { (map: UniformMap) -> [Any] in
            return [(map as! TileUniformMap).southAndNorthLatitude]
        },
        
        "u_southMercatorYLowAndHighAndOneOverHeight": { (map: UniformMap) -> [Any] in
            return [(map as! TileUniformMap).southMercatorYLowAndHighAndOneOverHeight]
        },
        
        "u_waterMask": { (map: UniformMap) -> [Any] in
            return [(map as! TileUniformMap).waterMask!]
        },
        
        "u_waterMaskTranslationAndScale": { (map: UniformMap) -> [Any] in
            return [(map as! TileUniformMap).waterMaskTranslationAndScale]
        }*/
    ]
    
    private var _floatUniforms: [String: FloatUniformFunc] = [
        
        "u_initialColor": { (map: UniformMap) -> [Float] in
            return (map as! TileUniformMap).initialColor
        },
        
        "u_zoomedOutOceanSpecularIntensity": { (map: UniformMap) -> [Float] in
            return [(map as! TileUniformMap).zoomedOutOceanSpecularIntensity]
        },
        
        "u_lightingFadeDistance": { (map: UniformMap) -> [Float] in
            return (map as! TileUniformMap).lightingFadeDistance
        },
        
        "u_center3D": { (map: UniformMap) -> [Float] in
            return (map as! TileUniformMap).center3D
        },
        
        "u_tileRectangle": { (map: UniformMap) -> [Float] in
            return (map as! TileUniformMap).tileRectangle
        },
        
        "u_modifiedModelView": { (map: UniformMap) -> [Float] in
            return (map as! TileUniformMap).modifiedModelView
        },
        
        "u_dayTextureTranslationAndScale": { (map: UniformMap) -> [Float] in
            return (map as! TileUniformMap).dayTextureTranslationAndScale
        },
        
        "u_dayTextureTexCoordsRectangle": { (map: UniformMap) -> [Float] in
            return (map as! TileUniformMap).dayTextureTexCoordsRectangle
        },
        
        /*"u_dayTextureAlpha": { (map: UniformMap) -> [Any]  in
        return (map as! TileUniformMap).dayTextureAlpha
        },
        
        "u_dayTextureBrightness": { (map: UniformMap) -> [Any] in
        return (map as! TileUniformMap).dayTextureBrightness
        },
        
        "u_dayTextureContrast": { (map: UniformMap) -> [Any] in
        return (map as! TileUniformMap).dayTextureContrast
        },
        
        "u_dayTextureHue": { (map: UniformMap) -> [Any] in
        return (map as! TileUniformMap).dayTextureHue
        },
        
        "u_dayTextureSaturation": { (map: UniformMap) -> [Any] in
        return (map as! TileUniformMap).dayTextureSaturation
        },
        
        "u_dayTextureOneOverGamma": { (map: UniformMap) -> [Any] in
        return (map as! TileUniformMap).dayTextureOneOverGamma
        },
        
        "u_dayIntensity": { (map: UniformMap) -> [Any] in
        return [(map as! TileUniformMap).dayIntensity]
        },
        
        "u_southAndNorthLatitude": { (map: UniformMap) -> [Any] in
        return [(map as! TileUniformMap).southAndNorthLatitude]
        },
        
        "u_southMercatorYLowAndHighAndOneOverHeight": { (map: UniformMap) -> [Any] in
        return [(map as! TileUniformMap).southMercatorYLowAndHighAndOneOverHeight]
        },
        
        "u_waterMaskTranslationAndScale": { (map: UniformMap) -> [Any] in
        return [(map as! TileUniformMap).waterMaskTranslationAndScale]
        }*/
    ]
    
    init(maxTextureCount: Int) {
        self.maxTextureCount = maxTextureCount
        dayTextures = [Texture]()
        dayTextures.reserveCapacity(maxTextureCount)
        dayTextureTranslationAndScale = [Float](count: maxTextureCount * 4, repeatedValue: 0.0)
        dayTextureTexCoordsRectangle = [Float](count: maxTextureCount * 4, repeatedValue: 0.0)
        dayTextureAlpha = [Float](count: maxTextureCount, repeatedValue: 0.0)
        dayTextureBrightness = [Float](count: maxTextureCount, repeatedValue: 0.0)
        dayTextureContrast = [Float](count: maxTextureCount, repeatedValue: 0.0)
        dayTextureHue = [Float](count: maxTextureCount, repeatedValue: 0.0)
        dayTextureSaturation = [Float](count: maxTextureCount, repeatedValue: 0.0)
        dayTextureOneOverGamma = [Float](count: maxTextureCount, repeatedValue: 0.0)
    }
    
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
    
    func textureForUniform (uniform: UniformSampler) -> Texture? {
        let name = uniform.name
        if name.hasPrefix("u_dayTexture") {
            return dayTextures.first
        }
        return nil
    }
    
}