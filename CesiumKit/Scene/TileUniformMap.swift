//
//  TileUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

class TileUniformMap {
    
    var initialColor = Cartesian4(x: 0.0, y: 0.0, z: 0.5, w: 1.0)
    
    var zoomedOutOceanSpecularIntensity = 0.5
    
    var oceanNormalMap: Texture? = nil
    
    var lightingFadeDistance = Cartesian2(x: 6500000.0, y: 9000000.0)
    
    var center3D: Cartesian3? = nil
    
    var modifiedModelView = Matrix4()
    
    var tileRectangle = Rectangle()
    
    var dayTextures = [Texture]()
    
    var dayTextureTranslationAndScale = [Cartesian4]()
    
    var dayTextureTexCoordsRectangle = [Rectangle]()
    
    var dayTextureAlpha = [Double]()
    
    var dayTextureBrightness = [Double]()
    
    var dayTextureContrast = [Double]()
    
    var dayTextureHue = [Double]()
    
    var dayTextureSaturation = [Double]()
    
    var dayTextureOneOverGamma = [Double]()
    
    var dayIntensity = 0.0
    
    var southAndNorthLatitude = Cartesian2()
    
    var southMercatorYLowAndHighAndOneOverHeight = Cartesian3()
    
    var waterMask: [UInt8]? = nil
    
    var waterMaskTranslationAndScale = Cartesian4()
    
    func u_initialColor () -> Cartesian4 {
            return initialColor
    }
    
    func u_zoomedOutOceanSpecularIntensity () -> Double {
        return zoomedOutOceanSpecularIntensity
    }
    
    func u_oceanNormalMap () -> Texture? {
        return oceanNormalMap
    }
    
    func u_lightingFadeDistance () -> Cartesian2 {
        return lightingFadeDistance
    }
    
    func u_center3D () -> Cartesian3? {
        return center3D
    }
    
    func u_tileRectangle () -> Rectangle {
        return tileRectangle
    }
    
    func u_modifiedModelView () -> Matrix4 {
        return modifiedModelView
    }
    
    func u_dayTextures () -> [Texture] {
        return dayTextures
    }
    
    func u_dayTextureTranslationAndScale () -> [Cartesian4] {
        return dayTextureTranslationAndScale
    }
    
    func u_dayTextureTexCoordsRectangle () -> [Rectangle] {
        return dayTextureTexCoordsRectangle
    }
    
    func u_dayTextureAlpha () -> [Double]  {
        return dayTextureAlpha
    }
    
    func u_dayTextureBrightness () -> [Double] {
        return dayTextureBrightness
    }
    
    func u_dayTextureContrast () -> [Double] {
        return dayTextureContrast
    }
    
    func u_dayTextureHue () -> [Double] {
        return dayTextureHue
    }
    
    func u_dayTextureSaturation () -> [Double] {
        return dayTextureSaturation
    }
    
    func u_dayTextureOneOverGamma () -> [Double] {
        return dayTextureOneOverGamma
    }
    
    func u_dayIntensity () -> Double {
        return dayIntensity
    }
    
    func u_southAndNorthLatitude () -> Cartesian2 {
        return southAndNorthLatitude
    }
    
    func u_southMercatorYLowAndHighAndOneOverHeight () -> Cartesian3 {
        return southMercatorYLowAndHighAndOneOverHeight
    }
    
    func u_waterMask () -> [UInt8]? {
        return waterMask
    }
    
    func u_waterMaskTranslationAndScale () -> Cartesian4 {
        return waterMaskTranslationAndScale
    }
    
}