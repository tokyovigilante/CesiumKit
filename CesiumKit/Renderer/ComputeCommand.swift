//
//  ComputeCommand.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/10/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
* Represents a command to the renderer for GPU Compute (using old-school GPGPU).
*
* @private
*/
class ComputeCommand: Command {
    
    /**
    * The vertex array. If none is provided, a viewport quad will be used.
    *
    * @type {VertexArray}
    * @default undefined
    */
    var vertexArray: VertexArray?
    
    /**
    * The fragment shader source. The default vertex shader is ViewportQuadVS.
    *
    * @type {ShaderSource}
    * @default undefined
    */
    var fragmentShaderSource: ShaderSource?
    
    /**
    * The shader program to apply.
    *
    * @type {ShaderProgram}
    * @default undefined
    */
    var pipeline: RenderPipeline?
    
    /**
    * An object with functions whose names match the uniforms in the shader program
    * and return values to set those uniforms.
    *
    * @type {Object}
    * @default undefined
    */
    var uniformMap: UniformMap?
    
    /**
    * Texture to use for offscreen rendering.
    *
    * @type {Texture}
    * @default undefined
    */
    var outputTexture: Texture?
    
    /**
    * Function that is called immediately before the ComputeCommand is executed. Used to
    * update any renderer resources. Takes the ComputeCommand as its single argument.
    *
    * @type {Function}
    * @default undefined
    */
    var preExecute: ((ComputeCommand) -> ())?
    
    /**
    * Function that is called after the ComputeCommand is executed. Takes the output
    * texture as its single argument.
    *
    * @type {Function}
    * @default undefined
    */
    var postExecute: ((Texture) -> ())?
    
    /**
    * Whether the renderer resources will persist beyond this call. If not, they
    * will be destroyed after completion.
    *
    * @type {Boolean}
    * @default false
    */
    var persists: Bool
    
    /**
    * The pass when to render. Always compute pass.
    *
    * @type {Pass}
    * @default Pass.COMPUTE;
    */
    let pass: Pass = .compute
    
    /**
    * The object who created this command.  This is useful for debugging command
    * execution; it allows us to see who created a command when we only have a
    * reference to the command, and can be used to selectively execute commands
    * with {@link Scene#debugCommandFilter}.
    *
    * @type {Object}
    * @default undefined
    *
    * @see Scene#debugCommandFilter
    */
    var owner: AnyObject? = nil
    
    init(
        vertexArray: VertexArray? = nil,
        fragmentShaderSource: ShaderSource? = nil,
        renderPipeline: RenderPipeline? = nil,
        uniformMap: UniformMap? = nil,
        outputTexture: Texture? = nil,
        preExecute: ((ComputeCommand) -> ())? = nil,
        postExecute: ((Texture) -> ())? = nil,
        persists: Bool = false,
        owner: AnyObject? = nil) {
            self.vertexArray = vertexArray
            self.fragmentShaderSource = fragmentShaderSource
            self.pipeline = renderPipeline
            self.uniformMap = uniformMap
            self.outputTexture = outputTexture
            self.preExecute = preExecute
            self.postExecute = postExecute
            self.persists = persists
            self.owner = owner
    }
    
    /**
    * Executes the compute command.
    *
    * @param {Context} context The context that processes the compute command.
    */
    func execute (_ computeEngine: ComputeEngine) {
        computeEngine.execute(self)
    }
    
}
