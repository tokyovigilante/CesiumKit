 //
//  ComputeEngine.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/10/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation
import Metal

class ComputeEngine {
    
    
    /**
    * @private
    */
    let context: Context
    
    init (context: Context) {
        self.context = context
    }
    
    /*private func createRenderPassDescriptor () -> MTLRenderPassDescriptor {
        return MTLRenderPassDescriptor()
    }*/
    
    private func createViewportQuadPipeline(fragmentShaderSource: ShaderSource) -> RenderPipeline? {
        
        let attributes = [
            // attribute vec4 position;
            VertexAttributes(
                bufferIndex: 1,
                index: 0,
                format: .Float4,
                offset: 0,
                size: 16),
            // attribute vec2 textureCoordinates;
            VertexAttributes(
                bufferIndex: 1,
                index: 1,
                format: .Float2,
                offset: 16,
                size: 8)
        ]
        
        return RenderPipeline.fromCache(context: context, vertexShaderSource: ShaderSource(sources: [Shaders["ViewportQuadVS"]!]), fragmentShaderSource: fragmentShaderSource, vertexDescriptor: VertexDescriptor(attributes: attributes), depthStencil: false)
    }
    
    func execute (computeCommand: ComputeCommand) {
        
        // This may modify the command's resources, so do error checking afterwards
        if let preExecute = computeCommand.preExecute {
            preExecute(computeCommand)
        }
        
        assert(computeCommand.fragmentShaderSource != nil || computeCommand.pipeline != nil, "computeCommand.fragmentShaderSource or pipeline is required")
        guard let outputTexture = computeCommand.outputTexture else {
            assertionFailure("computeCommand.outputTexture is required")
            return
        }
        
        let framebuffer = Framebuffer(maximumColorAttachments: 1, colorTextures: [computeCommand.outputTexture!], depthTexture: nil, stencilTexture: nil)
        let passState = PassState()
        passState.context = context
        passState.framebuffer = framebuffer
        
        let vertexArray = computeCommand.vertexArray ?? context.getViewportQuadVertexArray()
        let pipeline = computeCommand.pipeline ?? createViewportQuadPipeline(computeCommand.fragmentShaderSource!)
        let renderState = RenderState(
            windingOrder: .CounterClockwise,
            viewport: BoundingRectangle(width: Double(outputTexture.width), height: Double(outputTexture.height)))
        
        
        var clearCommand = ClearCommand(color: Cartesian4(fromRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.0))
        clearCommand.renderState = renderState
        clearCommand.execute(context, passState: passState)
        
        let drawCommand = DrawCommand()
        drawCommand.vertexArray = vertexArray
        drawCommand.renderState = renderState
        drawCommand.pipeline = pipeline
        drawCommand.uniformMap = computeCommand.uniformMap
        
        let renderPass = context.createRenderPass(passState)
        drawCommand.execute(context, renderPass: renderPass)
        renderPass.complete()
        //FIXME: postExecute
        if let postExecute = computeCommand.postExecute {
            postExecute(computeCommand.outputTexture!)
        }
    }
    
}