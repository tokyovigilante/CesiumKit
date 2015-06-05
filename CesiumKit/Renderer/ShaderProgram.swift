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
    
    var uniformBuffer: Buffer!
    
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
    
    let _attributeLocations: [String: Int]
    
    private var _program: GLuint? = nil
    
    var keyword: String {
        get {
            return _vertexShaderText + _fragmentShaderText + _attributeLocations.description
        }
    }

    var numberOfVertexAttributes: Int {
        return vertexAttributes.count
    }
    
    private (set) var vertexAttributes: [String: GLSLShaderVariableDescription]!
    
    var uniformsByName: [String: Uniform] {
        get {
            //initialize()
            return _uniformsByName!
        }
    }
    private var _uniformsByName = [String: Uniform]?()
    
    private var _uniforms: [Uniform]? = nil
    
    private var _automaticUniforms = [automaticTuple]()
    
    private var _manualUniforms = [Uniform]?()
    
    var maximumTextureUnitIndex: Int = 0
    
    var count: Int = 0
    
    let _id: Int
    
    init(device: MTLDevice, optimizer: GLSLOptimizer, logShaderCompilation: Bool = false, vertexShaderSource: ShaderSource, vertexShaderText: String, fragmentShaderSource: ShaderSource, fragmentShaderText: String, attributeLocations: [String: Int], id: Int) {

        _logShaderCompilation = logShaderCompilation
        self.vertexShaderSource = vertexShaderSource
        _vertexShaderText = vertexShaderText
        self.fragmentShaderSource = fragmentShaderSource
        _fragmentShaderText = fragmentShaderText
        _attributeLocations = attributeLocations
        _id = id
        count = 0
        
        initialize(device, optimizer: optimizer)
    }
    
    func initialize(device: MTLDevice, optimizer: GLSLOptimizer) {
        
        if _program != nil {
            return
        }
        _program = createMetalProgram(optimizer)
        compileMetalProgram(device)
        
        vertexAttributes = findVertexAttributes()

        var uniforms = findUniforms()
        var partitionedUniforms = partitionUniforms(uniforms.uniformsByName)
        
        /*_uniformsByName = uniforms.uniformsByName
        _uniforms = uniforms.uniforms
        _automaticUniforms = partitionedUniforms.automaticUniforms
        _manualUniforms = partitionedUniforms.manualUniforms
        
        maximumTextureUnitIndex = Int(setSamplerUniforms(uniforms.samplerUniforms))*/
    }

    
    private func createMetalProgram(optimizer: GLSLOptimizer) -> GLuint {
        
        _vertexShader = optimizer.optimize(.Vertex, shaderSource: _vertexShaderText, options: 0)
        assert(_vertexShader.status(), _vertexShader.log())
        _metalVertexShaderSource = _vertexShader.output()
        
        _fragmentShader = optimizer.optimize(.Fragment, shaderSource: _fragmentShaderText, options: 0)
        assert(_vertexShader.status(), _vertexShader.log())
        _metalFragmentShaderSource = _fragmentShader.output()
    
        return 0
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
    
    private func findVertexAttributes() -> [String: GLSLShaderVariableDescription] {
        
        assert(_program != nil, "no GLSL program")
        
        let attributeCount = _vertexShader.inputCount()
        
        var attributes = [String: GLSLShaderVariableDescription]()
        
        for i in 0..<attributeCount {
            var attribute = _vertexShader.inputDescription(i)
            attributes[attribute.name] = attribute
        }
        return attributes
    }
    
    private func findUniforms() -> (uniformsByName: [String: Uniform], uniforms : [Uniform], samplerUniforms : [Uniform]) {
        assert(_program != nil, "no GLSL program")

        
        var vertexUniformDescArray = [GLSLShaderVariableDescription]()
        let vertexUniformCount = _vertexShader.uniformCount()
        for i in 0..<vertexUniformCount {
            vertexUniformDescArray.append(_vertexShader.uniformDescription(i))
        }
        
        var fragmentUniformDescArray = [GLSLShaderVariableDescription]()
        let fragmentUniformCount = _fragmentShader.uniformCount()
        for i in 0..<fragmentUniformCount {
            fragmentUniformDescArray.append(_fragmentShader.uniformDescription(i))
        }

        var uniformsByName = Dictionary<String, Uniform>()
        var uniforms = [Uniform]()
        var samplerUniforms = [Uniform]()
        
        /*
        for i in 0..<Int(numberOfUniforms) {
            var uniformLength: GLsizei = 0
            var uniformNameBuffer = [GLchar](count: Int(maxUniformLength + 1), repeatedValue: 0)
            var uniformType: GLenum = 0
            var uniformSize: GLsizei = 0
            glGetActiveUniform(program, GLuint(i), GLsizei(maxUniformLength), &uniformLength, &uniformSize, &uniformType, &uniformNameBuffer)
            let activeUniform = ActiveUniformInfo(name: String.fromCString(UnsafePointer<CChar>(uniformNameBuffer))!, size: uniformSize, type: ActiveUniformInfo.dataType(uniformType))
            
            let suffix = "[0]"
            var uniformName = activeUniform.name
            if uniformName.hasSuffix(suffix) {
                let suffixRange = Range(
                    start: advance(uniformName.endIndex, -3),
                    end: uniformName.endIndex)
                uniformName.removeRange(suffixRange)
            }
            
            let uniform: Uniform
            if activeUniform.name.indexOf("[") == nil {
                // Single uniform
                let nameBuffer = UnsafePointer<GLchar>((uniformName as NSString).UTF8String)
                let location = GLint(glGetUniformLocation(program, nameBuffer))
                
                uniform = Uniform.create(activeUniform: activeUniform, name: uniformName, locations: [location])

            } else {
                var locations = [GLint]()
                for j in  0..<Int(activeUniform.size) {
                    let nameBuffer = UnsafePointer<GLchar>((uniformName + "[\(j)]" as NSString).UTF8String)
                    let location = GLint(glGetUniformLocation(program, nameBuffer))
                    locations.append(location)
                }
                uniform = Uniform.create(activeUniform: activeUniform, name: uniformName, locations: locations)
            }
            uniformsByName[uniformName] = uniform
            uniforms.append(uniform)
            
            if uniform is UniformSampler {
                samplerUniforms.append(uniform)
            }
            
        }
        */
        return (
            uniformsByName : uniformsByName,
            uniforms : uniforms,
            samplerUniforms : samplerUniforms
        )
    }
    
    typealias automaticTuple = (uniform: Uniform, automaticUniform: AutomaticUniform)
    
    private func partitionUniforms(uniforms: [String: Uniform]) -> (automaticUniforms: [automaticTuple], manualUniforms: [Uniform]) {
        var automaticUniforms = [automaticTuple]()
        var manualUniforms = [Uniform]()
        
        for (name, uniform) in uniforms {
            // FIXME: could use filter/map
            if let automaticUniform = AutomaticUniforms[name] {
                automaticUniforms.append((
                    uniform : uniform,
                    automaticUniform : automaticUniform
                ))
            } else {
                manualUniforms.append(uniform)
            }
        }
        return (automaticUniforms: automaticUniforms, manualUniforms: manualUniforms)
    }
    
    private func setSamplerUniforms(samplerUniforms: [Uniform]) -> GLint {
        
        glUseProgram(_program!)
        
        var textureUnitIndex: GLint = 0
        
        for uniform in samplerUniforms {
            if let samplerUniform = uniform as? UniformSampler {
                textureUnitIndex = samplerUniform.setSampler(textureUnitIndex)
            }
        }
        
        glUseProgram(0)
        
        return textureUnitIndex
    }
    
    func setUniforms (uniformMap: UniformMap?, uniformState: UniformState, validate: Bool) {
        
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

        for automaticUniform in _automaticUniforms {
         /*   if let uniform: FloatUniform = automaticUniform.uniform as? FloatUniform {
                uniform.setFloatValues(automaticUniform.automaticUniform.getValue(uniformState: uniformState))
            }*/
        }
        
        
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
        }*/
    }
    
    deinit {
        if _program != nil {
            glDeleteProgram(_program!)
        }
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
