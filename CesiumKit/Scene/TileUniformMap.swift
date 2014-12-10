//
//  TileUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

protocol UniformMap {}

class TileUniformMap: UniformMap {
    
    var initialColor = Cartesian4(x: 0.0, y: 0.0, z: 0.5, w: 1.0)
    
    var zoomedOutOceanSpecularIntensity = 0.5
    
    var oceanNormalMap: Texture? = nil
    
    var lightingFadeDistance = Cartesian2(x: 6500000.0, y: 9000000.0)
    
    var center3D = Cartesian3()
    
    var modifiedModelView = Matrix4()
    
    var tileRectangle = Cartesian4()
    
    var dayTextures = [Texture]()
    
    var dayTextureTranslationAndScale = [Cartesian4]()
    
    var dayTextureTexCoordsRectangle = [Cartesian4]()
    
    var dayTextureAlpha = [Double]()
    
    var dayTextureBrightness = [Double]()
    
    var dayTextureContrast = [Double]()
    
    var dayTextureHue = [Double]()
    
    var dayTextureSaturation = [Double]()
    
    var dayTextureOneOverGamma = [Double]()
    
    var dayIntensity = 0.0
    
    var southAndNorthLatitude = Cartesian2()
    
    var southMercatorYLowAndHighAndOneOverHeight = Cartesian3()
    
    var waterMask: Texture? = nil
    
    var waterMaskTranslationAndScale = Cartesian4()
    
    var uniforms: [String: ((map: TileUniformMap) -> UniformValue)] = [
    
        "u_initialColor": { (map: TileUniformMap) -> UniformValue in
            return .FloatVec4(map.initialColor)
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
        "u_center3D": { (map: TileUniformMap) -> UniformValue in
            return .FloatVec3(map.center3D)
        },
        /*
        "u_tileRectangle": { (map: TileUniformMap) -> Cartesian4 in
            return map.tileRectangle
        },
        */
        "u_modifiedModelView": { (map: TileUniformMap) -> UniformValue in
            return .FloatMatrix4(map.modifiedModelView)
        },
        /*
        "u_dayTextures": { (map: TileUniformMap) -> [Texture] in
            return map.dayTextures
        },
        
        "u_dayTextureTranslationAndScale": { (map: TileUniformMap) -> [Cartesian4] in
            return map.dayTextureTranslationAndScale
        },
        
        "u_dayTextureTexCoordsRectangle": { (map: TileUniformMap) -> [Cartesian4] in
            return map.dayTextureTexCoordsRectangle
        },
        
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


}