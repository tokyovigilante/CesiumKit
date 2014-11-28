//
//  ShaderCache.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

class ShaderCache {

    /**
    * @private
    */
    weak var context: Context?
    
    private var _shaders = [String: ShaderProgram]()
    
    
    var nextShaderProgramId = 0
    
    init (context: Context) {
        self.context = context
        
        /*for ( var uniformName in AutomaticUniforms) {
            if (AutomaticUniforms.hasOwnProperty(uniformName)) {
                var uniform = AutomaticUniforms[uniformName];
                if (typeof uniform.getDeclaration === 'function') {
                    ShaderProgram._czmBuiltinsAndUniforms[uniformName] = uniform.getDeclaration(uniformName);
                }
            }
        }*/

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
    * @param {String} vertexShaderSource The GLSL source for the vertex shader.
    * @param {String} fragmentShaderSource The GLSL source for the fragment shader.
    * @param {Object} attributeLocations Indices for the attribute inputs to the vertex shader.
    * @returns {ShaderProgram} The cached or newly created shader program.
    *
    * @see ShaderCache#getShaderProgram
    *
    * @example
    * this._shaderProgram = context.shaderCache.replaceShaderProgram(
    *     this._shaderProgram, vs, fs, attributeLocations);
    */
    func replaceShaderProgram (shaderProgram: ShaderProgram?, vertexShaderSource: String, fragmentShaderSource: String, attributeLocations: [String: Int]) -> ShaderProgram? {
        
        if let existingShader = shaderProgram {
            existingShader.count = 0
            releaseShaderProgram(existingShader)
        }
        
        return getShaderProgram(vertexShaderSource: vertexShaderSource, fragmentShaderSource: fragmentShaderSource, attributeLocations: attributeLocations)
    }
    
    /**
    * Returns a shader program from the cache, or creates and caches a new shader program,
    * given the GLSL vertex and fragment shader source and attribute locations.
    * <p>
    *
    * @param {String} vertexShaderSource The GLSL source for the vertex shader.
    * @param {String} fragmentShaderSource The GLSL source for the fragment shader.
    * @param {Object} attributeLocations Indices for the attribute inputs to the vertex shader.
    * @returns {ShaderProgram} The cached or newly created shader program.
    *
    * @example
    * this._shaderProgram = context.shaderCache.getShaderProgram(
    *     this._shaderProgram, vs, fs, attributeLocations);
    */
    func getShaderProgram (#vertexShaderSource: String, fragmentShaderSource: String, attributeLocations: [String: Int]) -> ShaderProgram {
        var keyword = vertexShaderSource + fragmentShaderSource + attributeLocations.description

        var cachedShader: ShaderProgram? = _shaders[keyword]
        
        if cachedShader == nil {
            cachedShader = ShaderProgram(
                logShaderCompilation: context!._logShaderCompilation,
                vertexShaderSource: vertexShaderSource,
                fragmentShaderSource: fragmentShaderSource,
                attributeLocations: attributeLocations,
                id: nextShaderProgramId++
            )
            _shaders[keyword] = cachedShader!
        }
        cachedShader!.count++
        return cachedShader!
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
    func releaseShaderProgram(shader: ShaderProgram) {
        if --shader.count < 1 {
            _shaders.removeValueForKey(shader.keyword)
        }
    }

}
