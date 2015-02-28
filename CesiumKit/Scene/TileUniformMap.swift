//
//  TileUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

class TileUniformMap: UniformMap {
    
    let maxTextureCount: Int
    
    var initialColor = Cartesian4(x: 0.0, y: 0.0, z: 0.5, w: 1.0)
    
    var zoomedOutOceanSpecularIntensity = 0.5
    
    var oceanNormalMap: Texture? = nil
    
    var lightingFadeDistance = Cartesian2(x: 6500000.0, y: 9000000.0)
    
    var center3D = Cartesian3()
    
    var modifiedModelView = Matrix4()
    
    var tileRectangle = Cartesian4()
    
    var dayTextures: [Texture]
    
    lazy var dayTextureTranslationAndScale: [Cartesian4] = {
        return Array(count: self.maxTextureCount, repeatedValue: Cartesian4())
    }()
    
    lazy var dayTextureTexCoordsRectangle: [Cartesian4] = {
        return Array(count: self.maxTextureCount, repeatedValue: Cartesian4())
    }()
    
    lazy var dayTextureAlpha: [Double] = {
        return Array(count: self.maxTextureCount, repeatedValue: Double())
    }()
    
    lazy var dayTextureBrightness: [Double] = {
        return Array(count: self.maxTextureCount, repeatedValue: Double())
    }()
    
    lazy var dayTextureContrast: [Double] = {
        return Array(count: self.maxTextureCount, repeatedValue: Double())
    }()
    
    lazy var dayTextureHue: [Double] = {
        return Array(count: self.maxTextureCount, repeatedValue: Double())
    }()
    
    lazy var dayTextureSaturation: [Double] = {
        return Array(count: self.maxTextureCount, repeatedValue: Double())
    }()
    
    lazy var dayTextureOneOverGamma: [Double] = {
        return Array(count: self.maxTextureCount, repeatedValue: Double())
    }()
    
    var dayIntensity = 0.0
    
    var southAndNorthLatitude = Cartesian2()
    
    var southMercatorYLowAndHighAndOneOverHeight = Cartesian3()
    
    var waterMask: Texture? = nil
    
    var waterMaskTranslationAndScale = Cartesian4()
    
    private var _uniforms: [String: UniformFunc] = [
    
        "u_initialColor": { (map: UniformMap) -> [UniformValue] in
            return [.FloatVec4((map as! TileUniformMap).initialColor)]
        },
        /*
        "u_zoomedOutOceanSpecularIntensity": { (map: TileUniformMap) -> Double in
            return map.zoomedOutOceanSpecularIntensity
        },
        
        "u_oceanNormalMap": { (map: TileUniformMap) -> Texture? in
            return map.oceanNormalMap
        },
        
        "u_lightingFadeDistance": { (map: TileUniformMap) -> Cartesian2 in
            return map.lightingFadeDistance
        },
        */
        "u_center3D": { (map: UniformMap) -> [UniformValue] in
            return [.FloatVec3((map as! TileUniformMap).center3D)]
        },
        /*
        "u_tileRectangle": { (map: TileUniformMap) -> Cartesian4 in
            return map.tileRectangle
        },
        */
        "u_modifiedModelView": { (map: UniformMap) -> [UniformValue] in
            return [.FloatMatrix4((map as! TileUniformMap).modifiedModelView)]
        },
        
        "u_dayTextures": { (map: UniformMap) -> [UniformValue] in
            return ((map as! TileUniformMap).dayTextures.map { .Sampler2D($0) })
        },
        
        "u_dayTextureTranslationAndScale": { (map: UniformMap) -> [UniformValue] in
            return ((map as! TileUniformMap).dayTextureTranslationAndScale.map { .FloatVec4($0) })
        },
        
        "u_dayTextureTexCoordsRectangle": { (map: UniformMap) -> [UniformValue] in
            return ((map as! TileUniformMap).dayTextureTexCoordsRectangle.map { UniformValue.FloatVec4($0) })
        },
        /*
        "u_dayTextureAlpha": { (map: TileUniformMap) -> [Double]  in
            return map.dayTextureAlpha
        },
        
        "u_dayTextureBrightness": { (map: TileUniformMap) -> [Double] in
            return map.dayTextureBrightness
        },
        
        "u_dayTextureContrast": { (map: TileUniformMap) -> [Double] in
            return map.dayTextureContrast
        },
        
        "u_dayTextureHue": { (map: TileUniformMap) -> [Double] in
            return map.dayTextureHue
        },
        
        "u_dayTextureSaturation": { (map: TileUniformMap) -> [Double] in
            return map.dayTextureSaturation
        },
        
        "u_dayTextureOneOverGamma": { (map: TileUniformMap) -> [Double] in
            return map.dayTextureOneOverGamma
        },
        
        "u_dayIntensity": { (map: TileUniformMap) -> Double in
            return map.dayIntensity
        },
        
        "u_southAndNorthLatitude": { (map: TileUniformMap) -> Cartesian2 in
            return map.southAndNorthLatitude
        },
        
        "u_southMercatorYLowAndHighAndOneOverHeight": { (map: TileUniformMap) -> Cartesian3 in
            return map.southMercatorYLowAndHighAndOneOverHeight
        },
        
        "u_waterMask": { (map: TileUniformMap) -> Texture? in
            return map.waterMask
        },
        
        "u_waterMaskTranslationAndScale": { (map: TileUniformMap) -> Cartesian4 in
            return map.waterMaskTranslationAndScale
        }*/
    ]

    init(maxTextureCount: Int) {
        self.maxTextureCount = maxTextureCount
        dayTextures = Array<Texture>()
        dayTextures.reserveCapacity(maxTextureCount)
    }
    
    subscript(name: String) -> UniformFunc? {
        get {
            return uniform(name)
        }
    }
    
    func uniform(name: String) -> UniformFunc? {
        return _uniforms[name]
    }

}