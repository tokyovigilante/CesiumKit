//
//  Framebuffer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

/**
 * @private
 */
class Framebuffer {
    
    let maximumColorAttachments: Int
    
    let colorTextures: [Texture]?
    
    let depthTexture: Texture?
    
    let stencilTexture: Texture?
    
    var renderPassDescriptor: MTLRenderPassDescriptor {
        return _rpd
    }
    
    var numberOfColorAttachments: Int {
        return colorTextures?.count ?? 0
    }
    
    /**
     * True if the framebuffer has a depth attachment.  Depth attachments include
     * depth and depth-stencil textures, and depth and depth-stencil renderbuffers.  When
     * rendering to a framebuffer, a depth attachment is required for the depth test to have effect.
     * @memberof Framebuffer.prototype
     * @type {Boolean}
     */
    var hasDepthAttachment: Bool {
        return depthTexture != nil
    }
    
    private var _rpd = MTLRenderPassDescriptor()
    
    init (
        maximumColorAttachments: Int,
        colorTextures: [Texture]? = nil,
        depthTexture: Texture? = nil,
        stencilTexture: Texture? = nil) {
            self.maximumColorAttachments = maximumColorAttachments
            self.colorTextures = colorTextures
            self.depthTexture = depthTexture
            self.stencilTexture = stencilTexture
            
            assert(colorTextures == nil || colorTextures!.count <= Int(maximumColorAttachments), "The number of color attachments exceeds the number supported.")
            
            if let colorTextures = self.colorTextures {
                for (i, colorTexture) in colorTextures.enumerate() {
                    _rpd.colorAttachments[i].texture = colorTexture.metalTexture
                }
            }
            
            _rpd.depthAttachment.texture = self.depthTexture?.metalTexture
            _rpd.stencilAttachment.texture = self.stencilTexture?.metalTexture

    }
    
}