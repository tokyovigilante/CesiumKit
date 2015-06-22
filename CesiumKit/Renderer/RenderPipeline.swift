//
//  RenderPipeline.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/05/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Metal

class RenderPipeline {
    
    let state: MTLRenderPipelineState!
    
    let shaderProgram: ShaderProgram
    
    var keyword: String {
        return shaderProgram.keyword
    }
    
    var count: Int = 0
    
    init (device: MTLDevice, shaderProgram: ShaderProgram, descriptor: MTLRenderPipelineDescriptor) {
        
        self.shaderProgram = shaderProgram
        do {
            let state = try device.newRenderPipelineStateWithDescriptor(descriptor)
            self.state = state
        } catch  {
            state = nil
            assertionFailure("newRenderPipelineStateWithDescriptor failed")
        }
    }
    
    func setUniforms(command: DrawCommand, context: Context, uniformState: UniformState) -> (buffer: Buffer, fragmentOffset: Int, samplerOffset: Int, texturesValid: Bool, textures: [Texture]) {
        if command.uniformBufferProvider == nil {
            command.uniformBufferProvider = shaderProgram.createUniformBufferProvider(context)
        }
        return shaderProgram.setUniforms(command, uniformState: uniformState)
    }
}