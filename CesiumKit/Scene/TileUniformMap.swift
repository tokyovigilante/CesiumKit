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
    
    var dayTextureTranslationAndScale: [Cartesian4]
    
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
        
        "u_initialColor": { (map: UniformMap) -> [Any] in
            return [(map as! TileUniformMap).initialColor]
        },
        
        "u_zoomedOutOceanSpecularIntensity": { (map: UniformMap) -> [Any] in
        return [(map as! TileUniformMap).zoomedOutOceanSpecularIntensity]
        },
        
        "u_oceanNormalMap": { (map: UniformMap) -> [Any] in
        return [(map as! TileUniformMap).oceanNormalMap]
        },
        
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
        
        "u_dayTextures": { (map: UniformMap) -> [Any] in
            return (map as! TileUniformMap).dayTextures.map({ $0 as Any })
        },
        
        "u_dayTextureTranslationAndScale": { (map: UniformMap) -> [Any] in
            return (map as! TileUniformMap).dayTextureTranslationAndScale.map({ $0 as Any })
        },
        
        "u_dayTextureTexCoordsRectangle": { (map: UniformMap) -> [Any] in
            return (map as! TileUniformMap).dayTextureTexCoordsRectangle.map({ $0 as Any })
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
        
        "u_waterMask": { (map: UniformMap) -> [Any] in
            return [(map as! TileUniformMap).waterMask!]
        },
        
        "u_waterMaskTranslationAndScale": { (map: UniformMap) -> [Any] in
            return [(map as! TileUniformMap).waterMaskTranslationAndScale]
        }*/
    ]
    
    init(maxTextureCount: Int) {
        self.maxTextureCount = maxTextureCount
        dayTextures = [Texture]()
        dayTextures.reserveCapacity(maxTextureCount)
        dayTextureTranslationAndScale = [Cartesian4](count: maxTextureCount, repeatedValue: Cartesian4())
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