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

    fileprivate func createViewportQuadPipeline(_ fragmentShaderSource: ShaderSource) -> RenderPipeline? {

        let attributes = [
            // attribute vec4 position;
            VertexAttributes(
                buffer: nil,
                bufferIndex: VertexDescriptorFirstBufferOffset,
                index: 0,
                format: .float2,
                offset: 0,
                size: 8,
                normalize: false),
            // attribute vec2 textureCoordinates;
            VertexAttributes(
                buffer: nil,
                bufferIndex: VertexDescriptorFirstBufferOffset,
                index: 1,
                format: .float2,
                offset: 8,
                size: 8,
                normalize: false)
        ]

        return RenderPipeline.fromCache(
            context: context,
            vertexShaderSource: ShaderSource(sources: [Shaders["ViewportQuadVS"]!]),
            fragmentShaderSource: fragmentShaderSource,
            vertexDescriptor: VertexDescriptor(attributes: attributes),
            colorMask: nil,
            depthStencil: false)
    }

    func execute (_ computeCommand: ComputeCommand) {

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
            device: context.device,
            viewport: Cartesian4(x: 0, y: 0, width: Double(outputTexture.width), height: Double(outputTexture.height)))


        var clearCommand = ClearCommand(color: Cartesian4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        clearCommand.renderState = renderState
        clearCommand.execute(context, passState: passState)

        let drawCommand = DrawCommand()
        drawCommand.vertexArray = vertexArray
        drawCommand.renderState = renderState
        drawCommand.pipeline = pipeline
        drawCommand.uniformMap = computeCommand.uniformMap
        if let map = drawCommand.uniformMap {
            map.uniformBufferProvider = drawCommand.pipeline!.shaderProgram.createUniformBufferProvider(context.device, deallocationBlock: nil)
        }

        let renderPass = context.createRenderPass(passState)
        drawCommand.execute(context, renderPass: renderPass)
        renderPass.complete()
        //FIXME: postExecute
        if let postExecute = computeCommand.postExecute {
            postExecute(computeCommand.outputTexture!)
        }
    }

}
