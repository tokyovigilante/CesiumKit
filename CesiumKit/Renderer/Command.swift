//
//  Command.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//


/**
* Renderer command protocol
*/
protocol Command: class {
    
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
    var boundingVolume: Intersectable? { get }
    
    /**
    * When <code>true</code>, the renderer frustum and horizon culls the command based on its {@link DrawCommand#boundingVolume}.
    * If the command was already culled, set this to <code>false</code> for a performance improvement.
    *
    * @type {Boolean}
    * @default true
    */
    var cull: Bool { get }
    
    /**
    * The render state to apply when executing the clear command.  The following states affect clearing:
    * scissor test, color mask, depth mask, and stencil mask.  When the render state is
    * <code>undefined</code>, the default render state is used.
    *
    * @type {RenderState}
    *
    * @default undefined
    *
    * @see Context#createRenderState
    */
    var renderState: RenderState? { get set }
    
    /**
    * The framebuffer to clear.
    *
    * @type {Framebuffer}
    *
    * @default undefined
    */
    var framebuffer: Framebuffer? { get set }
    
    /**
    * The pass when to render.
    *
    * @type {Pass}
    * @default undefined
    */
    var pass: Pass? { get set }
    
    var debugOverlappingFrustums: Int { get set }
    
    var executeInClosestFrustum: Bool { get set }
    
    func execute(context context: Context, passState: PassState?, renderState: RenderState?, shaderProgram: ShaderProgram?)
    
}