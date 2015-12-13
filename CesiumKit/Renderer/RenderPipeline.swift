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
        return state.label ?? ""
    }
    
    var count: Int = 0
    
    init (device: MTLDevice, shaderProgram: ShaderProgram, descriptor: MTLRenderPipelineDescriptor) {
        
        var reflectionInfo: MTLAutoreleasedRenderPipelineReflection? = nil
        self.shaderProgram = shaderProgram
        do {
            //let state = try device.newRenderPipelineStateWithDescriptor(descriptor)
            
            let state = try device.newRenderPipelineStateWithDescriptor(descriptor, options: [.ArgumentInfo], reflection: &reflectionInfo)
            for argument in reflectionInfo!.vertexArguments! {
                //  process each MTLArgument
                print(argument)
                if argument.type == .Buffer {
                    if argument.bufferDataType == .Struct {
                        print("vertex")
                        print(argument.bufferStructType.members.count)
                        for member in argument.bufferStructType.members {
                            print(member)
                        }
                    }
                }
            }
            for argument in reflectionInfo!.fragmentArguments! {
                //  process each MTLArgument
                if argument.type == .Buffer {
                    if argument.bufferDataType == .Struct {
                        print("fragment")
                        print(argument.bufferStructType.members.count)
                        for member in argument.bufferStructType.members {
                            print(member)
                        }
                    }
                }
            }
            self.state = state
        } catch let error as NSError  {
            state = nil
            assertionFailure("newRenderPipelineStateWithDescriptor failed: \(error.localizedDescription)")
        }
    }
    
    static func fromCache (context context: Context, vertexShaderSource vss: ShaderSource, fragmentShaderSource fss: ShaderSource, vertexDescriptor vd: VertexDescriptor?, colorMask: ColorMask? = nil, depthStencil: Bool) -> RenderPipeline {

        return context.pipelineCache.getRenderPipeline(vertexShaderSource: vss, fragmentShaderSource: fss, vertexDescriptor: vd, colorMask: colorMask, depthStencil: depthStencil)
    }
    
    static func replaceCache (context: Context,  pipeline: RenderPipeline?, vertexShaderSource vss: ShaderSource, fragmentShaderSource fss: ShaderSource, vertexDescriptor vd: VertexDescriptor?, colorMask: ColorMask? = nil, depthStencil: Bool) -> RenderPipeline? {
        
        return context.pipelineCache.replaceRenderPipeline(pipeline, vertexShaderSource: vss, fragmentShaderSource: fss, vertexDescriptor: vd, colorMask: colorMask, depthStencil: depthStencil)
    }
    
    func setUniforms(command: DrawCommand, device: MTLDevice, uniformState: UniformState) -> (buffer: Buffer, fragmentOffset: Int, texturesValid: Bool, textures: [Texture]) {
        if command.uniformBufferProvider == nil {
            command.uniformBufferProvider = shaderProgram.createUniformBufferProvider(device)
        }
        return shaderProgram.setUniforms(command, uniformState: uniformState)
    }
}