//
//  GlobeSurfaceShaderSet.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

struct GlobeSurfaceShader {
    
    var numberOfDayTextures: Int
    
    var flags: Int
    
    var shaderProgram: ShaderProgram
}

/**
* Manages the shaders used to shade the surface of a {@link Globe}.
*
* @alias GlobeSurfaceShaderSet
* @private
*/
class GlobeSurfaceShaderSet {
    
    var baseVertexShaderSource: ShaderSource
    var baseFragmentShaderSource: ShaderSource
    
    let attributeLocations: [String: Int]
    
    var _shadersByTexturesFlags = [Int: [Int: GlobeSurfaceShader]]()
    
    init (
        baseVertexShaderSource: ShaderSource,
        baseFragmentShaderSource: ShaderSource,
        attributeLocations: [String: Int]) {
            self.baseVertexShaderSource = baseVertexShaderSource
            self.baseFragmentShaderSource = baseFragmentShaderSource
            self.attributeLocations = attributeLocations
    }
    
    func getShaderProgram (context context: Context, sceneMode: SceneMode, surfaceTile: GlobeSurfaceTile, numberOfDayTextures: Int, applyBrightness: Bool, applyContrast: Bool, applyHue: Bool, applySaturation: Bool, applyGamma: Bool, applyAlpha: Bool, showReflectiveOcean: Bool, showOceanWaves: Bool, enableLighting: Bool, hasVertexNormals: Bool, useWebMercatorProjection: Bool) -> ShaderProgram {
        
        let flags: Int = Int(sceneMode.rawValue) |
            (Int(applyBrightness) << 2) |
            (Int(applyContrast) << 3) |
            (Int(applyHue) << 4) |
            (Int(applySaturation) << 5) |
            (Int(applyGamma) << 6) |
            (Int(applyAlpha) << 7) |
            (Int(showReflectiveOcean) << 8) |
            (Int(showOceanWaves) << 9) |
            (Int(enableLighting) << 10) |
            (Int(hasVertexNormals) << 11) |
            (Int(useWebMercatorProjection) << 12)
        
        var surfaceShader = surfaceTile.surfaceShader
        if surfaceShader != nil && surfaceShader!.numberOfDayTextures == numberOfDayTextures && surfaceShader!.flags == flags {
            return surfaceShader!.shaderProgram
        }
        
        // New tile, or tile changed number of textures or flags.
        var shadersByFlags = _shadersByTexturesFlags[numberOfDayTextures]
        if shadersByFlags == nil {
            _shadersByTexturesFlags[numberOfDayTextures] = [Int: GlobeSurfaceShader]()
            shadersByFlags = _shadersByTexturesFlags[numberOfDayTextures]
        }
        
        surfaceShader = shadersByFlags![flags]
        if surfaceShader == nil {
            // Cache miss - we've never seen this combination of numberOfDayTextures and flags before.
            var vs = baseVertexShaderSource
            var fs = baseFragmentShaderSource
            
            fs.defines.append("TEXTURE_UNITS \(numberOfDayTextures)")
            
            if applyBrightness {
                fs.defines.append("APPLY_BRIGHTNESS")
            }
            if (applyContrast) {
                fs.defines.append("APPLY_CONTRAST")
            }
            if (applyHue) {
                fs.defines.append("APPLY_HUE")
            }
            if (applySaturation) {
                fs.defines.append("APPLY_SATURATION")
            }
            if (applyGamma) {
                fs.defines.append("APPLY_GAMMA")
            }
            if (applyAlpha) {
                fs.defines.append("APPLY_ALPHA")
            }
            if (showReflectiveOcean) {
                fs.defines.append("SHOW_REFLECTIVE_OCEAN")
                vs.defines.append("SHOW_REFLECTIVE_OCEAN")
            }
            if (showOceanWaves) {
                fs.defines.append("SHOW_OCEAN_WAVES")
            }
            
            if enableLighting {
                if hasVertexNormals {
                    vs.defines.append("ENABLE_VERTEX_LIGHTING")
                    fs.defines.append("ENABLE_VERTEX_LIGHTING")
                } else {
                    vs.defines.append("ENABLE_DAYNIGHT_SHADING")
                    fs.defines.append("ENABLE_DAYNIGHT_SHADING")
                }
            }
            
            var computeDayColor = "vec4 computeDayColor(vec4 initialColor, vec2 textureCoordinates)\n{    \nvec4 color = initialColor;\n"
            
            for i in 0..<numberOfDayTextures {
                computeDayColor += "color = sampleAndBlend(\ncolor,\nu_dayTextures[\(i)],\n" +
                    "textureCoordinates,\n" +
                    "u_dayTextureTexCoordsRectangle[\(i)],\n" +
                    "u_dayTextureTranslationAndScale[\(i)],\n" +
                    (applyAlpha ? "u_dayTextureAlpha[\(i)]" : "1.0") + ",\n" +
                    (applyBrightness ? "u_dayTextureBrightness[\(i)]" : "0.0") + ",\n" +
                    (applyContrast ? "u_dayTextureContrast[\(i)]" : "0.0") + ",\n" +
                    (applyHue ? "u_dayTextureHue[\(i)]" : "0.0") + ",\n" +
                    (applySaturation ? "u_dayTextureSaturation[\(i)]" : "0.0") + ",\n" +
                    (applyGamma ? "u_dayTextureOneOverGamma[\(i)]" : "0.0") + "\n" +
                ");\n"
            }
            
            computeDayColor += "return color;\n}"
            
            fs.sources.append(computeDayColor)
            
            let getPosition3DMode = "vec4 getPosition(vec3 position3DWC) { return getPosition3DMode(position3DWC); }"
            let getPosition2DMode = "vec4 getPosition(vec3 position3DWC) { return getPosition2DMode(position3DWC); }"
            let getPositionColumbusViewMode = "vec4 getPosition(vec3 position3DWC) { return getPositionColumbusViewMode(position3DWC); }"
            let getPositionMorphingMode = "vec4 getPosition(vec3 position3DWC) { return getPositionMorphingMode(position3DWC); }"
            
            let getPositionMode: String
            
            switch sceneMode {
            case .Scene3D:
                getPositionMode = getPosition3DMode
            case .Scene2D:
                getPositionMode = getPosition2DMode
            case .ColumbusView:
                getPositionMode = getPositionColumbusViewMode
            case .Morphing:
                getPositionMode = getPositionMorphingMode
            }
            
            vs.sources.append(getPositionMode)
            
            let get2DYPositionFractionGeographicProjection = "float get2DYPositionFraction() { return get2DGeographicYPositionFraction(); }"
            let get2DYPositionFractionMercatorProjection = "float get2DYPositionFraction() { return get2DMercatorYPositionFraction(); }"
            
            let get2DYPositionFraction: String
            
            if useWebMercatorProjection {
                get2DYPositionFraction = get2DYPositionFractionMercatorProjection
            } else {
                get2DYPositionFraction = get2DYPositionFractionGeographicProjection
            }
            
            vs.sources.append(get2DYPositionFraction)
            
            let shader = context.createShaderProgram(vertexShaderSource: vs, fragmentShaderSource: fs, attributeLocations: attributeLocations)
            shadersByFlags![flags] = GlobeSurfaceShader(numberOfDayTextures: numberOfDayTextures, flags: flags, shaderProgram: shader!)

            surfaceShader = shadersByFlags![flags]
        }
        _shadersByTexturesFlags[numberOfDayTextures] = shadersByFlags!
        surfaceTile.surfaceShader = surfaceShader
        return surfaceShader!.shaderProgram
    }
    
    deinit {
        // ARC should deinit shaders
    }
    
}
