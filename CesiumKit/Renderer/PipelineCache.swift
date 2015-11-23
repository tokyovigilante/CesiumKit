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
    weak var context: Context!
    
    weak var device: MTLDevice!
    
    private var _optimizer: GLSLOptimizer!
    
    private var _pipelines = [String: RenderPipeline]()
    
    var nextRenderPipelineId = 0
    
    init (context: Context, device: MTLDevice) {
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
        depthStencil: Bool) -> RenderPipeline? {
        
        if let existingPipeline = pipeline {
            existingPipeline.count = 0
            releasePipeline(existingPipeline)
        }
            return getRenderPipeline(vertexShaderSource: vss, fragmentShaderSource: fss, vertexDescriptor: vertexDescriptor, depthStencil: depthStencil)
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
    func getRenderPipeline (vertexShaderSource vss: ShaderSource, fragmentShaderSource fss: ShaderSource, vertexDescriptor: VertexDescriptor?, depthStencil: Bool) -> RenderPipeline {
        // FIXME: Cache
        let shader = ShaderProgram(
            device: device,
            optimizer: _optimizer,
            vertexShaderSource: vss,
            fragmentShaderSource: fss
        )
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineDescriptor.vertexFunction = shader.metalVertexFunction
        pipelineDescriptor.fragmentFunction = shader.metalFragmentFunction
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = context.view.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = depthStencil ? .Depth32Float_Stencil8 : .Invalid
        pipelineDescriptor.stencilAttachmentPixelFormat = depthStencil ? .Depth32Float_Stencil8 : .Invalid
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor?.metalDescriptor
        
        return RenderPipeline(device: device, shaderProgram: shader, descriptor: pipelineDescriptor)
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
        if --pipeline.count < 1 {
            _pipelines.removeValueForKey(pipeline.keyword)
        }
    }

}
