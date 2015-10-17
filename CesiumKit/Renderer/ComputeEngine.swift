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
    
    //var renderStateScratch: RenderState
    
    lazy var drawCommandScratch = DrawCommand()
    
    lazy var clearCommandScratch = ClearCommand(color: Cartesian4(fromRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.0))
    
    init (context: Context) {
        self.context = context
    }
    
    private func createRenderPassDescriptor () -> MTLRenderPassDescriptor {
        return MTLRenderPassDescriptor()
    }
    
    private func createViewportQuadPipeline(fragmentShaderSource: ShaderSource) -> RenderPipeline? {
        
        let attributes = [
            // attribute vec4 position;
            VertexAttributes(
                bufferIndex: 0,
                index: 1,
                format: .Float4,
                offset: 0,
                size: 16),
            // attribute vec2 textureCoordinates;
            VertexAttributes(
                bufferIndex: 0,
                index: 2,
                format: .Float2,
                offset: 16,
                size: 8)
        ]
        
        return RenderPipeline.fromCache(context, vertexShaderSource: ShaderSource(sources: [Shaders["ViewportQuadVS"]!]), fragmentShaderSource: fragmentShaderSource, vertexDescriptor: VertexDescriptor(attributes: attributes))
    }
    /*
    function createRenderState(width, height) {
    if ((!defined(renderStateScratch)) ||
    (renderStateScratch.viewport.width !== width) ||
    (renderStateScratch.viewport.height !== height)) {
    
    renderStateScratch = RenderState.fromCache({
    viewport : new BoundingRectangle(0, 0, width, height)
    });
    }
    return renderStateScratch;
    }
    */
    func execute (computeCommand: ComputeCommand) {
        /*//>>includeStart('debug', pragmas.debug);
        if (!defined(computeCommand)) {
        throw new DeveloperError('computeCommand is required.');
        }
        //>>includeEnd('debug');
        
        // This may modify the command's resources, so do error checking afterwards
        if (defined(computeCommand.preExecute)) {
        computeCommand.preExecute(computeCommand);
        }
        
        //>>includeStart('debug', pragmas.debug);
        if (!defined(computeCommand.fragmentShaderSource) && !defined(computeCommand.shaderProgram)) {
        throw new DeveloperError('computeCommand.fragmentShaderSource or computeCommand.shaderProgram is required.');
        }
        
        if (!defined(computeCommand.outputTexture)) {
        throw new DeveloperError('computeCommand.outputTexture is required.');
        }
        //>>includeEnd('debug');
        
        var outputTexture = computeCommand.outputTexture;
        var width = outputTexture.width;
        var height = outputTexture.height;
        
        var context = this._context;
        var vertexArray = defined(computeCommand.vertexArray) ? computeCommand.vertexArray : context.getViewportQuadVertexArray();
        var shaderProgram = defined(computeCommand.shaderProgram) ? computeCommand.shaderProgram : createViewportQuadShader(context, computeCommand.fragmentShaderSource);
        var framebuffer = createFramebuffer(context, outputTexture);
        var renderState = createRenderState(width, height);
        var uniformMap = computeCommand.uniformMap;
        
        var clearCommand = clearCommandScratch;
        clearCommand.framebuffer = framebuffer;
        clearCommand.renderState = renderState;
        clearCommand.execute(context);
        
        var drawCommand = drawCommandScratch;
        drawCommand.vertexArray = vertexArray;
        drawCommand.renderState = renderState;
        drawCommand.shaderProgram = shaderProgram;
        drawCommand.uniformMap = uniformMap;
        drawCommand.framebuffer = framebuffer;
        drawCommand.execute(context);
        
        framebuffer.destroy();
        
        if (!computeCommand.persists) {
        shaderProgram.destroy();
        if (defined(computeCommand.vertexArray)) {
        vertexArray.destroy();
        }
        }
        
        if (defined(computeCommand.postExecute)) {
        computeCommand.postExecute(outputTexture);
        }*/
    }
    /*
    
    ComputeEngine.prototype.destroy = function() {
    return destroyObject(this);
    };
    
    
    */
}