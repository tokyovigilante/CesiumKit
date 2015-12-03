//
//  Framebuffer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import MetalKit

/**
 * @private
 */
class Framebuffer {
    
    let maximumColorAttachments: Int
    
    private (set) var colorTextures: [Texture]?
    
    private (set) var depthTexture: Texture?
    
    private (set) var stencilTexture: Texture?
    
    var depthStencilTexture: Texture? {
        return depthTexture === stencilTexture ? depthTexture : nil
    }
    
    var renderPassDescriptor: MTLRenderPassDescriptor {
        return _rpd
    }
    
    private var _rpd = MTLRenderPassDescriptor()
    
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
            updateRenderPassDescriptor()
    }
    
    func updateFromDrawable (context: Context, drawable: CAMetalDrawable, depthStencil: MTLTexture?) {
        
        colorTextures = [Texture(context: context, metalTexture: drawable.texture)]
        depthTexture = depthStencil == nil ? nil : Texture(context: context, metalTexture: depthStencil!)
        stencilTexture = depthTexture
        
        updateRenderPassDescriptor()
    }
    
    func update (colorTextures colorTextures: [Texture]?, depthTexture: Texture?, stencilTexture: Texture?) {
        self.colorTextures = colorTextures
        self.depthTexture = depthTexture
        self.stencilTexture = stencilTexture
        updateRenderPassDescriptor()
    }
    
    private func updateRenderPassDescriptor () {
        if let colorTextures = self.colorTextures {
            for (i, colorTexture) in colorTextures.enumerate() {
                _rpd.colorAttachments[i].texture = colorTexture.metalTexture
                _rpd.colorAttachments[i].storeAction = .Store
            }
        } else {
            for i in 0..<maximumColorAttachments {
                _rpd.colorAttachments[i].texture = nil
                _rpd.colorAttachments[i].loadAction = .DontCare
                _rpd.colorAttachments[i].storeAction = .DontCare
            }
        }
        
        _rpd.depthAttachment.texture = self.depthTexture?.metalTexture
        _rpd.stencilAttachment.texture = self.stencilTexture?.metalTexture
    }
    
    func clearDrawable () {
        colorTextures = nil
        _rpd.colorAttachments[0].texture = nil
        _rpd.colorAttachments[0].loadAction = .Load
        _rpd.colorAttachments[0].storeAction = .DontCare
    }
}