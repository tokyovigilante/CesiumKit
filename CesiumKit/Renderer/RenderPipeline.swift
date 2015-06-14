//
//  RenderPipeline.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/05/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Metal

class RenderPipeline {
    
    let state: MTLRenderPipelineState
    
    let shaderProgram: ShaderProgram
    
    var keyword: String {
        return shaderProgram.keyword
    }
    
    var count: Int = 0
    
    init (device: MTLDevice, shaderProgram: ShaderProgram, descriptor: MTLRenderPipelineDescriptor) {
        var error: NSError?
        var metalPipeline = device.newRenderPipelineStateWithDescriptor(descriptor, error: &error)
        assert(error == nil, "Metal Error: \(error!.description)")
        self.state = metalPipeline!
        self.shaderProgram = shaderProgram
    }
    
    func setUniforms(drawCommand: DrawCommand, context: Context, uniformState: UniformState) {
        if drawCommand.vertexUniformBuffer == nil ||
            drawCommand.fragmentUniformBuffer == nil ||
            drawCommand.samplerUniformBuffer == nil {
                let uniformBuffers = shaderProgram.createUniformBuffers(context)
                drawCommand.setUniformBuffers(vertex: uniformBuffers.vertex, fragment: uniformBuffers.fragment, sampler: uniformBuffers.sampler)
        }
    }
}