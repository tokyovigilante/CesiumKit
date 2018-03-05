//
//  GlobeSurfaceShaderSet.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

struct GlobeSurfacePipeline {

    var numberOfDayTextures: Int

    var flags: Int

    var pipeline: RenderPipeline
}

/**
* Manages the shaders used to shade the surface of a {@link Globe}.
*
* @alias GlobeSurfaceShaderSet
* @private
*/
class GlobeSurfaceShaderSet {

    let baseVertexShaderSource: ShaderSource
    let baseFragmentShaderSource: ShaderSource

    fileprivate var _pipelinesByTexturesFlags = [Int: [Int: GlobeSurfacePipeline]]()
    fileprivate var _pickPipelines = [Int: RenderPipeline]()

    init (
        baseVertexShaderSource: ShaderSource,
        baseFragmentShaderSource: ShaderSource) {
            self.baseVertexShaderSource = baseVertexShaderSource
            self.baseFragmentShaderSource = baseFragmentShaderSource
    }

    fileprivate func getPositionMode(_ sceneMode: SceneMode) -> String {
        let getPosition3DMode = "vec4 getPosition(vec3 position, float height, vec2 textureCoordinates) { return getPosition3DMode(position, height, textureCoordinates); }"
        let getPosition2DMode = "vec4 getPosition(vec3 position, float height, vec2 textureCoordinates) { return getPosition2DMode(position, height, textureCoordinates); }"
        let getPositionColumbusViewMode = "vec4 getPosition(vec3 position, float height, vec2 textureCoordinates) { return getPositionColumbusViewMode(position, height, textureCoordinates); }"
        let getPositionMorphingMode = "vec4 getPosition(vec3 position, float height, vec2 textureCoordinates) { return getPositionMorphingMode(position, height, textureCoordinates); }"

        let positionMode: String

        switch sceneMode {
        case SceneMode.scene3D:
            positionMode = getPosition3DMode
        case SceneMode.scene2D:
            positionMode = getPosition2DMode
        case SceneMode.columbusView:
            positionMode = getPositionColumbusViewMode
        case SceneMode.morphing:
            positionMode = getPositionMorphingMode
        }

        return positionMode
    }

    func get2DYPositionFraction(_ useWebMercatorProjection: Bool) -> String {
        let get2DYPositionFractionGeographicProjection = "float get2DYPositionFraction(vec2 textureCoordinates) { return get2DGeographicYPositionFraction(textureCoordinates); }"
        let get2DYPositionFractionMercatorProjection = "float get2DYPositionFraction(vec2 textureCoordinates) { return get2DMercatorYPositionFraction(textureCoordinates); }"
        return useWebMercatorProjection ? get2DYPositionFractionMercatorProjection : get2DYPositionFractionGeographicProjection
    }

    fileprivate let uniformStructString = "struct xlatMtlShaderUniform {\n    float4 u_dayTextureTexCoordsRectangle [31];\n    float4 u_dayTextureTranslationAndScale [31];\n    float u_dayTextureAlpha [31];\n    float u_dayTextureBrightness [31];\n    float u_dayTextureContrast [31];\n    float u_dayTextureHue [31];\n    float u_dayTextureSaturation [31];\n    float u_dayTextureOneOverGamma [31];\n    float2 u_minMaxHeight;\n    float4x4 u_scaleAndBias;\n    float4 u_waterMaskTranslationAndScale;\n    float4 u_initialColor;\n    float4 u_tileRectangle;\n    float4x4 u_modifiedModelView;\n    float3 u_center3D;\n    float2 u_southMercatorYAndOneOverHeight;\n    float2 u_southAndNorthLatitude;\n    float2 u_lightingFadeDistance;\n    float u_zoomedOutOceanSpecularIntensity;\n};\n"

    func getRenderPipeline (
        frameState: FrameState,
        surfaceTile: GlobeSurfaceTile,
        numberOfDayTextures: Int,
        applyBrightness: Bool,
        applyContrast: Bool,
        applyHue: Bool,
        applySaturation: Bool,
        applyGamma: Bool,
        applyAlpha: Bool,
        showReflectiveOcean: Bool,
        showOceanWaves: Bool,
        enableLighting: Bool,
        hasVertexNormals: Bool,
        useWebMercatorProjection: Bool,
        enableFog: Bool
     ) -> RenderPipeline
    {


        let terrainEncoding = surfaceTile.pickTerrain!.mesh!.encoding
        let quantizationMode = terrainEncoding.quantization
        let quantization = quantizationMode.enabled
        let quantizationDefine = quantizationMode.define

        let sceneMode = frameState.mode

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
            (Int(useWebMercatorProjection) << 12) |
            (Int(enableFog) << 13) |
            (Int(quantization) << 14)

        var surfacePipeline = surfaceTile.surfacePipeline
        if surfacePipeline != nil && surfacePipeline!.numberOfDayTextures == numberOfDayTextures && surfacePipeline!.flags == flags {
            return surfacePipeline!.pipeline
        }

        // New tile, or tile changed number of textures or flags.
        var pipelinesByFlags = _pipelinesByTexturesFlags[numberOfDayTextures]
        if pipelinesByFlags == nil {
            _pipelinesByTexturesFlags[numberOfDayTextures] = [Int: GlobeSurfacePipeline]()
            pipelinesByFlags = _pipelinesByTexturesFlags[numberOfDayTextures]
        }

        surfacePipeline = pipelinesByFlags![flags]
        if surfacePipeline == nil {
            // Cache miss - we've never seen this combination of numberOfDayTextures and flags before.
            var vs = baseVertexShaderSource
            var fs = baseFragmentShaderSource

            vs.defines.append(quantizationDefine)
            fs.defines.append("TEXTURE_UNITS \(numberOfDayTextures)")

            // Account for Metal not supporting sampler arrays
            if numberOfDayTextures > 0 {
                var textureArrayDefines = "\n"
                for i in 0..<numberOfDayTextures {
                    textureArrayDefines += "uniform sampler2D u_dayTexture\(i);\n"
                }
                textureArrayDefines += "uniform vec4 u_dayTextureTranslationAndScale[TEXTURE_UNITS];\nuniform float u_dayTextureAlpha[TEXTURE_UNITS];\nuniform float u_dayTextureBrightness[TEXTURE_UNITS];\nuniform float u_dayTextureContrast[TEXTURE_UNITS];\nuniform float u_dayTextureHue[TEXTURE_UNITS];\nuniform float u_dayTextureSaturation[TEXTURE_UNITS];\nuniform float u_dayTextureOneOverGamma[TEXTURE_UNITS];\nuniform vec4 u_dayTextureTexCoordsRectangle[TEXTURE_UNITS];\n"

                fs.sources.insert(textureArrayDefines, at: 0)
            }

            if applyBrightness {
                fs.defines.append("APPLY_BRIGHTNESS")
            }
            if applyContrast {
                fs.defines.append("APPLY_CONTRAST")
            }
            if applyHue {
                fs.defines.append("APPLY_HUE")
            }
            if applySaturation {
                fs.defines.append("APPLY_SATURATION")
            }
            if applyGamma {
                fs.defines.append("APPLY_GAMMA")
            }
            if applyAlpha {
                fs.defines.append("APPLY_ALPHA")
            }
            if showReflectiveOcean {
                fs.defines.append("SHOW_REFLECTIVE_OCEAN")
                vs.defines.append("SHOW_REFLECTIVE_OCEAN")
            }
            if showOceanWaves {
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
            if enableFog {
                vs.defines.append("FOG")
                fs.defines.append("FOG")
            }

            var computeDayColor = "vec4 computeDayColor(vec4 initialColor, vec2 textureCoordinates)\n{    \nvec4 color = initialColor;\n"

            for i in 0..<numberOfDayTextures {
                computeDayColor += "color = sampleAndBlend(\ncolor,\nu_dayTexture\(i),\n"
                computeDayColor += "textureCoordinates,\n"
                computeDayColor += "u_dayTextureTexCoordsRectangle[\(i)],\n"
                computeDayColor += "u_dayTextureTranslationAndScale[\(i)],\n"
                computeDayColor += (applyAlpha ? "u_dayTextureAlpha[\(i)]" : "1.0") + ",\n"
                computeDayColor += (applyBrightness ? "u_dayTextureBrightness[\(i)]" : "0.0") + ",\n"
                computeDayColor += (applyContrast ? "u_dayTextureContrast[\(i)]" : "0.0") + ",\n"
                computeDayColor += (applyHue ? "u_dayTextureHue[\(i)]" : "0.0") + ",\n"
                computeDayColor += (applySaturation ? "u_dayTextureSaturation[\(i)]" : "0.0") + ",\n"
                computeDayColor += (applyGamma ? "u_dayTextureOneOverGamma[\(i)]" : "0.0") + "\n"
                computeDayColor += ");\n"
/*                computeDayColor += "color = sampleAndBlend(\ncolor,\nu_dayTexture\(i),\n" +
 "textureCoordinates,\n" +
 "u_dayTextureTexCoordsRectangle[\(i)],\n" +
 "u_dayTextureTranslationAndScale[\(i)],\n" +
 (applyAlpha ? "u_dayTextureAlpha[\(i)]" : "1.0") + ",\n" +
 (applyBrightness ? "u_dayTextureBrightness[\(i)]" : "0.0") + ",\n" +
 (applyContrast ? "u_dayTextureContrast[\(i)]" : "0.0") + ",\n" +
 (applyHue ? "u_dayTextureHue[\(i)]" : "0.0") + ",\n" +
 (applySaturation ? "u_dayTextureSaturation[\(i)]" : "0.0") + ",\n" +
 (applyGamma ? "u_dayTextureOneOverGamma[\(i)]" : "0.0") + "\n" +
 ");\n"*/
            }

            computeDayColor += "return color;\n}"

            fs.sources.append(computeDayColor)

            vs.sources.append(getPositionMode(sceneMode))
            vs.sources.append(get2DYPositionFraction(useWebMercatorProjection))

            let pipeline = RenderPipeline.fromCache(
                context: frameState.context,
                vertexShaderSource: vs,
                fragmentShaderSource: fs,
                vertexDescriptor: VertexDescriptor(attributes:  terrainEncoding.vertexAttributes),
                colorMask: nil,
                depthStencil: frameState.context.depthTexture,
                manualUniformStruct: uniformStructString,
                uniformStructSize: MemoryLayout<TileUniformStruct>.size
            )
            pipelinesByFlags![flags] = GlobeSurfacePipeline(numberOfDayTextures: numberOfDayTextures, flags: flags, pipeline: pipeline)

            surfacePipeline = pipelinesByFlags![flags]
        }
        _pipelinesByTexturesFlags[numberOfDayTextures] = pipelinesByFlags!
        surfaceTile.surfacePipeline = surfacePipeline
        return surfacePipeline!.pipeline
    }

    func getPickRenderPipeline(_ frameState: FrameState, surfaceTile: GlobeSurfaceTile, useWebMercatorProjection: Bool) -> RenderPipeline {

        let terrainEncoding = surfaceTile.pickTerrain!.mesh!.encoding
        let quantizationMode = terrainEncoding.quantization
        let quantization = quantizationMode.enabled
        let quantizationDefine = quantizationMode.define

        let sceneMode = frameState.mode

        let flags = sceneMode.rawValue | (Int(useWebMercatorProjection) << 2) | (Int(quantization) << 3)

        var pickShader: RenderPipeline! = _pickPipelines[flags]
        if pickShader == nil {
            var vs = baseVertexShaderSource
            vs.defines.append(quantizationDefine)
            vs.sources.append(getPositionMode(sceneMode))
            vs.sources.append(get2DYPositionFraction(useWebMercatorProjection))

            // pass through fragment shader. only depth is rendered for the globe on a pick pass
            let fs = ShaderSource(sources: [
                "void main()\n" +
                    "{\n" +
                    "    gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);\n" +
                "}\n"
                ])

            pickShader = RenderPipeline.fromCache(
                context : frameState.context,
                vertexShaderSource : vs,
                fragmentShaderSource : fs,
                vertexDescriptor: VertexDescriptor(attributes:  terrainEncoding.vertexAttributes),
                colorMask: ColorMask(
                    red : false,
                    green : false,
                    blue : false,
                    alpha : false
                ),
                depthStencil: true
            )
            _pickPipelines[flags] = pickShader
        }

        return pickShader
    }

    deinit {
        // ARC should deinit shaders
    }

}
