//
//  PipelineCache.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import GLSLOptimizer
import Metal

class PipelineCache {

    /**
    * @private
    */
    weak var context: Context! = nil
    
    weak var device: MTLDevice!
    
    private var _optimizer: GLSLOptimizer!
    
    private var _pipelines = [String: RenderPipeline]()
    
    var nextRenderPipelineId = 0
    
    init (device: MTLDevice) {
        self.device = device
        _optimizer = GLSLOptimizer(.Metal)
    }
        
    /**
    * Returns a shader program from the cache, or creates and caches a new shader program,
    * given the GLSL vertex and fragment shader source and attribute locations.
    * <p>
    * The difference between this and {@link ShaderCache#getShaderProgram}, is this is used to
    * replace an existing reference to a shader program, which is passed as the first argument.
    * </p>
    *
    * @param {ShaderProgram} shaderProgram The shader program that is being reassigned.  This can be <code>undefined</code>.
    * @param {String|ShaderSource} vertexShaderSource The GLSL source for the vertex shader.
    * @param {String|ShaderSource} fragmentShaderSource The GLSL source for the fragment shader.
    * @param {Object} attributeLocations Indices for the attribute inputs to the vertex shader.
    * @returns {ShaderProgram} The cached or newly created shader program.
    *
    * @see ShaderCache#getShaderProgram
    *
    * @example
    * this._shaderProgram = context.shaderCache.replaceShaderProgram(
    *     this._shaderProgram, vs, fs, attributeLocations);
    */
    func replaceRenderPipeline (
        pipeline: RenderPipeline?,
        vertexShaderSource vss: ShaderSource,
        fragmentShaderSource fss: ShaderSource,
        vertexDescriptor: VertexDescriptor?,
        colorMask: ColorMask?,
        depthStencil: Bool, blendingState: BlendingState? = nil) -> RenderPipeline? {
        
        if let existingPipeline = pipeline {
            releasePipeline(existingPipeline)
        }
            
            return getRenderPipeline(vertexShaderSource: vss, fragmentShaderSource: fss, vertexDescriptor: vertexDescriptor, colorMask: colorMask, depthStencil: depthStencil, blendingState: blendingState)
    }
    
    /**
    * Returns a shader program from the cache, or creates and caches a new shader program,
    * given the GLSL vertex and fragment shader source and attribute locations.
    *
    * @param {String|ShaderSource} vertexShaderSource The GLSL source for the vertex shader.
    * @param {String|ShaderSource} fragmentShaderSource The GLSL source for the fragment shader.
    * @param {Object} attributeLocations Indices for the attribute inputs to the vertex shader.
    *
    * @returns {ShaderProgram} The cached or newly created shader program.
    */
    func getRenderPipeline (vertexShaderSource vss: ShaderSource, fragmentShaderSource fss: ShaderSource, vertexDescriptor descriptor: VertexDescriptor?, colorMask: ColorMask?, depthStencil: Bool, blendingState: BlendingState? = nil) -> RenderPipeline {

        let combinedShaders = ShaderProgram.combineShaders(vertexShaderSource: vss, fragmentShaderSource: fss)
        
        let keyword = combinedShaders.keyword + (colorMask != nil ? colorMask!.description() : "xxxx") + (depthStencil ? "depth" : "nodepth") + (blendingState != nil ? blendingState!.description : "noblend")
        
        if let pipeline = _pipelines[keyword] {
            //pipeline.count++
            print("cached")
            return pipeline
        }
        
        let shader = ShaderProgram(
            device: device,
            optimizer: _optimizer,
            vertexShaderSource: vss,
            fragmentShaderSource: fss,
            combinedShaders: combinedShaders
        )
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let color = pipelineDescriptor.colorAttachments[0]
        
        pipelineDescriptor.vertexFunction = shader.metalVertexFunction
        pipelineDescriptor.fragmentFunction = shader.metalFragmentFunction
        
        color.pixelFormat = context.view.colorPixelFormat
        let colorWriteMask: MTLColorWriteMask = colorMask != nil ? colorMask!.toMetal() : MTLColorWriteMask.All
        color.writeMask = colorWriteMask
        
        pipelineDescriptor.depthAttachmentPixelFormat = depthStencil ? .Depth32Float_Stencil8 : .Invalid
        pipelineDescriptor.stencilAttachmentPixelFormat = depthStencil ? .Depth32Float_Stencil8 : .Invalid
        
        if let blendingState = blendingState {
            color.blendingEnabled = true
            color.rgbBlendOperation = blendingState.equationRgb.toMetal()
            color.sourceRGBBlendFactor = blendingState.functionSourceRgb.toMetal()
            color.destinationRGBBlendFactor = blendingState.functionDestinationRgb.toMetal()

            color.alphaBlendOperation = blendingState.equationAlpha.toMetal()
            color.sourceAlphaBlendFactor = blendingState.functionSourceAlpha.toMetal()
            color.destinationAlphaBlendFactor = blendingState.functionDestinationAlpha.toMetal()

        }
        
        pipelineDescriptor.vertexDescriptor = descriptor?.metalDescriptor
        
        pipelineDescriptor.label = keyword
        
        let pipeline = RenderPipeline(device: device, shaderProgram: shader, descriptor: pipelineDescriptor)
        _pipelines[keyword] = pipeline
        pipeline.count++
        return pipeline
    }
    
    /**
    * Decrements a shader's reference count. The shader's deinit function
    * will automatically release the GL resources the program uses once 
    * the reference count reaches zero and the renderer does not have any
    * more strong references to the object.
    * <p>
    *
    * @param {ShaderProgram} shader The shader to decrement
    */
    func releasePipeline(pipeline: RenderPipeline) {
        pipeline.count--
        if --pipeline.count < 1 {
            _pipelines.removeValueForKey(pipeline.keyword)
        }
    }

}
