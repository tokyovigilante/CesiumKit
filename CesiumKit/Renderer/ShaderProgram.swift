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

struct VertexAttributeInfo {
    
    var name: String = ""
    
    var type: GLenum = 0
    
    var index: GLenum = 0
        
}

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
    
    private var _samplerUniforms: [Uniform]!
    
    let _attributeLocations: [String: Int]
    
    let keyword: String

    var numberOfVertexAttributes: Int {
        return vertexAttributes.count
    }
    
    private (set) var vertexAttributes: [String: GLSLShaderVariableDescription]!
    
    private var _uniforms: [Uniform]!
    
    var maximumTextureUnitIndex: Int = 0
    
    var count: Int = 0
    
    let _id: Int
    
    init(context: Context, optimizer: GLSLOptimizer, logShaderCompilation: Bool = false, vertexShaderSource: ShaderSource, vertexShaderText: String, fragmentShaderSource: ShaderSource, fragmentShaderText: String, attributeLocations: [String: Int], id: Int) {

        _logShaderCompilation = logShaderCompilation
        self.vertexShaderSource = vertexShaderSource
        _vertexShaderText = vertexShaderText
        self.fragmentShaderSource = fragmentShaderSource
        _fragmentShaderText = fragmentShaderText
        _attributeLocations = attributeLocations
        _id = id
        count = 0
        keyword = _vertexShaderText + _fragmentShaderText + _attributeLocations.description
        initialize(context, optimizer: optimizer)
    }
    
    func createUniformBuffers(context: Context) -> (vertex: Buffer, fragment: Buffer, sampler: Buffer) {
        let vSize = Int(_vertexShader.uniformTotalSize())
        let v = context.createBuffer(componentDatatype: .UnsignedByte, sizeInBytes: vSize > 0 ? vSize : 1)
        
        let fSize = Int(_fragmentShader.uniformTotalSize())
        let f = context.createBuffer(componentDatatype: .UnsignedByte, sizeInBytes: fSize > 0 ? fSize : 1)
        
        let sSize = Int(_fragmentShader.textureCount())
        let s = context.createBuffer(componentDatatype: .UnsignedByte, sizeInBytes: sSize > 0 ? sSize : 1)
        
        return (vertex: v, fragment: f, sampler: s)
    }
    
    private func initialize(context: Context, optimizer: GLSLOptimizer) {

        createMetalProgram(optimizer)
        compileMetalProgram(context.device)
        
        findVertexAttributes()
        findUniforms()
        createUniformBuffers(context)
        
       /* maximumTextureUnitIndex = Int(setSamplerUniforms(uniforms.samplerUniforms))*/
    }
    
    private func createMetalProgram(optimizer: GLSLOptimizer) {
        
        _vertexShader = optimizer.optimize(.Vertex, shaderSource: _vertexShaderText, options: 0)
        assert(_vertexShader.status(), _vertexShader.log())
        _metalVertexShaderSource = _vertexShader.output()
        
        _fragmentShader = optimizer.optimize(.Fragment, shaderSource: _fragmentShaderText, options: 0)
        assert(_vertexShader.status(), _vertexShader.log())
        _metalFragmentShaderSource = _fragmentShader.output()
    }
    
    private func compileMetalProgram(device: MTLDevice) {
        var error: NSError?
        _vertexLibrary = device.newLibraryWithSource(_metalVertexShaderSource, options: nil, error: &error)
        if _vertexLibrary == nil {
            println(error!.localizedDescription)
            assertionFailure("_vertexLibrary == nil")
        }
        metalVertexFunction = _vertexLibrary.newFunctionWithName("xlatMtlMain")
        
        _fragmentLibrary = device.newLibraryWithSource(_metalFragmentShaderSource, options: nil, error: &error)
        if _fragmentLibrary == nil {
            println(_fragmentShaderText)
            println(_metalFragmentShaderSource)
            println(error!.localizedDescription)
            assertionFailure("_library == nil")
        }
        metalFragmentFunction = _fragmentLibrary.newFunctionWithName("xlatMtlMain")
    }
    
    private func findVertexAttributes() {
        let attributeCount = _vertexShader.inputCount()
        
        vertexAttributes = [String: GLSLShaderVariableDescription]()
        
        for i in 0..<attributeCount {
            var attribute = _vertexShader.inputDescription(i)
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

        _samplerUniforms = [Uniform]()
        let samplerUniformCount = _fragmentShader.textureCount()
        for i in 0..<samplerUniformCount {
            let desc =  _fragmentShader.textureDescription(i)
            _samplerUniforms.append(Uniform.create(desc: desc, type: .Sampler))
        }
    }
        
    private func setSamplerUniforms(samplerUniforms: [Uniform]) -> GLint {
        
        
        var textureUnitIndex: GLint = 0
        
        for uniform in samplerUniforms {
            if let samplerUniform = uniform as? UniformSampler {
                textureUnitIndex = samplerUniform.setSampler(textureUnitIndex)
            }
        }
            
        return textureUnitIndex
    }
    
    func setUniforms (command: DrawCommand, uniformState: UniformState) {
        
        for uniform in _vertexUniforms {
            setUniform(uniform, buffer: command.vertexUniformBuffer, uniformMap: command.uniformMap, uniformState: uniformState)
        }
    
        for uniform in _fragmentUniforms {
            setUniform(uniform, buffer: command.fragmentUniformBuffer, uniformMap: command.uniformMap, uniformState: uniformState)
        }
        
        for uniform in _samplerUniforms {
            //setUniform(uniform, buffer: command.samplerUniformBuffer, uniformMap: command.uniformMap?, uniformState: uniformState)

        }
        /*
        
        if let uniformMap = uniformMap {
            
            
            
            let czm_projection = AutomaticUniforms["czm_projection"]!
            var floatCZMPR = czm_projection.getValue(uniformState: uniformState)
            
            let u_modifiedModelView = uniformMap.floatUniform("u_modifiedModelView")!
            var floatMMV = u_modifiedModelView(map: uniformMap)
            
            let u_initialColor = uniformMap.floatUniform("u_initialColor")!
            var floatUIC = u_initialColor(map: uniformMap)
            
            var bufferData = uniformBuffer.data
            memcpy(bufferData, floatCZMPR, sizeof(Float) * 16)
            memcpy(bufferData+64, floatMMV, sizeof(Float) * 16)
            memcpy(bufferData+128, floatUIC, sizeof(Float) * 4)
        }
        // TODO: Performance
        if let uniformMap = uniformMap {
            // FIXME: uniforms
            /*for uniform in _manualUniforms! {
                if uniform.isFloat {
                    if let uniformFloatFunc = uniformMap.floatUniform(uniform.name) {
                        (uniform as! FloatUniform).setFloatValues(uniformFloatFunc(map: uniformMap))
                    }
                } else {
                    if let uniformFunc = uniformMap[uniform.name] {
                        uniform.setValues(uniformFunc(map: uniformMap))
                    }
                    /*} else {
                    assertionFailure("no matching uniform for \(uniform.name)")
                    }*/
                }
            }*/
        }

        /*for automaticUniform in _automaticUniforms {
         /*   if let uniform: FloatUniform = automaticUniform.uniform as? FloatUniform {
                uniform.setFloatValues(automaticUniform.automaticUniform.getValue(uniformState: uniformState))
            }*/
        }*/
        
        
        // It appears that assigning the uniform values above and then setting them here
        // (which makes the GL calls) is faster than removing this loop and making
        // the GL calls above.  I suspect this is because each GL call pollutes the
        // L2 cache making our JavaScript and the browser/driver ping-pong cache lines.
        return
        /*for uniform in _uniforms! {
            uniform.set()
            if validate {
                glValidateProgram(_program!)
                var err: GLenum
                var status: GLint = 0
                glGetProgramiv(_program!, GLenum(GL_VALIDATE_STATUS), &status)
                if status != GLint(GL_TRUE) {
                    var infoLogLength: GLsizei = 0
                    glGetProgramiv(_program!, GLenum(GL_INFO_LOG_LENGTH), &infoLogLength)
                    var strInfoLog = [GLchar](count: Int(infoLogLength + 1), repeatedValue: 0)
                    var actualLength: GLsizei = 0
                    glGetProgramInfoLog(_program!, infoLogLength, &actualLength, &strInfoLog)
                    let errorMessage = String.fromCString(UnsafePointer<CChar>(strInfoLog))
                    assertionFailure("Program validation failed.  Program info log: " + errorMessage!)
                }
            }
        }*/*/
    }
    
    func setUniform (uniform: Uniform, buffer: Buffer, uniformMap: UniformMap?, uniformState: UniformState) {
        switch (uniform.type) {
        case .Automatic:
            if let automaticUniform = AutomaticUniforms[uniform.name] {
                memcpy(buffer.data+uniform.location, automaticUniform.getValue(uniformState: uniformState), uniform.rawSize)
            }
        case .Manual:
            if let uniformFloatFunc = uniformMap!.floatUniform(uniform.name) {
                memcpy(buffer.data+uniform.location, uniformFloatFunc(map: uniformMap!), uniform.rawSize)
            }
        case .Sampler:
            assertionFailure("Sampler not implemented")
        }
        //uniform.set(buffer)
    }
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
    
    class func createShaderSource(#defines: [String], sources: [String], pickColorQualifier: String? = nil) -> String {
        
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
