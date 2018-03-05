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
    fileprivate (set) var ellipsoid: Ellipsoid

    fileprivate let _command = DrawCommand()

    fileprivate let _rayleighScaleDepth: Float = 0.25

    fileprivate var _rpSkyFromSpace: RenderPipeline? = nil

    fileprivate var _rpSkyFromAtmosphere: RenderPipeline? = nil

    init (ellipsoid: Ellipsoid = Ellipsoid.wgs84()) {
        self.ellipsoid = ellipsoid

        let map = SkyAtmosphereUniformMap()
        map.fOuterRadius = Float(ellipsoid.radii.multiplyBy(scalar: 1.025).maximumComponent())
        map.fOuterRadius2 = map.fOuterRadius * map.fOuterRadius
        map.fInnerRadius = Float(ellipsoid.maximumRadius)
        map.fScale = 1.0 / (map.fOuterRadius - map.fInnerRadius)
        map.fScaleDepth = _rayleighScaleDepth
        map.fScaleOverScaleDepth = map.fScale / map.fScaleDepth
        _command.uniformMap = map
        _command.owner = self
    }

    func update (_ frameState: FrameState) -> DrawCommand? {

        if !show {
            return nil
        }

        if frameState.mode != .scene3D && frameState.mode != SceneMode.morphing {
            return nil
        }

        // The atmosphere is only rendered during the render pass; it is not pickable, it doesn't cast shadows, etc.
        if !frameState.passes.render {
            return nil
        }

        guard let context = frameState.context else {
            return nil
        }

        if _command.vertexArray == nil {
            let geometry = EllipsoidGeometry(
                radii : ellipsoid.radii.multiplyBy(scalar: 1.025),
                stackPartitions : 256,
                slicePartitions : 256,
                vertexFormat : VertexFormat.PositionOnly()
            ).createGeometry(context)

            _command.vertexArray = VertexArray(
                fromGeometry: geometry,
                context: context,
                attributeLocations: GeometryPipeline.createAttributeLocations(geometry)
            )
            _command.renderState = RenderState(
                device: context.device,
                cullFace: .front
            )

            let metalStruct = (_command.uniformMap as! NativeUniformMap).generateMetalUniformStruct()

            _rpSkyFromSpace = RenderPipeline.fromCache(
                context : context,
                vertexShaderSource : ShaderSource(
                    sources: [Shaders["SkyAtmosphereVS"]!],
                    defines: ["SKY_FROM_SPACE"]
                ),
                fragmentShaderSource : ShaderSource(
                    sources: [Shaders["SkyAtmosphereFS"]!]
                ),
                vertexDescriptor: VertexDescriptor(attributes: _command.vertexArray!.attributes),
                depthStencil: context.depthTexture,
                blendingState: .AlphaBlend(),
                manualUniformStruct: metalStruct,
                uniformStructSize: MemoryLayout<SkyAtmosphereUniformStruct>.stride
            )

            _rpSkyFromAtmosphere = RenderPipeline.fromCache(
                context : context,
                vertexShaderSource : ShaderSource(
                    sources: [Shaders["SkyAtmosphereVS"]!],
                    defines: ["SKY_FROM_ATMOSPHERE"]
                ),
                fragmentShaderSource : ShaderSource(
                    sources: [Shaders["SkyAtmosphereFS"]!]
                ),
                vertexDescriptor: VertexDescriptor(attributes: _command.vertexArray!.attributes),
                depthStencil: context.depthTexture,
                blendingState: .AlphaBlend(),
                manualUniformStruct: metalStruct,
                uniformStructSize: MemoryLayout<SkyAtmosphereUniformStruct>.stride
            )

            _command.uniformMap?.uniformBufferProvider = _rpSkyFromSpace!.shaderProgram.createUniformBufferProvider(context.device, deallocationBlock: nil)
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

struct SkyAtmosphereUniformStruct: UniformStruct {
    var u_cameraHeight = Float()
    var u_cameraHeight2 = Float()
    var u_outerRadius = Float()
    var u_outerRadius2 = Float()
    var u_innerRadius = Float()
    var u_scale = Float()
    var u_scaleDepth = Float()
    var u_scaleOverScaleDepth = Float()
}

private class SkyAtmosphereUniformMap: NativeUniformMap {

    var fCameraHeight: Float {
        get {
            return _uniformStruct.u_cameraHeight
        }
        set {
            _uniformStruct.u_cameraHeight = newValue
        }
    }

    var fCameraHeight2: Float {
        get {
            return _uniformStruct.u_cameraHeight2
        }
        set {
            _uniformStruct.u_cameraHeight2 = newValue
        }
    }

    var fOuterRadius: Float {
        get {
            return _uniformStruct.u_outerRadius
        }
        set {
            _uniformStruct.u_outerRadius = newValue
        }
    }

    var fOuterRadius2: Float {
        get {
            return _uniformStruct.u_outerRadius2
        }
        set {
            _uniformStruct.u_outerRadius2 = newValue
        }
    }

    var fInnerRadius: Float {
        get {
            return _uniformStruct.u_innerRadius
        }
        set {
            _uniformStruct.u_innerRadius = newValue
        }
    }

    var fScale: Float {
        get {
            return _uniformStruct.u_scale
        }
        set {
            _uniformStruct.u_scale = newValue
        }
    }

    var fScaleDepth: Float {
        get {
            return _uniformStruct.u_scaleDepth
        }
        set {
            _uniformStruct.u_scaleDepth = newValue
        }
    }

    var fScaleOverScaleDepth: Float {
        get {
            return _uniformStruct.u_scaleOverScaleDepth
        }
        set {
            _uniformStruct.u_scaleOverScaleDepth = newValue
        }
    }

    var uniformBufferProvider: UniformBufferProvider! = nil

    lazy var uniformUpdateBlock: UniformUpdateBlock = { buffer in
        buffer.write(from: &self._uniformStruct, length: MemoryLayout<SkyAtmosphereUniformStruct>.size)
        return []
    }

    fileprivate var _uniformStruct = SkyAtmosphereUniformStruct()

    let uniformDescriptors: [UniformDescriptor] = [
        UniformDescriptor(name: "u_cameraHeight", type: .floatVec1, count: 1),
        UniformDescriptor(name: "u_cameraHeight2", type: .floatVec1, count: 1),
        UniformDescriptor(name: "u_outerRadius", type: .floatVec1, count: 1),
        UniformDescriptor(name: "u_outerRadius2", type: .floatVec1, count: 1),
        UniformDescriptor(name: "u_innerRadius", type: .floatVec1, count: 1),
        UniformDescriptor(name: "u_scale", type: .floatVec1, count: 1),
        UniformDescriptor(name: "u_scaleDepth", type: .floatVec1, count: 1),
        UniformDescriptor(name: "u_scaleOverScaleDepth", type: .floatVec1, count: 1)
    ]

}

