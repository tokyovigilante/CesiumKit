//
//  ShaderProgram.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import OpenGLES

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
    
    let _attributeLocations: [String: Int]
    
    private var _program: GLuint? = nil
    
    var keyword: String {
        get {
            return _vertexShaderText + _fragmentShaderText + _attributeLocations.description
        }
    }
    
    var numberOfVertexAttributes: Int {
        get {
            initialize()
            return Int(_numberOfVertexAttributes)
        }
        
    }
    private var _numberOfVertexAttributes: GLint = 0
    
    var vertexAttributes: [String: VertexAttributeInfo] {
        get {
            initialize()
            return _vertexAttributes
        }
    }
    private var _vertexAttributes = [String: VertexAttributeInfo]()
    
    
    var uniformsByName: [String: Uniform] {
        get {
            initialize()
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
    
    init(logShaderCompilation: Bool = false, vertexShaderSource: ShaderSource, vertexShaderText: String, fragmentShaderSource: ShaderSource, fragmentShaderText: String, attributeLocations: [String: Int], id: Int) {
        
        _logShaderCompilation = logShaderCompilation
        self.vertexShaderSource = vertexShaderSource
        _vertexShaderText = vertexShaderText
        self.fragmentShaderSource = fragmentShaderSource
        _fragmentShaderText = fragmentShaderText
        _attributeLocations = attributeLocations
        _id = id
        count = 0
    }
    
    private func createAndLinkProgram() -> GLuint {
        
        var log: GLint = 0
        
        var shaderCount: GLsizei = 1
        
        var vertexSourceUTF8 = UnsafePointer<GLchar>((_vertexShaderText as NSString).UTF8String)
        var vertexSourceLength = GLint(_vertexShaderText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        
        let vertexShader: GLuint = glCreateShader(GLenum(GL_VERTEX_SHADER))
        glShaderSource(vertexShader, shaderCount, &vertexSourceUTF8, &vertexSourceLength)
        glCompileShader(vertexShader)
        
        var fragmentSourceUTF8 = UnsafePointer<GLchar>((_fragmentShaderText as NSString).UTF8String)
        var fragmentSourceLength = GLint(_fragmentShaderText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        
        let fragmentShader: GLuint = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        glShaderSource(fragmentShader, shaderCount, &fragmentSourceUTF8, &fragmentSourceLength)
        glCompileShader(fragmentShader)
        
        let program = glCreateProgram()
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        for (key, value) in _attributeLocations {
            glBindAttribLocation(program, GLuint(value), (key as NSString).UTF8String)
        }
        
        glLinkProgram(program)
        
        var status: GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        
        if status == 0 {
            // For performance, only check compile errors if there is a linker error.
            
            var infoLogLength: GLint = 0
            
            glGetShaderiv(vertexShader, GLenum(GL_COMPILE_STATUS), &status)
            
            if status == 0 {
                glGetShaderiv(vertexShader, GLenum(GL_INFO_LOG_LENGTH), &infoLogLength)
                var strInfoLog = [GLchar](count: Int(infoLogLength + 1), repeatedValue: 0)
                var actualLength: GLsizei = 0
                glGetShaderInfoLog(vertexShader, infoLogLength, &actualLength, &strInfoLog)
                let errorMessage = String.fromCString(UnsafePointer<CChar>(strInfoLog))
                println(_vertexShaderText)
                assertionFailure("[GL] Vertex shader compile log: " + errorMessage!)
                
            }
            
            glGetShaderiv(fragmentShader, GLenum(GL_COMPILE_STATUS), &status)
            
            if status == 0 {
                glGetShaderiv(fragmentShader, GLenum(GL_INFO_LOG_LENGTH), &infoLogLength)
                var strInfoLog = [GLchar](count: Int(infoLogLength + 1), repeatedValue: 0)
                var actualLength: GLsizei = 0
                glGetShaderInfoLog(fragmentShader, infoLogLength, &actualLength, &strInfoLog)
                let errorMessage = String.fromCString(UnsafePointer<CChar>(strInfoLog))
                println(_fragmentShaderText)
                assertionFailure("[GL] Fragment shader compile log: " + errorMessage!)
            }
            
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &infoLogLength)
            var strInfoLog = [GLchar](count: Int(infoLogLength + 1), repeatedValue: 0)
            var actualLength: GLsizei = 0
            glGetProgramInfoLog(program, infoLogLength, &actualLength, &strInfoLog)
            glDeleteProgram(program)
            let errorMessage = String.fromCString(UnsafePointer<CChar>(strInfoLog))
            assertionFailure("Program failed to link.  Link log: " + errorMessage!)
        }
        return program
    }
    
    typealias VertexAttribute = (name: String, type: GLenum, index: GLint)
    
    private func findVertexAttributes(numberOfAttributes: Int) -> [String: VertexAttributeInfo] {
        
        assert(_program != nil, "no GLSL program")
        let program = _program!
        
        var attributes = [String: VertexAttributeInfo]()
        
        for var i = 0; i < numberOfAttributes; ++i {
            
            var maxVertexAttribLength: GLint = 0
            glGetProgramiv(program, GLenum(GL_ACTIVE_ATTRIBUTE_MAX_LENGTH), &maxVertexAttribLength)
            
            var vertexAttribNameBuffer = [GLchar](count: Int(maxVertexAttribLength), repeatedValue: 0)
            var attr = VertexAttributeInfo()
            var vertexAttribSize: GLint = 0
            var vertexAttribLength: GLsizei = 0
            
            glGetActiveAttrib(program, GLuint(i), GLsizei(maxVertexAttribLength), &vertexAttribLength, &vertexAttribSize, &attr.type, &vertexAttribNameBuffer)
            attr.name = String.fromCString(UnsafePointer<CChar>(vertexAttribNameBuffer))!
            attr.index = GLenum(i)
            
            attributes[attr.name] = attr
        }
        return attributes
    }
    
    private func findUniforms() -> (uniformsByName: [String: Uniform], uniforms : [Uniform], samplerUniforms : [Uniform]) {
        
        assert(_program != nil, "no GLSL program")
        let program = _program!
        
        var numberOfUniforms: GLint = 0
        glGetProgramiv(program, GLenum(GL_ACTIVE_UNIFORMS), &numberOfUniforms)
        
        var uniformsByName = Dictionary<String, Uniform>()
        var uniforms = [Uniform]()
        var samplerUniforms = [Uniform]()
        
        var maxUniformLength: GLint = 0
        glGetProgramiv(program, GLenum(GL_ACTIVE_UNIFORM_MAX_LENGTH), &maxUniformLength)
        
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
    
    func initialize() {
        
        if _program != nil {
            return
        }
        
        _program = createAndLinkProgram()
        
        glGetProgramiv(_program!, GLenum(GL_ACTIVE_ATTRIBUTES), &_numberOfVertexAttributes)
        
        var uniforms = findUniforms()
        var partitionedUniforms = partitionUniforms(uniforms.uniformsByName)
        
        _vertexAttributes = findVertexAttributes(numberOfVertexAttributes)
        _uniformsByName = uniforms.uniformsByName
        _uniforms = uniforms.uniforms
        _automaticUniforms = partitionedUniforms.automaticUniforms
        _manualUniforms = partitionedUniforms.manualUniforms
        
        maximumTextureUnitIndex = Int(setSamplerUniforms(uniforms.samplerUniforms))
    }
    
    func bind () {
        initialize()
        glUseProgram(_program!)
    }
    
    func setUniforms (uniformMap: UniformMap?, uniformState: UniformState, validate: Bool) {
        // TODO: Performance
        if let uniformMap = uniformMap {
            for uniform in _manualUniforms! {
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
            }
        }

        for automaticUniform in _automaticUniforms {
            if let uniform: FloatUniform = automaticUniform.uniform as? FloatUniform {
                uniform.setFloatValues(automaticUniform.automaticUniform.getValue(uniformState: uniformState))
            }
        }
        
        
        // It appears that assigning the uniform values above and then setting them here
        // (which makes the GL calls) is faster than removing this loop and making
        // the GL calls above.  I suspect this is because each GL call pollutes the
        // L2 cache making our JavaScript and the browser/driver ping-pong cache lines.
        return
        for uniform in _uniforms! {
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
        }
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
