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
    func replaceShaderProgram (shaderProgram: ShaderProgram?, vertexShaderString: String? = nil, vertexShaderSource vss: ShaderSource? = nil, fragmentShaderString: String? = nil, fragmentShaderSource fss: ShaderSource? = nil, attributeLocations: [String: Int]) -> ShaderProgram? {
        
        if let existingShader = shaderProgram {
            existingShader.count = 0
            releaseShaderProgram(existingShader)
        }
        
        return getShaderProgram(vertexShaderString: vertexShaderString, vertexShaderSource: vss, fragmentShaderString: fragmentShaderString, fragmentShaderSource: fss, attributeLocations: attributeLocations)
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
    func getShaderProgram (vertexShaderString: String? = nil, vertexShaderSource vss: ShaderSource? = nil, fragmentShaderString: String? = nil, fragmentShaderSource fss: ShaderSource? = nil, attributeLocations: [String: Int]) -> ShaderProgram {

        assert((vertexShaderString == nil && vss != nil) ||
        (vertexShaderString != nil && vss == nil), "Must provide only one of vertexShaderString or vertexShaderSource")
        assert((fragmentShaderString == nil && fss != nil) ||
        (fragmentShaderString != nil && fss == nil), "Must provide only one of vertexShaderString or vertexShaderSource")

        let vertexShaderSource: ShaderSource
        let fragmentShaderSource: ShaderSource
        
        // convert shaders which are provided as strings into ShaderSource objects
        // because ShaderSource handles all the automatic including of built-in functions, etc.
        if vertexShaderString != nil {
            vertexShaderSource = ShaderSource(sources: [vertexShaderString!])
        } else {
            vertexShaderSource = vss!
        }
        
        if fragmentShaderString != nil {
            fragmentShaderSource = ShaderSource(sources: [fragmentShaderString!])
        } else {
            fragmentShaderSource = fss!
        }
        
        let vertexShaderText = vertexShaderSource.createCombinedVertexShader()
        let fragmentShaderText = fragmentShaderSource.createCombinedFragmentShader()
        
        var keyword = vertexShaderText + fragmentShaderText + attributeLocations.description
        
        var cachedShader: ShaderProgram? = _shaders[keyword]
        
        if cachedShader == nil {
            cachedShader = ShaderProgram(
                logShaderCompilation: context!._logShaderCompilation,
                vertexShaderSource: vertexShaderSource,
                vertexShaderText: vertexShaderText,
                fragmentShaderSource: fragmentShaderSource,
                fragmentShaderText: fragmentShaderText,
                attributeLocations: attributeLocations,
                id: nextShaderProgramId++
            )
            _shaders[cachedShader!.keyword] = cachedShader!
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
