//
//  GlobeSurfaceShaderSet.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* Manages the shaders used to shade the surface of a {@link Globe}.
*
* @alias GlobeSurfaceShaderSet
* @private
*/
class GlobeSurfaceShaderSet {
    
    var baseVertexShaderString: String? = nil
    var baseFragmentShaderString: String? = nil
    
    let attributeLocations: [String: Int]
    
    var shaders = [String: ShaderProgram]()
    
    init (attributeLocations: [String: Int]) {
        self.baseVertexShaderString = nil
        self.baseFragmentShaderString = nil
        self.attributeLocations = attributeLocations
    }
    
    func invalidateShaders() {
        shaders = [String : ShaderProgram]()
    }
    
    func getShaderKey(#textureCount: Int, applyBrightness: Bool, applyContrast: Bool, applyHue: Bool, applySaturation: Bool, applyGamma: Bool, applyAlpha: Bool) -> String {
        var key = ""
        key += String(textureCount)
        
        if (applyBrightness) {
            key += "_brightness"
        }
        
        if (applyContrast) {
            key += "_contrast"
        }
        
        if (applyHue) {
            key += "_hue"
        }
        
        if (applySaturation) {
            key += "_saturation"
        }
        
        if (applyGamma) {
            key += "_gamma"
        }
        
        if (applyAlpha) {
            key += "_alpha"
        }
        return key
    }

    func getShaderProgram(#context: Context,
        textureCount: Int,
        applyBrightness: Bool,
        applyContrast: Bool,
        applyHue: Bool,
        applySaturation: Bool,
        applyGamma: Bool,
        applyAlpha: Bool) -> ShaderProgram {
            var key = getShaderKey(
                textureCount: textureCount,
                applyBrightness: applyBrightness,
                applyContrast: applyContrast,
                applyHue: applyHue,
                applySaturation: applySaturation,
                applyGamma: applyGamma,
                applyAlpha: applyAlpha)
            var shader = shaders[key]
            if (shader == nil) {
                var vs = baseVertexShaderString!
                //FIXME: compiler bug
                var fs =
                (applyBrightness == true ? "#define APPLY_BRIGHTNESS\n" : "") +
                    (applyContrast == true ? "#define APPLY_CONTRAST\n" : "") +
                    (applyHue == true ? "#define APPLY_HUE\n" : "") +
                    (applySaturation == true ? "#define APPLY_SATURATION\n" : "") +
                    (applyGamma == true ? "#define APPLY_GAMMA\n" : "")
                var fs2 = (applyAlpha == true ? "#define APPLY_ALPHA\n" : "")
                fs2 += String("#define TEXTURE_UNITS \(textureCount)\n")
                fs2 +=
                    baseFragmentShaderString! + "\n" +
                    "vec3 computeDayColor(vec3 initialColor, vec2 textureCoordinates)\n" +
                    "{\n" +
                "    vec3 color = initialColor\n"
                fs += fs2
                for i in 0..<textureCount {
                    //fs +=
                        fs += "color = sampleAndBlend(\n"
                        fs += "   color,\n"
                        fs += String("   u_dayTextures[\(i)],\n")
                        fs += "   textureCoordinates,\n"
                        fs += "   u_dayTextureTexCoordsRectangle[\(i)],\n"
                        fs += "   u_dayTextureTranslationAndScale[\(i)],\n"
                        fs += (applyAlpha ?      "   u_dayTextureAlpha[\(i)],\n" : "1.0,\n")
                        fs += (applyBrightness ? "   u_dayTextureBrightness[\(i)],\n" : "0.0,\n")
                        fs += (applyContrast ?   "   u_dayTextureContrast[\(i)],\n" : "0.0,\n")
                        fs += (applyHue ?        "   u_dayTextureHue[\(i)],\n" : "0.0,\n")
                        fs += (applySaturation ? "   u_dayTextureSaturation[\(i)],\n" : "0.0,\n")
                        fs += (applyGamma ?      "   u_dayTextureOneOverGamma[\(i)])\n" : "0.0)\n")
                }
                
                fs +=
                    "    return color\n" +
                "}"
                
                shader = context.createShaderProgram(vertexShaderSource: vs, fragmentShaderSource: fs, attributeLocations: attributeLocations)
                self.shaders[key] = shader
            }
            return shader!
    }
    
    deinit {
        invalidateShaders()
    }
    
}
