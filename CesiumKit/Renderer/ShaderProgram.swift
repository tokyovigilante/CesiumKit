//
//  ShaderProgram.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import OpenGLES

// represents WebGLActiveInfo
struct ActiveUniformInfo {
    
    var name: String = ""
    
    var size: GLsizei = 0
    
    var type: GLenum = 0
}

struct VertexAttributeInfo {
    
    var name: String = ""
    
    var type: GLenum = 0
    
    var index: GLenum = 0
}



private class DependencyNode: Equatable {
    
    var name: String
    
    var glslSource: String
    
    var dependsOn = [DependencyNode]()
    
    var requiredBy = [DependencyNode]()
    
    var evaluated: Bool = false
    
    init (
        name: String,
        glslSource: String,
        dependsOn: [DependencyNode] = [DependencyNode](),
        requiredBy: [DependencyNode] = [DependencyNode](),
        evaluated: Bool = false)
    {
        self.name = name
        self.glslSource = glslSource
        self.dependsOn = dependsOn
        self.requiredBy = requiredBy
        self.evaluated = evaluated
    }
    
}

private func == (left: DependencyNode, right: DependencyNode) -> Bool {
    return left.name == right.name &&
        left.glslSource == right.glslSource
}

class ShaderProgram {

    var _logShaderCompilation: Bool = false
    
    /**
    * GLSL source for the shader program's vertex shader.  This is the version of
    * the source provided when the shader program was created, not the final
    * source provided to WebGL, which includes Cesium bulit-ins.
    *
    * @memberof ShaderProgram.prototype
    *
    * @type {String}
    * @readonly
    */
    let _vertexShaderSource: String
    
    /**
    * GLSL source for the shader program's fragment shader.  This is the version of
    * the source provided when the shader program was created, not the final
    * source provided to WebGL, which includes Cesium bulit-ins.
    *
    * @memberof ShaderProgram.prototype
    *
    * @type {String}
    * @readonly
    */
    let _fragmentShaderSource: String
    
    let _attributeLocations: [String: Int]? = nil
    
    private var _program: GLuint? = nil
    
    var keyword: String {
        get {
            return _vertexShaderSource + _fragmentShaderSource + (_attributeLocations == nil ? "" :_attributeLocations!.description)
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
    
    var manualUniforms: [String: Uniform] {
        get {
            initialize()
            return _manualUniforms!
        }
    }
    private var _manualUniforms = [String: Uniform]?()
    
    var maximumTextureUnitIndex: Int = 0
    
    var count: Int = 0
    
    let _id: Int
    
    private let _commentRegex = Regex("/\\*\\*[\\s\\S]*?\\*/")
    private let _lineRegex = Regex("\\n")
    private let _czmRegex = Regex("\\bczm_[a-zA-Z0-9_]*")

    init(logShaderCompilation: Bool = false, vertexShaderSource: String, fragmentShaderSource: String, attributeLocations: [String: Int]? = nil, id: Int) {
        
        _logShaderCompilation = logShaderCompilation
        _attributeLocations = attributeLocations
        _vertexShaderSource = vertexShaderSource
        _fragmentShaderSource = fragmentShaderSource
        _id = id
        count = 0
    }
    
    private func extractShaderVersion(source: String) -> (version: String, source: String) {
        // This will fail if the first #version is actually in a comment.
        //var index = source.indexOf("#version")
        var index = source.indexOf("#version")
        
        if (index != nil) {
            var newLineIndex = source.indexOf("\n", startIndex: index)
            /*
            // We could throw an exception if there is not a new line after
            // #version, but the GLSL compiler will catch it.
            if (newLineIndex != nil) {
            // Extract #version directive, including the new line.
            var version = source.substringWithRange(Range(index!, advance(newLineIndex!, 1)))
            
            // Comment out original #version directive so the line numbers
            // are not off by one.  There can be only one #version directive
            // and it must appear at the top of the source, only preceded by
            // whitespace and comments.
            var modified = source.substring(0, index) + '//' + source.substring(index);
            
            return {
            version : version,
            source : modified
            };
            }*/
        }
        
        return (
            version: "", // defaults to #version 100
            source : source // no modifications required
        )
    }
    
    private func getDependencyNode(name: String, glslSource: String, inout nodes: [DependencyNode]) -> DependencyNode {
        
        var dependencyNode: DependencyNode?
        
        // check if already loaded
        for node in nodes {
            if node.name == name {
                dependencyNode = node
            }
        }
        
        if dependencyNode == nil {
            
            var newGLSLSource = glslSource
            // strip doc comments so we don't accidentally try to determine a dependency for something found
            // in a comment
            var commentBlocks = _commentRegex.matches(glslSource)
            if commentBlocks.count > 0 {
                // FIXME: shader comments
                for var i = 0; i < commentBlocks.count; ++i {
                    
                    let commentBlock = commentBlocks[i] as NSTextCheckingResult
                    let matchRange = Range(start: commentBlock.range.location, end: commentBlock.range.location + commentBlock.range.length)
                    let comment = glslSource[matchRange]
                    let numberOfLines = _lineRegex.matches(comment).count
                    
                    // preserve the number of lines in the comment block so the line numbers will be correct when debugging shaders
                    var modifiedComment = ""
                    for var lineNumber = 0; lineNumber < numberOfLines; ++lineNumber {
                        if (lineNumber == 0) {
                            modifiedComment += "// Comment replaced to prevent problems when determining dependencies on built-in functions\n"
                        } else {
                            modifiedComment += "//\n"
                        }
                    }
                    
                    newGLSLSource = newGLSLSource.replace(comment, modifiedComment)
                }
            }
            // create new node
            dependencyNode = DependencyNode(name: name, glslSource: newGLSLSource)
            nodes << dependencyNode!
        }
        
        return dependencyNode!
    }
    
    private func generateDependencies(currentNode: DependencyNode, inout dependencyNodes: [DependencyNode]) {
        if currentNode.evaluated {
            return
        }
        
        currentNode.evaluated = true
        
        // identify all dependencies that are referenced from this glsl source code
        var czmMatchRanges = _czmRegex.matches(currentNode.glslSource) as [NSTextCheckingResult]
        var czmMatches: [String]
        if czmMatchRanges.count > 0 {
            czmMatches = czmMatchRanges.map({
                currentNode.glslSource[Range(start: $0.range.location, end: $0.range.location + $0.range.length)]
            })
            czmMatches = deleteDuplicates(czmMatches)
            
            for match in czmMatches {
                if (match != currentNode.name) {
                    var elementSource: String? = nil
                    if let builtin = Builtins[match] {
                        elementSource = builtin
                    } else if let uniform = AutomaticUniforms[match] {
                        elementSource = uniform.declaration(match)
                    } else {
                        println("uniform \(match) not found")
                    }
                    if elementSource != nil {
                        var referencedNode = getDependencyNode(match, glslSource: elementSource!, nodes: &dependencyNodes)
                        currentNode.dependsOn.append(referencedNode)
                        referencedNode.requiredBy.append(currentNode)
                        
                        // recursive call to find any dependencies of the new node
                        generateDependencies(referencedNode, dependencyNodes: &dependencyNodes)
                    }
                }
                
            }
        }
    }
    
    
    private func sortDependencies(inout dependencyNodes: [DependencyNode]) {
        
        var nodesWithoutIncomingEdges = [DependencyNode]()
        var allNodes = [DependencyNode]()
        
        while (dependencyNodes.count > 0) {
            var node = dependencyNodes.removeLast()
            allNodes.append(node)
            
            if node.requiredBy.count == 0 {
                nodesWithoutIncomingEdges.append(node)
            }
        }
        
        while nodesWithoutIncomingEdges.count > 0 {
            var currentNode = nodesWithoutIncomingEdges.removeAtIndex(0)
            
            dependencyNodes.append(currentNode)
            for (var i = 0; i < currentNode.dependsOn.count; ++i) {
                // remove the edge from the graph
                var referencedNode = currentNode.dependsOn[i]
                var index = find(referencedNode.requiredBy, currentNode)
                if (index != nil) {
                    referencedNode.requiredBy.removeAtIndex(index!)
                }
                
                // if referenced node has no more incoming edges, add to list
                if referencedNode.requiredBy.count == 0 {
                    nodesWithoutIncomingEdges.append(referencedNode)
                }
            }
        }
        
        // if there are any nodes left with incoming edges, then there was a circular dependency somewhere in the graph
        var badNodes = [DependencyNode]()
        for node in allNodes {
            if node.requiredBy.count != 0 {
                badNodes.append(node)
            }
        }
        if badNodes.count != 0 {
            var message = "A circular dependency was found in the following built-in functions/structs/constants: \n"
            for node in badNodes {
                message += node.name + "\n"
            }
            fatalError(message)
        }
    }
    
    private func getBuiltinsAndAutomaticUniforms(shaderSource: String) -> String {
        // generate a dependency graph for builtin functions
        
        var dependencyNodes = [DependencyNode]()
        var root = getDependencyNode("main", glslSource: shaderSource, nodes: &dependencyNodes)
        generateDependencies(root, dependencyNodes: &dependencyNodes)
        sortDependencies(&dependencyNodes)
        
        // Concatenate the source code for the function dependencies.
        // Iterate in reverse so that dependent items are declared before they are used.
        return reverse(dependencyNodes)
            .reduce("", { $0 + $1.glslSource + "\n" })
            .replace(root.glslSource, "")
    }
    
    private func getFragmentShaderPrecision() -> String {
        return "#ifdef GL_FRAGMENT_PRECISION_HIGH \n" +
            "  precision highp float; \n" +
            "#else \n" +
            "  precision mediump float; \n" +
        "#endif \n\n"
    }
    
    private func createAndLinkProgram(logShaderCompilation: Bool, vertexShaderSource: String, fragmentShaderSource: String, attributeLocations: [String: Int]?) -> GLuint {
        
        let vsSourceVersioned = extractShaderVersion(vertexShaderSource)
        let fsSourceVersioned = extractShaderVersion(fragmentShaderSource)
        
        var vsSource = vsSourceVersioned.version +
            getBuiltinsAndAutomaticUniforms(vsSourceVersioned.source) +
            "\n#line 0\n" +
            vsSourceVersioned.source
        
        var fsSource = fsSourceVersioned.version +
            getFragmentShaderPrecision() +
            getBuiltinsAndAutomaticUniforms(fsSourceVersioned.source) +
            "\n#line 0\n" +
            fsSourceVersioned.source
        
        var log: GLint = 0
        
        var shaderCount: GLsizei = 1
        
        var vertexSourceUTF8 = UnsafePointer<GLchar>((vsSource as NSString).UTF8String)
        var vertexSourceLength = GLint(vsSource.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        
        var vertexShader: GLuint = glCreateShader(GLenum(GL_VERTEX_SHADER))
        glShaderSource(vertexShader, shaderCount, &vertexSourceUTF8, &vertexSourceLength)
        glCompileShader(vertexShader)
        
        var fragmentSourceUTF8 = UnsafePointer<GLchar>((fsSource as NSString).UTF8String)
        var fragmentSourceLength = GLint(fsSource.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        
        var fragmentShader: GLuint = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        glShaderSource(fragmentShader, shaderCount, &fragmentSourceUTF8, &fragmentSourceLength)
        glCompileShader(fragmentShader)
        
        let program = glCreateProgram()
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        if _attributeLocations != nil {
            for (key, value) in _attributeLocations! {
                glBindAttribLocation(program, GLuint(value), (key as NSString).UTF8String)
            }
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
                fatalError("[GL] Vertex shader compile log: " + errorMessage!)
            }
            
            glGetShaderiv(fragmentShader, GLenum(GL_COMPILE_STATUS), &status)
            
            if status == 0 {
                glGetShaderiv(fragmentShader, GLenum(GL_INFO_LOG_LENGTH), &infoLogLength)
                var strInfoLog = [GLchar](count: Int(infoLogLength + 1), repeatedValue: 0)
                var actualLength: GLsizei = 0
                glGetShaderInfoLog(fragmentShader, infoLogLength, &actualLength, &strInfoLog)
                let errorMessage = String.fromCString(UnsafePointer<CChar>(strInfoLog))
                println(fsSource)
                fatalError("[GL] Fragment shader compile log: " + errorMessage!)
            }
            
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &infoLogLength)
            var strInfoLog = [GLchar](count: Int(infoLogLength + 1), repeatedValue: 0)
            var actualLength: GLsizei = 0
            glGetProgramInfoLog(program, infoLogLength, &actualLength, &strInfoLog)
            glDeleteProgram(program)
            let errorMessage = String.fromCString(UnsafePointer<CChar>(strInfoLog))
            fatalError("Program failed to link.  Link log: " + errorMessage!)
        }
        /*
        if (logShaderCompilation) {
        log = gl.getShaderInfoLog(vertexShader);
        if (defined(log) && (log.length > 0)) {
        console.log('[GL] Vertex shader compile log: ' + log);
        }
        }
        
        if (logShaderCompilation) {
        log = gl.getShaderInfoLog(fragmentShader);
        if (defined(log) && (log.length > 0)) {
        console.log('[GL] Fragment shader compile log: ' + log);
        }
        }
        
        if (logShaderCompilation) {
        log = gl.getProgramInfoLog(program);
        if (defined(log) && (log.length > 0)) {
        console.log('[GL] Shader program link log: ' + log);
        }
        }
        */
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
        
        for var i = 0; i < Int(numberOfUniforms); ++i {
            var uniformLength: GLsizei = 0
            var uniformNameBuffer = [GLchar](count: Int(uniformLength + 1), repeatedValue: 0)
            var activeUniform = ActiveUniformInfo()
            glGetActiveUniform(program, GLuint(i), GLsizei(maxUniformLength), &uniformLength, &activeUniform.size, &activeUniform.type, &uniformNameBuffer)
            /*var uniformName = String.fromCString(UnsafePointer<CChar>(uniformNameBuffer))!
            
            let suffix = "[0]"*/
            /*
            if uniformName.hasSuffix(suffix) {
                let suffixRange = Range(
                    start: advance(uniformName.endIndex, -3),
                    end: uniformName.endIndex)
                uniformName.removeRange(suffixRange)
            }*/
            activeUniform.name = uniformName

            /*if !activeUniform.name.hasPrefix("gl_") {
                if activeUniform.name.indexOf("[") == nil {
                    // Single uniform
                    /*let nameBuffer = UnsafePointer<GLchar>((activeUniform.name as NSString).UTF8String)
                    let location = GLint(glGetUniformLocation(program, nameBuffer))
                    assert(glGetError() == GLenum(GL_NO_ERROR))
                    var value: GLfloat = 0.0
                    /*glGetUniformfv(program, location, &value)
                    assert(glGetError() == GLenum(GL_NO_ERROR))*/
                    var uniform = Uniform(activeUniform: activeUniform, uniformName: uniformName, location: location, value: .FloatVec1(value))
                    
                    uniformsByName[activeUniform.name] = uniform
                    uniforms.append(uniform)
                    
                    if uniform.hasSetSampler {
                        samplerUniforms.append(uniform)
                    }*/
                } else {
                    // Uniform array
                    
                    /*var uniformArray: UniformArray*/
                    var locations = [GLint]()
                    /*var value;
                    var loc;
                    
                    // On some platforms - Nexus 4 in Firefox for one - an array of sampler2D ends up being represented
                    // as separate uniforms, one for each array element.  Check for and handle that case.
                    var indexOfBracket = uniformName.indexOf('[');
                    if (indexOfBracket >= 0) {
                    // We're assuming the array elements show up in numerical order - it seems to be true.
                    uniformArray = uniformsByName[uniformName.slice(0, indexOfBracket)];
                    
                    // Nexus 4 with Android 4.3 needs this check, because it reports a uniform
                    // with the strange name webgl_3467e0265d05c3c1[1] in our globe surface shader.
                    if (typeof uniformArray === 'undefined') {
                    continue;
                    }
                    
                    locations = uniformArray._locations;
                    
                    // On the Nexus 4 in Chrome, we get one uniform per sampler, just like in Firefox,
                    // but the size is not 1 like it is in Firefox.  So if we push locations here,
                    // we'll end up adding too many locations.
                    if (locations.length <= 1) {
                    value = uniformArray.value;
                    loc = gl.getUniformLocation(program, uniformName);
                    locations.push(loc);
                    value.push(gl.getUniform(program, loc));
                    }
                    } else {
                    locations = [];
                    value = [];
                    for ( var j = 0; j < activeUniform.size; ++j) {
                    loc = gl.getUniformLocation(program, uniformName + '[' + j + ']');
                    locations.push(loc);
                    value.push(gl.getUniform(program, loc));
                    }
                    uniformArray = new UniformArray(gl, activeUniform, uniformName, locations, value);
                    
                    uniformsByName[uniformName] = uniformArray;
                    uniforms.push(uniformArray);
                    
                    if (uniformArray._setSampler) {
                    samplerUniforms.push(uniformArray);
                    }
                    }
                    }*/
                }
            }*/
        }
        
        return (
            uniformsByName : uniformsByName,
            uniforms : uniforms,
            samplerUniforms : samplerUniforms
        )
    }
    
    typealias automaticTuple = (uniform: Uniform, automaticUniform: AutomaticUniform)
    
    private func partitionUniforms(uniforms: [String: Uniform]) -> (automaticUniforms: [automaticTuple], manualUniforms: [String: Uniform]) {
        var automaticUniforms = [automaticTuple]()
        var manualUniforms = [String: Uniform]()
        
        for (name, uniform) in uniforms {
            // FIXME: could use filter/map
            if let automaticUniform = AutomaticUniforms[name] {
                automaticUniforms.append((
                    uniform : uniform,
                    automaticUniform : automaticUniform
                ))
            } else {
                manualUniforms[name] = uniform
            }
        }
        return (automaticUniforms: automaticUniforms, manualUniforms: manualUniforms)
    }
    
    private func setSamplerUniforms(samplerUniforms: [Uniform]) -> GLint {
        
        glUseProgram(_program!)
        
        var textureUnitIndex: GLint = 0
        for samplerUniform in samplerUniforms {
            textureUnitIndex = samplerUniform.setSampler!(textureUnitIndex: textureUnitIndex)
        }
        
        glUseProgram(0)
        
        return textureUnitIndex
    }
    
    func initialize() {
        
        if _program != nil {
            return
        }
        
        _program = createAndLinkProgram(_logShaderCompilation, vertexShaderSource: _vertexShaderSource, fragmentShaderSource: _fragmentShaderSource, attributeLocations: _attributeLocations)
        
        glGetProgramiv(_program!, GLenum(GL_ACTIVE_ATTRIBUTES), &_numberOfVertexAttributes)
        assert(glGetError() == GLenum(GL_NO_ERROR), "GL call failed")

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
        assert(glGetError() == GLenum(GL_NO_ERROR), "GL call failed")
    }
    
    func setUniforms (uniformMap: TileUniformMap?, uniformState: UniformState, validate: Bool) {
        // TODO: Performance

        if uniformMap != nil {
            for (name, uniform) in _manualUniforms! {
                if let uniformFunc: UniformFunc = uniformMap!.uniforms[name] {
                    uniform.value = uniformFunc(map: uniformMap!)
                } else {
                    assert(true, "no matching uniform for \(name)")
                }
            }
        }
        for automaticUniform in _automaticUniforms {
            automaticUniform.uniform.value = automaticUniform.automaticUniform.getValue(uniformState: uniformState)
        }
        
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
                    fatalError("Program validation failed.  Link log: " + errorMessage!)
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

typealias UniformFunc = ((map: TileUniformMap) -> UniformValue)

