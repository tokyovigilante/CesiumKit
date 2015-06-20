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
    
    func setUniforms(command: DrawCommand, context: Context, uniformState: UniformState) -> (buffer: Buffer, fragmentOffset: Int, samplerOffset: Int, texturesValid: Bool, textures: [Texture]) {
        if command.uniformBufferProvider == nil {
            command.uniformBufferProvider = shaderProgram.createUniformBufferProvider(context)
        }
        return shaderProgram.setUniforms(command, uniformState: uniformState)
    }
}