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
    
    let baseVertexShaderString: String? = nil
    let baseFragmentShaderString: String? = nil
    
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
    // FIXME: GetShaderProgram
    func getShaderProgram(context: Context,
        textureCount: Int,
        applyBrightness: Bool,
        applyContrast: Bool,
        applyHue: Bool,
        applySaturation: Bool,
        applyGamma: Bool,
        applyAlpha: Bool) {//-> ShaderProgram {
/*            var key = getShaderKey(
                textureCount: textureCount,
                applyBrightness: applyBrightness,
                applyContrast: applyContrast,
                applyHue: applyHue,
                applySaturation: applySaturation,
                applyGamma: applyGamma,
                applyAlpha: applyAlpha)
            var shader = shaders[key]
            if (shader == nil) {
                var vs = baseVertexShaderString
                var fs =
                (applyBrightness ? "#define APPLY_BRIGHTNESS\n" : "") +
                    (applyContrast ? "#define APPLY_CONTRAST\n" : "") +
                    (applyHue ? "#define APPLY_HUE\n" : "") +
                    (applySaturation ? "#define APPLY_SATURATION\n" : "") +
                    (applyGamma ? "#define APPLY_GAMMA\n" : "") +
                    (applyAlpha ? "#define APPLY_ALPHA\n" : "") +
                    "#define TEXTURE_UNITS " + textureCount + "\n" +
                    baseFragmentShaderString + "\n" +
                    "vec3 computeDayColor(vec3 initialColor, vec2 textureCoordinates)\n" +
                    "{\n" +
                "    vec3 color = initialColor\n"
                
                for i in 0..textureCount {
                    fs +=
                        "color = sampleAndBlend(\n" +
                        "   color,\n" +
                        "   u_dayTextures[" + i + "],\n" +
                        "   textureCoordinates,\n" +
                        "   u_dayTextureTexCoordsRectangle[" + i + "],\n" +
                        "   u_dayTextureTranslationAndScale[" + i + "],\n" +
                        (applyAlpha ?      "   u_dayTextureAlpha[" + i + "],\n" : "1.0,\n") +
                        (applyBrightness ? "   u_dayTextureBrightness[" + i + "],\n" : "0.0,\n") +
                        (applyContrast ?   "   u_dayTextureContrast[" + i + "],\n" : "0.0,\n") +
                        (applyHue ?        "   u_dayTextureHue[" + i + "],\n" : "0.0,\n") +
                        (applySaturation ? "   u_dayTextureSaturation[" + i + "],\n" : "0.0,\n") +
                        (applyGamma ?      "   u_dayTextureOneOverGamma[" + i + "])\n" : "0.0)\n")
                }
                
                fs +=
                    "    return color\n" +
                "}"
                
                shader = context.createShaderProgram(vs, fs, this._attributeLocations)
                self.shaders[key] = shader
            }
            return shader*/
    }
    
    deinit {
        invalidateShaders()
    }
    
}
