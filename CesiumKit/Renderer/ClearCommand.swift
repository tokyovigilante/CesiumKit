//
//  File.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* Represents a command to the renderer for clearing a framebuffer.
*
* @private
*/
struct ClearCommand {
    
    /**
    * The value to clear the color buffer to.  When <code>undefined</code>, the color buffer is not cleared.
    *
    * @type {Color}
    *
    * @default undefined
    */
    var color: Cartesian4 = nil
    
    /**
    * The value to clear the depth buffer to.  When <code>undefined</code>, the depth buffer is not cleared.
    *
    * @type {Number}
    *
    * @default undefined
    */
    var depth: Int = nil
    
    /**
    * The value to clear the stencil buffer to.  When <code>undefined</code>, the stencil buffer is not cleared.
    *
    * @type {Number}
    *
    * @default undefined
    */
    var stencil: Int = nil
    
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
    var renderState: RenderState = nil
    
    /**
    * The framebuffer to clear.
    *
    * @type {Framebuffer}
    *
    * @default undefined
    */
    var framebuffer: Framebuffer = nil
    
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
    var owner: AnyObject = nil
    
    /**
    * Clears color to (0.0, 0.0, 0.0, 0.0); depth to 1.0; and stencil to 0.
    *
    * @type {ClearCommand}
    *
    * @constant
    */
    static func all() -> ClearCommand {
        var result = ClearCommand()
        result.color = Cartesian4()
        result.depth = 1.0
        result.stencil = 1.0
        return object
    }
    
    func execute(context: Context, passState: PassState) {
        context.clear(this, passState)
    }
    
}
