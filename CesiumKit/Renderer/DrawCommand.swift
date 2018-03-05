//
//  DrawCommand.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

/**
* Represents a command to the renderer for drawing.
*
* @private
*/
class DrawCommand: Command {

    /**
    * The bounding volume of the geometry in world space.  This is used for culling and frustum selection.
    * <p>
    * For best rendering performance, use the tightest possible bounding volume.  Although
    * <code>undefined</code> is allowed, always try to provide a bounding volume to
    * allow the tightest possible near and far planes to be computed for the scene, and
    * minimize the number of frustums needed.
    * </p>
    *
    * @type {Object}
    * @default undefined
    *
    * @see DrawCommand#debugShowBoundingVolume
    */
    var boundingVolume: BoundingVolume? = nil

    /**
    * The oriented bounding box of the geometry in world space. If this is defined, it is used instead of
    * {@link DrawCommand#boundingVolume} for plane intersection testing.
    *
    * @type {OrientedBoundingBox}
    * @default undefined
    *
    * @see DrawCommand#debugShowBoundingVolume
    */
    var orientedBoundingBox: OrientedBoundingBox? = nil

    /**
    * When <code>true</code>, the renderer frustum and horizon culls the command based on its {@link DrawCommand#boundingVolume}.
    * If the command was already culled, set this to <code>false</code> for a performance improvement.
    *
    * @type {Boolean}
    * @default true
    */
    var cull: Bool

    /**
    * The transformation from the geometry in model space to world space.
    * <p>
    * When <code>undefined</code>, the geometry is assumed to be defined in world space.
    * </p>
    *
    * @type {Matrix4}
    * @default undefined
    */
    var modelMatrix: Matrix4?

    /**
    * The type of geometry in the vertex array.
    *
    * @type {PrimitiveType}
    * @default PrimitiveType.TRIANGLES
    */
    var primitiveType: MTLPrimitiveType = .triangle

    /**
    * The vertex array.
    *
    * @type {VertexArray}
    * @default undefined
    */
    var vertexArray: VertexArray?

    /**
    * The number of vertices to draw in the vertex array.
    *
    * @type {Number}
    * @default undefined
    */
    var count: Int?

    /**
    * The offset to start drawing in the vertex array.
    *
    * @type {Number}
    * @default 0
    */
    var offset: Int = 0

    /**
    * An object with functions whose names match the uniforms in the shader program
    * and return values to set those uniforms.
    *
    * @type {Object}
    * @default undefined
    */
    var uniformMap: UniformMap?

    /**
     * The render state.
     *
     * @type {RenderState}
     * @default undefined
     */
    var renderState: RenderState?

    /**
    * The render pipeline to apply.
    *
    * @type {RenderPipeline}
    * @default undefined
    */
    var pipeline: RenderPipeline? = nil

    /**
    * The pass when to render.
    *
    * @type {Pass}
    * @default undefined
    */
    var pass: Pass = .globe

    /**
    * Specifies if this command is only to be executed in the frustum closest
    * to the eye containing the bounding volume. Defaults to <code>false</code>.
    *
    * @type {Boolean}
    * @default false
    */
    var executeInClosestFrustum: Bool = false

    /**
    * The object who created this command.  This is useful for debugging command
    * execution; it allows us to see who created a command when we only have a
    * reference to the command, and can be used to selectively execute commands
    * with {@link Scene#debugCommandFilter}.
    *
    * @type {Object}
    * @default undefined
    *
    * @see Scene#debugCommandFilter
    */
    var owner: AnyObject? = nil

    /**
     * This property is for debugging only; it is not for production use nor is it optimized.
     * <p>
     * Draws the {@link DrawCommand#boundingVolume} for this command, assuming it is a sphere, when the command executes.
     * </p>
     *
     * @type {Boolean}
     * @default false
     *
     * @see DrawCommand#boundingVolume
     */
    var debugShowBoundingVolume: Bool

    /**
     * Used to implement Scene.debugShowFrustums.
     * @private
     */
    var debugOverlappingFrustums: Int

    /**
    * @private
    */
    //var oit = undefined;

    var dirty: Bool = true

    init(
        boundingVolume: BoundingVolume? = nil,
        orientedBoundingBox: OrientedBoundingBox? = nil,
        cull: Bool = true,
        modelMatrix: Matrix4? = nil,
        primitiveType: MTLPrimitiveType = .triangle,
        vertexArray: VertexArray? = nil,
        count: Int? = nil,
        offset: Int = 0,
        uniformMap: UniformMap? = nil,
        renderState: RenderState? = nil,
        renderPipeline: RenderPipeline? = nil,
        pass: Pass = .globe,
        executeInClosestFrustum: Bool = false,
        owner: AnyObject? = nil,
        debugShowBoundingVolume: Bool = false,
        debugOverlappingFrustums: Int = 0
        ) {
            self.boundingVolume = boundingVolume
            self.cull = cull
            self.primitiveType = primitiveType
            self.vertexArray = vertexArray
            self.count = count
            self.offset = offset
            self.pipeline = renderPipeline
            self.renderState = renderState
            self.pass = pass
            self.executeInClosestFrustum = executeInClosestFrustum
            self.owner = owner
            self.debugShowBoundingVolume = debugShowBoundingVolume
            self.debugOverlappingFrustums = debugOverlappingFrustums
            self.uniformMap = uniformMap
    }

    /**
    * Executes the draw command.
    *
    * @param {Context} context The renderer context in which to draw.
    * @param {RenderPass} [renderPass] The render pass this command is part of.
    * @param {RenderState} [renderState] The render state that will override the render state of the command.
    * @param {RenderPipeline} [renderPipeline] The render pipeline that will override the shader program of the command.
    */
    func execute(_ context: Context, renderPass: RenderPass, frustumUniformBuffer: Buffer? = nil) {
        context.draw(self, renderPass: renderPass, frustumUniformBuffer: frustumUniformBuffer)
    }

    deinit {
        guard let provider = uniformMap?.uniformBufferProvider else {
            return
        }
        provider.deallocationBlock?(provider)
    }

}
