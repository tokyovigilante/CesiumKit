//
//  SkyAtmosphere.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 13/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
 * An atmosphere drawn around the limb of the provided ellipsoid.  Based on
 * {@link http://http.developer.nvidia.com/GPUGems2/gpugems2_chapter16.html|Accurate Atmospheric Scattering}
 * in GPU Gems 2.
 * <p>
 * This is only supported in 3D.  atmosphere is faded out when morphing to 2D or Columbus view.
 * </p>
 *
 * @alias SkyAtmosphere
 * @constructor
 *
 * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid that the atmosphere is drawn around.
 *
 * @example
 * scene.skyAtmosphere = new Cesium.SkyAtmosphere();
 *
 * @see Scene.skyAtmosphere
 */
class SkyAtmosphere {
    
    /**
    * Determines if the atmosphere is shown.
    *
    * @type {Boolean}
    * @default true
    */
    var show = true
    
    /**
     * Gets the ellipsoid the atmosphere is drawn around.
     * @memberof SkyAtmosphere.prototype
     *
     * @type {Ellipsoid}
     * @readonly
     */
    private (set) var ellipsoid: Ellipsoid
    
    private let _command = DrawCommand()
    
    private let _rayleighScaleDepth: Float = 0.25
    
    private var _rpSkyFromSpace: RenderPipeline? = nil
    
    private var _rpSkyFromAtmosphere: RenderPipeline? = nil
    
    init (ellipsoid: Ellipsoid = Ellipsoid.wgs84()) {
        self.ellipsoid = ellipsoid

        let map = SkyAtmosphereUniformMap()
        map.fOuterRadius = Float(ellipsoid.radii.multiplyByScalar(1.025).maximumComponent())
        map.fOuterRadius2 = map.fOuterRadius * map.fOuterRadius
        map.fInnerRadius = Float(ellipsoid.maximumRadius)
        map.fScale = 1.0 / (map.fOuterRadius - map.fInnerRadius)
        map.fScaleDepth = _rayleighScaleDepth
        map.fScaleOverScaleDepth = map.fScale / map.fScaleDepth
        _command.uniformMap = map
        _command.owner = self
    }
    
    func update (context: Context, frameState: FrameState) -> DrawCommand? {

        if !show {
            return nil
        }
        
        if frameState.mode != .Scene3D && frameState.mode != SceneMode.Morphing {
            return nil
        }
        
        // The atmosphere is only rendered during the render pass; it is not pickable, it doesn't cast shadows, etc.
        if !frameState.passes.render {
            return nil
        }
    
        if _command.vertexArray == nil {
            let geometry = EllipsoidGeometry(
                radii : ellipsoid.radii.multiplyByScalar(1.025),
                slicePartitions : 256,
                stackPartitions : 256,
                vertexFormat : VertexFormat.PositionOnly()
            ).createGeometry(context)
            
            _command.vertexArray = VertexArray(
                fromGeometry: geometry,
                context: context,
                attributeLocations: GeometryPipeline.createAttributeLocations(geometry)
            )
            //FIXME: blending
            _command.renderState = RenderState(
                device: context.device,
                cullFace: .Front
            )
            
            _rpSkyFromSpace = RenderPipeline.fromCache(
                context : context,
                vertexShaderSource : ShaderSource(
                    defines: ["SKY_FROM_SPACE"],
                    sources: [Shaders["SkyAtmosphereVS"]!]
                ),
                fragmentShaderSource : ShaderSource(
                    sources: [Shaders["SkyAtmosphereFS"]!]
                ),
                vertexDescriptor: VertexDescriptor(attributes: _command.vertexArray!.attributes),
                depthStencil: context.depthTexture,
                blendingState: .AlphaBlend()
            )
            
            
            _rpSkyFromAtmosphere = RenderPipeline.fromCache(
                context : context,
                vertexShaderSource : ShaderSource(
                    defines: ["SKY_FROM_ATMOSPHERE"],
                    sources: [Shaders["SkyAtmosphereVS"]!]
                ),
                fragmentShaderSource : ShaderSource(
                    sources: [Shaders["SkyAtmosphereFS"]!]
                ),
                vertexDescriptor: VertexDescriptor(attributes: _command.vertexArray!.attributes),
                depthStencil: context.depthTexture,
                blendingState: .AlphaBlend()
            )
            _command.uniformBufferProvider = _rpSkyFromSpace!.shaderProgram.createUniformBufferProvider(context.device)
            
        }
    
        let cameraPosition = frameState.camera!.positionWC
        let map = _command.uniformMap as! SkyAtmosphereUniformMap
        map.fCameraHeight2 = Float(cameraPosition.magnitudeSquared)
        map.fCameraHeight = sqrt(map.fCameraHeight2)
        
        if map.fCameraHeight > map.fOuterRadius {
            // Camera in space
            _command.pipeline = _rpSkyFromSpace
        } else {
            // Camera in atmosphere
            _command.pipeline = _rpSkyFromAtmosphere
        }
        return _command
    }

}

private class SkyAtmosphereUniformMap: UniformMap {
    
    var fCameraHeight = Float.NaN
    
    var fCameraHeight2 = Float.NaN
    
    var fOuterRadius = Float.NaN
    
    var fOuterRadius2 = Float.NaN
    
    var fInnerRadius = Float.NaN
    
    var fScale = Float.NaN
    
    var fScaleDepth = Float.NaN
    
    var fScaleOverScaleDepth = Float.NaN

    let uniforms: [String: UniformFunc] = [
        
        "fCameraHeight": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! SkyAtmosphereUniformMap).fCameraHeight], sizeof(Float))
        },
        
        "fCameraHeight2": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! SkyAtmosphereUniformMap).fCameraHeight2], sizeof(Float))
        },
        
        "fOuterRadius": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! SkyAtmosphereUniformMap).fOuterRadius], sizeof(Float))
        },
        
        "fOuterRadius2": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! SkyAtmosphereUniformMap).fOuterRadius2], sizeof(Float))
        },
        
        "fInnerRadius": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! SkyAtmosphereUniformMap).fInnerRadius], sizeof(Float))
        },
        
        "fScale": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! SkyAtmosphereUniformMap).fScale], sizeof(Float))
        },
        
        "fScaleDepth": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! SkyAtmosphereUniformMap).fScaleDepth], sizeof(Float))
        },
        
        "fScaleOverScaleDepth": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! SkyAtmosphereUniformMap).fScaleOverScaleDepth], sizeof(Float))
        }
        
    ]

}

