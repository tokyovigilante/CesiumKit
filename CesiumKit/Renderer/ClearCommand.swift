//
//  File.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

/**
* Represents a command to the renderer for clearing a framebuffer.
*
* @private
*/
struct ClearCommand {

    let boundingVolume: BoundingVolume? = nil
    let cull: Bool = false

    /**
    * The value to clear the color buffer to.  When <code>undefined</code>, the color buffer is not cleared.
    *
    * @type {Color}
    *
    * @default undefined
    */
    var color: Color?

    /**
    * The value to clear the depth buffer to.  When <code>undefined</code>, the depth buffer is not cleared.
    *
    * @type {Number}
    *
    * @default undefined
    */
    var depth: Double?

    /**
    * The value to clear the stencil buffer to.  When <code>undefined</code>, the stencil buffer is not cleared.
    *
    * @type {Number}
    *
    * @default undefined
    */
    var stencil: UInt32?

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
    var renderState: RenderState?

    /**
    * The framebuffer to clear.
    *
    * @type {Framebuffer}
    *
    * @default undefined
    */
    var framebuffer: Framebuffer?

    /**
    * The object who created this command.  This is useful for debugging command
    * execution; it allows you to see who created a command when you only have a
    * reference to the command, and can be used to selectively execute commands
    * with {@link Scene#debugCommandFilter}.
    *
    * @type {Object}
    *
    * @default undefined
    *
    * @see Scene#debugCommandFilter
    */
    // FIXME: Owner
    weak var owner: AnyObject? = nil

    var debugOverlappingFrustums: Int = 0
    var executeInClosestFrustum: Bool = false

    /**
    * Clears color to (0.0, 0.0, 0.0, 0.0); depth to 1.0; and stencil to 0.
    *
    * @type {ClearCommand}
    *
    * @constant
    */
    init (color: Cartesian4? = nil, depth: Double? = nil, stencil: UInt32? = nil, renderState: RenderState? = nil, framebuffer: Framebuffer? = nil, owner: AnyObject? = nil) {

        self.color = color
        self.depth = depth
        self.stencil = stencil
        self.renderState = renderState
        self.framebuffer = framebuffer
        self.owner = owner
    }

    static func all() -> ClearCommand {
        return ClearCommand(color: Cartesian4(), depth: 1.0, stencil: 1, renderState: nil)
    }

    func execute(_ context: Context, passState: PassState?) {
        context.clear(self, passState: passState)
    }

}
