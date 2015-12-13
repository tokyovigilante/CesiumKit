//
//  ShaderProgram.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import Metal
import GLSLOptimizer
import simd

/*struct VertexAttributeInfo {
    
    var name: String = ""
    
    var type: GLenum = 0
    
    var index: GLenum = 0
        
}*/

class ShaderProgram {
    
    var _logShaderCompilation: Bool = false
    
    /**
    * GLSL source for the shader program's vertex shader.
    *
    * @memberof ShaderProgram.prototype
    *
    * @type {ShaderSource}
    * @readonly
    */
    let vertexShaderSource: ShaderSource
    
    private let _vertexShaderText: String
    
    private var _vertexShader: GLSLShader!
    
    private var _vertexLibrary: MTLLibrary!
    
    private var _metalVertexShaderSource: String!

    var metalVertexFunction: MTLFunction!
    
    private var _vertexUniforms: [Uniform]!
    
    /**
    * GLSL source for the shader program's fragment shader.
    *
    * @memberof ShaderProgram.prototype
    *
    * @type {ShaderSource}
    * @readonly
    */
    let fragmentShaderSource: ShaderSource
    
    private let _fragmentShaderText: String
    
    private var _fragmentShader: GLSLShader!

    private var _fragmentLibrary: MTLLibrary!
    
    private var _metalFragmentShaderSource: String!

    var metalFragmentFunction: MTLFunction!
    
    private var _fragmentUniforms: [Uniform]!
    
    private var _samplerUniforms: [UniformSampler]!
    
    private var _uniformBufferAlignment: Int = -1
    
    private (set) var vertexUniformSize = -1
    private (set) var fragmentUniformOffset = -1
    private (set) var fragmentUniformSize = -1
    
    var uniformBufferSize: Int {
        return vertexUniformSize + fragmentUniformSize
    }
    
    let keyword: String

    var numberOfVertexAttributes: Int {
        return vertexAttributes.count
    }
    
    private (set) var vertexAttributes: [String: GLSLShaderVariableDescription]!
    
    var maximumTextureUnitIndex: Int = 0
    
    init(device: MTLDevice, optimizer: GLSLOptimizer, logShaderCompilation: Bool = false, vertexShaderSource vss: ShaderSource, fragmentShaderSource fss: ShaderSource, combinedShaders: (vst: String, fst: String, keyword: String)) {
        _logShaderCompilation = logShaderCompilation
        vertexShaderSource = vss
        fragmentShaderSource = fss
        _vertexShaderText = combinedShaders.vst
        _fragmentShaderText = combinedShaders.fst
        keyword = combinedShaders.keyword
        initialize(device, optimizer: optimizer)
    }
    
    static func combineShaders (vertexShaderSource vss: ShaderSource, fragmentShaderSource fss: ShaderSource) -> (vst: String, fst: String, keyword: String) {
        let vst = vss.createCombinedVertexShader()
        let fst = fss.createCombinedFragmentShader()
        let keyword = vst + fst
        return (vst, fst, keyword)
    }
    
    private func initialize(device: MTLDevice, optimizer: GLSLOptimizer) {

        createMetalProgram(optimizer)
        compileMetalProgram(device)
        
        findVertexAttributes()
        findUniforms()
        setUniformBufferAlignment()
        setUniformBufferOffsets()
        //createUniformBuffers(context)
        
       /* maximumTextureUnitIndex = Int(setSamplerUniforms(uniforms.samplerUniforms))*/
    }
    
    private func createMetalProgram(optimizer: GLSLOptimizer) {
        
        _vertexShader = optimizer.optimize(.Vertex, shaderSource: _vertexShaderText, options: 0)
        assert(_vertexShader.status(), _vertexShader.log())
        _metalVertexShaderSource = _vertexShader.output()
        
        _fragmentShader = optimizer.optimize(.Fragment, shaderSource: _fragmentShaderText, options: 0)
        assert(_fragmentShader.status(), _fragmentShader .log())
        _metalFragmentShaderSource = _fragmentShader.output()
    }
    
    private func compileMetalProgram(device: MTLDevice) {
        
        do {
            _vertexLibrary = try device.newLibraryWithSource(_metalVertexShaderSource, options: nil)
            metalVertexFunction = _vertexLibrary.newFunctionWithName("xlatMtlMain")
        } catch let error as NSError {
            print(_fragmentShaderText)
            print(_metalFragmentShaderSource)
            print(error.localizedDescription)
            assertionFailure("_vertexLibrary == nil")
        }
        
        do {
            _fragmentLibrary = try device.newLibraryWithSource(_metalFragmentShaderSource, options: nil)
            metalFragmentFunction = _fragmentLibrary.newFunctionWithName("xlatMtlMain")
        } catch let error as NSError {
            print(_fragmentShaderText)
            print(_metalFragmentShaderSource)
            print(error.localizedDescription)
            assertionFailure("_library == nil")
        }
    }
    
    private func findVertexAttributes() {
        let attributeCount = _vertexShader.inputCount()
        
        vertexAttributes = [String: GLSLShaderVariableDescription]()
        
        for i in 0..<attributeCount {
            let attribute = _vertexShader.inputDescription(i)
            vertexAttributes[attribute.name] = attribute
        }
    }
    
    private func findUniforms() {
        _vertexUniforms = [Uniform]()
        let vertexUniformCount = _vertexShader.uniformCount()
        for i in 0..<vertexUniformCount {
            let desc =  _vertexShader.uniformDescription(i)
            let type: UniformType = desc.name.hasPrefix("czm_") ? .Automatic : .Manual
            _vertexUniforms.append(Uniform.create(desc: desc, type: type))
        }
        
        _fragmentUniforms = [Uniform]()
        let fragmentUniformCount = _fragmentShader.uniformCount()
        for i in 0..<fragmentUniformCount {
            let desc =  _fragmentShader.uniformDescription(i)
            let type: UniformType = desc.name.hasPrefix("czm_") ? .Automatic : .Manual
            _fragmentUniforms.append(Uniform.create(desc: desc, type: type))
        }

        _samplerUniforms = [UniformSampler]()
        let samplerUniformCount = _fragmentShader.textureCount()
        for i in 0..<samplerUniformCount {
            let desc =  _fragmentShader.textureDescription(i)
            _samplerUniforms.append(Uniform.create(desc: desc, type: .Sampler) as! UniformSampler)
        }
    }
    
    private func setUniformBufferAlignment () {
        var maxAlignment = 0
        for uniform in _vertexUniforms {
            maxAlignment = max(maxAlignment, uniform.dataType.alignment)
        }
        
        for uniform in _vertexUniforms {
            maxAlignment = max(maxAlignment, uniform.dataType.alignment)
        }
        _uniformBufferAlignment = maxAlignment
    }
    
    private func elementStrideForUniform (uniform: Uniform) -> Int {
        var stride = uniform.dataType.elementStride
        if stride < _uniformBufferAlignment {
            stride = _uniformBufferAlignment
        } else {
            stride += stride % _uniformBufferAlignment
        }
        return stride
    }
    
    private func setUniformBufferOffsets() {
        
        var offset = 0
        for uniform in _vertexUniforms {
            let stride = elementStrideForUniform(uniform)
            uniform.offset = offset
            print("size: \(stride), offset: \(offset)")
            offset += stride
        }
        assert(offset % _uniformBufferAlignment == 0, "invalid buffer alignment")
        vertexUniformSize = offset
        offset = ((offset + 255) / 256) * 256 // fragment buffer offset must be a multiple of 256
        fragmentUniformOffset = offset
        for uniform in _fragmentUniforms {
            let stride = elementStrideForUniform(uniform)
            uniform.offset = offset
            print("size: \(stride), offset: \(offset)")
            offset += stride
        }
        offset = ((offset + 255) / 256) * 256 // overall buffer size must be a multiple of 256
        assert(offset % _uniformBufferAlignment == 0, "invalid buffer alignment")
        fragmentUniformSize = offset - vertexUniformSize
    }

    func createUniformBufferProvider(device: MTLDevice) -> UniformBufferProvider {
        let provider = UniformBufferProvider(device: device, capacity: 3, bufferSize: uniformBufferSize)
        return provider
    }
    
    //MARK:- Set uniforms
    
    func setUniforms (command: DrawCommand, uniformState: UniformState) -> (buffer: Buffer, fragmentOffset: Int, texturesValid: Bool, textures: [Texture]) {
        
        let buffer = command.uniformBufferProvider.nextBuffer()

        for uniform in _vertexUniforms {
            setUniform(uniform, buffer: buffer, uniformMap: command.uniformMap, uniformState: uniformState)
        }

        for uniform in _fragmentUniforms {
            setUniform(uniform, buffer: buffer, uniformMap: command.uniformMap, uniformState: uniformState)
        }
        var textures = [Texture]()
        
        var texturesValid = true
        for uniform in _samplerUniforms {
            if let texture = command.uniformMap!.textureForUniform(uniform) {
                textures.append(texture)
            } else {
                texturesValid = false
            }
        }
        buffer.metalBuffer.didModifyRange(NSMakeRange(0, buffer.length))

        let fragmentOffset = command.pipeline!.shaderProgram.fragmentUniformOffset
        return (buffer: buffer, fragmentOffset: fragmentOffset, texturesValid: texturesValid, textures: textures)
    }
    
    func setUniform (uniform: Uniform, buffer: Buffer, uniformMap: UniformMap?, uniformState: UniformState) {

        let offset = uniform.offset

        switch (uniform.type) {
        case .Automatic:
            if let automaticUniform = AutomaticUniforms[uniform.name] {
                memcpy(buffer.data+offset, automaticUniform.getValue(uniformState: uniformState), uniform.rawSize)
            }
        case .Manual:
            if let uniformFloatFunc = uniformMap!.floatUniform(uniform.name) {
                memcpy(buffer.data+offset, uniformFloatFunc(map: uniformMap!), uniform.rawSize)
            }
        case .Sampler:
            assertionFailure("Sampler not implemented")
        }
        //uniform.set(buffer)
    }
    
    
    /*private func setSamplerUniform(samplerUniforms: [Uniform]) -> GLint {
        
        /*var textureUnitIndex: Int = 0
        
        for uniform in samplerUniforms {
            if let samplerUniform = uniform as? UniformSampler {
                textureUnitIndex = samplerUniform.setSampler(textureUnitIndex)
            }
        }
        
        return textureUnitIndex*/
    }**/
    /**
    * Creates a GLSL shader source string by sending the input through three stages:
    * <ul>
    *   <li>A series of <code>#define</code> statements are created from <code>options.defines</code>.</li>
    *   <li>GLSL snippets in <code>options.sources</code> are combined with line numbers preserved using <code>#line</code>.</li>
    *   <li>
    *     Modifies the source for use with color-buffer picking if <code>options.pickColorQualifier</code> is defined.
    *     The returned fragment shader source sets <code>gl_FragColor</code> to a new <code>vec4</code> uniform or varying,
    *     <code>czm_pickColor</code>, but still discards if the original fragment shader discards or outputs an alpha of 0.0.
    *     This allows correct picking when a material contains transparent parts.
    *   </li>
    * </ul>
    *
    * @exports createShaderSource
    *
    * @param {Object} [options] Object with the following properties:
    * @param {String[]} [options.defines] An array of strings to combine containing GLSL identifiers to <code>#define</code>.
    * @param {String[]} [options.sources] An array of strings to combine containing GLSL code for the shader.
    * @param {String} [options.pickColorQualifier] The GLSL qualifier, <code>uniform</code> or <code>varying</code>, for the input <code>czm_pickColor</code>.  When defined, a pick fragment shader is generated.
    * @returns {String} The generated GLSL shader source.
    *
    * @exception {DeveloperError} options.pickColorQualifier must be 'uniform' or 'varying'.
    *
    * @example
    * // 1. Prepend #defines to a shader
    * var source = Cesium.createShaderSource({
    *   defines : ['WHITE'],
    *   sources : ['void main() { \n#ifdef WHITE\n gl_FragColor = vec4(1.0); \n#else\n gl_FragColor = vec4(0.0); \n#endif\n }']
    * });
    *
    * // 2. Modify a fragment shader for picking
    * var source = createShaderSource({
    *   sources : ['void main() { gl_FragColor = vec4(1.0); }'],
    *   pickColorQualifier : 'uniform'
    * });
    *
    * @private
    */
    
    class func createShaderSource(defines defines: [String], sources: [String], pickColorQualifier: String? = nil) -> String {
        
        assert(pickColorQualifier == nil || pickColorQualifier == "uniform" || pickColorQualifier == "varying", "options.pickColorQualifier must be 'uniform' or 'varying'")
        
        var source = ""
        //var i
        //var length;
        
        // Stage 1.  Prepend #defines for uber-shaders
        for define in defines {
            source += "#define " + define + "\n"
        }
        
        // Stage 2.  Combine shader sources, generally for pseudo-polymorphism, e.g., czm_getMaterial.
        for shaderSource in sources {
            // #line needs to be on its own line.
            source += "\n#line 0\n" + shaderSource
        }
        
        
        // Stage 3.  Replace main() for picked if desired.
        if pickColorQualifier != nil {
            /*var renamedFS = source//.replace(/void\s+main\s*\(\s*(?:void)?\s*\)/g, "void czm_old_main()")
            var pickMain =
            pickColorQualifier + " vec4 czm_pickColor; \n" +
            "void main() \n" +
            "{ \n" +
            "    czm_old_main(); \n" +
            "    if (gl_FragColor.a == 0.0) { \n" +
            "        discard; \n" +
            "    } \n" +
            "    gl_FragColor = czm_pickColor; \n" +
            "}"
            
            source = renamedFS + "\n" + pickMain*/
        }
        
        return source
    }
    
}
