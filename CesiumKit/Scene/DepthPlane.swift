//
//  DepthPlane.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/11/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

class DepthPlane {

    /**
    * @private
    */
    fileprivate var _rs: RenderState? = nil
    fileprivate var _attributes: [VertexAttributes]? = nil
    fileprivate var _pipeline: RenderPipeline? = nil
    fileprivate var _va: VertexArray? = nil
    fileprivate var _command: DrawCommand? = nil
    fileprivate var _mode: SceneMode = .scene3D

    fileprivate func computeDepthQuad(_ ellipsoid: Ellipsoid, frameState: FrameState) -> [Float] {
        let radii = ellipsoid.radii
        let p = frameState.camera!.positionWC

        // Find the corresponding position in the scaled space of the ellipsoid.
        let q = ellipsoid.oneOverRadii.multiplyComponents(p)

        let qMagnitude = q.magnitude
        let qUnit = q.normalize()

        // Determine the east and north directions at q.
        let eUnit = Cartesian3.unitZ.cross(q).normalize()
        let nUnit = qUnit.cross(eUnit).normalize()

        // Determine the radius of the 'limb' of the ellipsoid.
        let wMagnitude = sqrt(q.magnitudeSquared - 1.0)

        // Compute the center and offsets.
        let center = qUnit.multiplyBy(scalar: 1.0 / qMagnitude)
        let scalar = wMagnitude / qMagnitude
        let eastOffset = eUnit.multiplyBy(scalar: scalar)
        let northOffset = nUnit.multiplyBy(scalar: scalar)

        var depthQuad = [Float](repeating: 0.0, count: 12)
        // A conservative measure for the longitudes would be to use the min/max longitudes of the bounding frustum.
        let upperLeft = center
            .add(northOffset)
            .subtract(eastOffset)
        radii.multiplyComponents(upperLeft).pack(&depthQuad, startingIndex: 0)

        let lowerLeft = center
            .subtract(northOffset)
            .subtract(eastOffset)
        radii.multiplyComponents(lowerLeft).pack(&depthQuad, startingIndex: 3)

        let upperRight = center
            .add(northOffset)
            .add(eastOffset)
        radii.multiplyComponents(upperRight).pack(&depthQuad, startingIndex: 6)

        let lowerRight = center
            .subtract(northOffset)
            .add(eastOffset)
        radii.multiplyComponents(lowerRight).pack(&depthQuad, startingIndex: 9)

        return depthQuad
    }

    func update (_ frameState: FrameState) {
        _mode = frameState.mode

        if frameState.mode != .scene3D {
            return
        }

        let ellipsoid = frameState.mapProjection.ellipsoid
        guard let context = frameState.context else {
            return
        }

        if _command == nil {
            _rs = RenderState( // Write depth, not color
                device: context.device,
                cullFace: .back,
                depthTest: RenderState.DepthTest(
                    enabled: true,
                    function: .always
                )
            )
            // position
            _attributes = [VertexAttributes(
                buffer: nil,
                bufferIndex: VertexDescriptorFirstBufferOffset,
                index: 0,
                format: .float3,
                offset: 0,
                size: MemoryLayout<Float>.stride * 3,
                normalize: false
                )]
            _pipeline = RenderPipeline.fromCache(
                context: context,
                vertexShaderSource: ShaderSource(sources: [Shaders["DepthPlaneVS"]!]),
                fragmentShaderSource: ShaderSource(sources: [Shaders["DepthPlaneFS"]!]),
                vertexDescriptor: VertexDescriptor(attributes: _attributes!),
                colorMask: ColorMask(
                    red: false,
                    green: false,
                    blue: false,
                    alpha: false
                ),
                depthStencil: context.depthTexture
            )
            _command = DrawCommand(
                boundingVolume: BoundingSphere(
                    center: Cartesian3.zero,
                    radius: ellipsoid.maximumRadius),
                renderState: _rs,
                renderPipeline: _pipeline,
                pass: .opaque,
                owner: self
            )
        }
        // update depth plane
        let depthQuad = computeDepthQuad(ellipsoid, frameState: frameState)

        // depth plane
        if _va == nil {
            let geometry = Geometry(
                attributes: GeometryAttributes(
                    position: GeometryAttribute(
                        componentDatatype : .float32,
                        componentsPerAttribute: 3,
                        values: Buffer(
                            device: context.device,
                            array: depthQuad,
                            componentDatatype: .float32,
                            sizeInBytes: depthQuad.sizeInBytes,
                            label: "DepthPlaneGeometry"
                        )
                    )

                ),
                indices : [0, 1, 2, 2, 1, 3],
                primitiveType : .triangle
            )

            _va = VertexArray(
                fromGeometry: geometry,
                context : context,
                attributeLocations: ["position": 0]
            )
            _command!.vertexArray = _va
        } else {
            _va!.attributes[0].buffer?.write(from: depthQuad, length: depthQuad.sizeInBytes)
        }
    }

    func execute (_ context: Context, renderPass: RenderPass, frustumUniformBuffer: Buffer? = nil) {
        if _mode == SceneMode.scene3D {
            _command?.execute(context, renderPass: renderPass, frustumUniformBuffer: frustumUniformBuffer)
        }
    }

}
