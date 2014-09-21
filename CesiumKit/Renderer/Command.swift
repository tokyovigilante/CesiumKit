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
protocol Command {
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
}