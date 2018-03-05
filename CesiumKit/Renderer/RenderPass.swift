//
//  CommandEncoder.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 13/07/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Metal

/**
* The state for a particular rendering pass.  This is used to supplement the state
* in a command being executed.
*
* @private
*/
class RenderPass {

    /**
    * The context used to execute commands for this pass.
    *
    * @type {Context}
    */
    weak var _context: Context! = nil

    let commandEncoder: MTLRenderCommandEncoder

    let passState: PassState

    init (context: Context, buffer: MTLCommandBuffer, passState: PassState, defaultFramebuffer: Framebuffer) {
        _context = context
        self.passState = passState
        let passDescriptor = passState.framebuffer?.renderPassDescriptor ?? defaultFramebuffer.renderPassDescriptor
        commandEncoder = buffer.makeRenderCommandEncoder(descriptor: passDescriptor)
    }

    func apply(renderState: RenderState) {
        renderState.apply(commandEncoder, passState: passState)
    }

    func complete () {
        commandEncoder.endEncoding()
    }
}

