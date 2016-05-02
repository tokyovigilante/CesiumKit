//
//  PassState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

/**
* The state for a particular rendering pass.  This is used to supplement the state
* in a command being executed.
*
* @private
*/
class PassState {
    /**
    * The context used to execute commands for this pass.
    *
    * @type {Context}
    */
    weak var context: Context! = nil
    
    /**
    * The framebuffer to render to.  This framebuffer is used unless a {@link DrawCommand}
    * or {@link ClearCommand} explicitly define a framebuffer, which is used for off-screen
    * rendering.
    *
    * @type {Framebuffer}
    * @default undefined
    */
    var framebuffer: Framebuffer! = nil
    
    /**
    * When defined, this overrides the blending property of a {@link DrawCommand}'s render state.
    * This is used to, for example, to allow the renderer to turn off blending during the picking pass.
    * <p>
    * When this is <code>undefined</code>, the {@link DrawCommand}'s property is used.
    * </p>
    *
    * @type {Boolean}
    * @default undefined
    */
    var blendingEnabled: Bool? = nil
    
    /**
    * When defined, this overrides the scissor test property of a {@link DrawCommand}'s render state.
    * This is used to, for example, to allow the renderer to scissor out the pick region during the picking pass.
    * <p>
    * When this is <code>undefined</code>, the {@link DrawCommand}'s property is used.
    * </p>
    *
    * @type {Object}
    * @default undefined
    */
    var scissorTest: RenderState.ScissorTest? = nil

    /**
     * The viewport used when one is not defined by a {@link DrawCommand}'s render state.
     * @type {BoundingRectangle}
     * @default undefined
     */
    var viewport: Cartesian4? = nil
    
}



