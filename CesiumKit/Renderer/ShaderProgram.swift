//
//  ShaderProgram.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import OpenGLES

/*

    var scratchUniformMatrix2;
    var scratchUniformMatrix3;
    var scratchUniformMatrix4;
    if (FeatureDetection.supportsTypedArrays()) {
    scratchUniformMatrix2 = new Float32Array(4);
    scratchUniformMatrix3 = new Float32Array(9);
    scratchUniformMatrix4 = new Float32Array(16);
    }
*/
// represents WebGLActiveInfo

struct ActiveInfo {
    var name: String = ""
    
    var size: GLsizei = 0
    
    var type: GLenum = 0
}

func setUniform (uniform: Uniform) -> (() -> ()) {

    var location = uniform._location
    switch uniform._activeUniform.type {
    case GLenum(GL_FLOAT):
        return { glUniform1f(location, uniform.value as GLfloat) }
    case GLenum(GL_FLOAT_VEC2):
        return {
            var v = uniform.value as Cartesian2
            glUniform2f(location, GLfloat(v.x), GLfloat(v.y))
        }
    case GLenum(GL_FLOAT_VEC3):
        return {
            var v = uniform.value as Cartesian3
            glUniform3f(location, GLfloat(v.x), GLfloat(v.y), GLfloat(v.z))
        }
    /*case gl.FLOAT_VEC4:
        return function() {
            var v = uniform.value;
            
            if (defined(v.red)) {
                gl.uniform4f(location, v.red, v.green, v.blue, v.alpha);
            } else if (defined(v.x)) {
                gl.uniform4f(location, v.x, v.y, v.z, v.w);
            } else {
                throw new DeveloperError('Invalid vec4 value for uniform "' + uniform._activeUniform.name + '".');
            }
        };
    case gl.SAMPLER_2D:
    case gl.SAMPLER_CUBE:
        return function() {
            gl.activeTexture(gl.TEXTURE0 + uniform.textureUnitIndex);
            gl.bindTexture(uniform.value._target, uniform.value._texture);
        };
    case gl.INT:
    case gl.BOOL:
        return function() {
            gl.uniform1i(location, uniform.value);
        };
    case gl.INT_VEC2:
    case gl.BOOL_VEC2:
        return function() {
            var v = uniform.value;
            gl.uniform2i(location, v.x, v.y);
        };
    case gl.INT_VEC3:
    case gl.BOOL_VEC3:
        return function() {
            var v = uniform.value;
            gl.uniform3i(location, v.x, v.y, v.z);
        };
    case gl.INT_VEC4:
    case gl.BOOL_VEC4:
        return function() {
            var v = uniform.value;
            gl.uniform4i(location, v.x, v.y, v.z, v.w);
        };
    case gl.FLOAT_MAT2:
        return function() {
            gl.uniformMatrix2fv(location, false, Matrix2.toArray(uniform.value, scratchUniformMatrix2));
        };
    case gl.FLOAT_MAT3:
        return function() {
            gl.uniformMatrix3fv(location, false, Matrix3.toArray(uniform.value, scratchUniformMatrix3));
        };
    case gl.FLOAT_MAT4:
        return function() {
            gl.uniformMatrix4fv(location, false, Matrix4.toArray(uniform.value, scratchUniformMatrix4));
        };*/
    default:
        fatalError("Unrecognized uniform type: \(uniform._activeUniform.type) for uniform '\(uniform._activeUniform.name)")
    }
}

class Uniform {
    
    private var _activeUniform: ActiveInfo
    
    var name: String {
        get {
            return _uniformName
        }
    }
    private var _uniformName: String
    
    private var _location: GLint
    
    var value: Any
    
    private var _textureUnitIndex: GLint = 0
    
    private var _set: (uniform: Uniform) -> (() -> ())
    
    var datatype: GLenum {
        get {
            return self._activeUniform.type
        }
    }
    
    private var _setSampler: ((textureUnitIndex: GLint) -> GLint)?

    init (activeUniform: ActiveInfo, uniformName: String, location: GLint, value: Any) {
        
        self.value = value
        _activeUniform = activeUniform
        _uniformName = uniformName
        _location = location
        
        _set = setUniform
        
        if _activeUniform.type == GLenum(GL_SAMPLER_2D) || activeUniform.type == GLenum(GL_SAMPLER_CUBE) {
            _setSampler = { (textureUnitIndex: GLint) -> GLint in
                self._textureUnitIndex = textureUnitIndex
                glUniform1i(self._location, self._textureUnitIndex)
                return textureUnitIndex + 1
            }
        }
    }
    /*
    function setUniformArray(uniformArray) {
    var gl = uniformArray._gl;
    var locations = uniformArray._locations;
    switch (uniformArray._activeUniform.type) {
    case gl.FLOAT:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    gl.uniform1f(locations[i], value[i]);
    }
    };
    case gl.FLOAT_VEC2:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    var v = value[i];
    gl.uniform2f(locations[i], v.x, v.y);
    }
    };
    case gl.FLOAT_VEC3:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    var v = value[i];
    gl.uniform3f(locations[i], v.x, v.y, v.z);
    }
    };
    case gl.FLOAT_VEC4:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    var v = value[i];
    
    if (defined(v.red)) {
    gl.uniform4f(locations[i], v.red, v.green, v.blue, v.alpha);
    } else if (defined(v.x)) {
    gl.uniform4f(locations[i], v.x, v.y, v.z, v.w);
    } else {
    throw new DeveloperError('Invalid vec4 value.');
    }
    }
    };
    case gl.SAMPLER_2D:
    case gl.SAMPLER_CUBE:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    var v = value[i];
    var index = uniformArray.textureUnitIndex + i;
    gl.activeTexture(gl.TEXTURE0 + index);
    gl.bindTexture(v._target, v._texture);
    }
    };
    case gl.INT:
    case gl.BOOL:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    gl.uniform1i(locations[i], value[i]);
    }
    };
    case gl.INT_VEC2:
    case gl.BOOL_VEC2:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    var v = value[i];
    gl.uniform2i(locations[i], v.x, v.y);
    }
    };
    case gl.INT_VEC3:
    case gl.BOOL_VEC3:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    var v = value[i];
    gl.uniform3i(locations[i], v.x, v.y, v.z);
    }
    };
    case gl.INT_VEC4:
    case gl.BOOL_VEC4:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    var v = value[i];
    gl.uniform4i(locations[i], v.x, v.y, v.z, v.w);
    }
    };
    case gl.FLOAT_MAT2:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    gl.uniformMatrix2fv(locations[i], false, Matrix2.toArray(value[i], scratchUniformMatrix2));
    }
    };
    case gl.FLOAT_MAT3:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    gl.uniformMatrix3fv(locations[i], false, Matrix3.toArray(value[i], scratchUniformMatrix3));
    }
    };
    case gl.FLOAT_MAT4:
    return function() {
    var value = uniformArray.value;
    var length = value.length;
    for (var i = 0; i < length; ++i) {
    gl.uniformMatrix4fv(locations[i], false, Matrix4.toArray(value[i], scratchUniformMatrix4));
    }
    };
    default:
    throw new RuntimeError('Unrecognized uniform type: ' + uniformArray._activeUniform.type);
    }
    }

}
class UniformArray {

    /**
    * @private
    */
    var UniformArray = function(gl, activeUniform, uniformName, locations, value) {
    this._gl = gl;
    this._activeUniform = activeUniform;
    this._uniformName = uniformName;
    this.value = value;
    this._locations = locations;
    
    /**
    * @private
    */
    this.textureUnitIndex = undefined;
    
    this._set = setUniformArray(this);
    
    if ((activeUniform.type === gl.SAMPLER_2D) || (activeUniform.type === gl.SAMPLER_CUBE)) {
    this._setSampler = function(textureUnitIndex) {
    this.textureUnitIndex = textureUnitIndex;
    
    var length = locations.length;
    for (var i = 0; i < length; ++i) {
    var index = textureUnitIndex + i;
    gl.uniform1i(locations[i], index);
    }
    
    return textureUnitIndex + length;
    };
    }
    };
    
    defineProperties(UniformArray.prototype, {
    name : {
    get : function() {
    return this._uniformName;
    }
    },
    datatype : {
    get : function() {
    return this._activeUniform.type;
    }
    }
    });
    
    function setSamplerUniforms(gl, program, samplerUniforms) {
    gl.useProgram(program);
    
    var textureUnitIndex = 0;
    var length = samplerUniforms.length;
    for (var i = 0; i < length; ++i) {
    textureUnitIndex = samplerUniforms[i]._setSampler(textureUnitIndex);
    }
    
    gl.useProgram(null);
    
    return textureUnitIndex;
    }*/

    
    /**
    * @private
    */

}
/*struct VertexAttribute {
    let name: String
    let type: Int
    let index: Int
}*/

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

    //var _activeUniform = ActiveInfo()

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

    var vertexAttributes: [VertexAttributes] {
        get {
            initialize()
            return _vertexAttributes
        }
    }
    private var _vertexAttributes = [VertexAttributes]()


    var uniformsByName: [String: Uniform] {
        get {
            initialize()
            return _uniformsByName!
        }
    }
    private var _uniformsByName = [String: Uniform]?()
    
    var uniforms: [Uniform]? = nil

    var automaticUniforms = [Uniform]()

    var manualUniforms: [Uniform] {
        get {
            initialize()
            return _manualUniforms!
        }
    }
    private var _manualUniforms = [Uniform]?()
    
    var maximumTextureUnitIndex: Int = 0
    
    var count: Int = 0
    
    let _id: Int
    
    init(logShaderCompilation: Bool = false, vertexShaderSource: String, fragmentShaderSource: String, attributeLocations: [String: Int]? = nil, id: Int) {
        
        _logShaderCompilation = logShaderCompilation
        _attributeLocations = attributeLocations
        _vertexShaderSource = vertexShaderSource
        _fragmentShaderSource = fragmentShaderSource
        _id = id
        count = 0
        
        
        //_uniformsByName = nil
        //_uniforms = nil
        //_automaticUniforms = nil
        //_manualUniforms = nil
    }
    
    func extractShaderVersion(source: String) -> (version: String, source: String) {
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
            let commentRegex = Regex("/\\*\\*[\\s\\S]*?\\*/")
            var commentBlocks = commentRegex.matches(glslSource)
            if commentBlocks.count > 0 {
                // FIXME: shader comments
                for var i = 0; i < commentBlocks.count; ++i {
                    
                    let commentBlock = commentBlocks[i] as NSTextCheckingResult
                    let matchRange = Range(start: commentBlock.range.location, end: commentBlock.range.location + commentBlock.range.length)
                    let comment = glslSource[matchRange]
                    let lineRegex = Regex("\\n")
                    let numberOfLines = lineRegex.matches(comment).count
                    
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
        let czmRegex = Regex("\\bczm_[a-zA-Z0-9_]*")
        var czmMatchRanges = czmRegex.matches(currentNode.glslSource) as [NSTextCheckingResult]
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
        var builtinsSource = reverse(dependencyNodes).reduce("", { $0 + $1.glslSource + "\n" })
        /*var builtinsSource = ""
        for var i = dependencyNodes.count - 1; i >= 0; --i {
            builtinsSource += dependencyNodes[i].glslSource + "\n"
        }*/
        return builtinsSource.replace(root.glslSource, "")
    }

    func getFragmentShaderPrecision() -> String {
        return "#ifdef GL_FRAGMENT_PRECISION_HIGH \n" +
            "  precision highp float; \n" +
            "#else \n" +
            "  precision mediump float; \n" +
        "#endif \n\n"
    }

    func createAndLinkProgram(logShaderCompilation: Bool, vertexShaderSource: String, fragmentShaderSource: String, attributeLocations: [String: Int]?) -> GLuint {

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
                //println(fragmentShaderSource)
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
    
/*
function findVertexAttributes(gl, program, numberOfAttributes) {
    var attributes = {};
    for (var i = 0; i < numberOfAttributes; ++i) {
        var attr = gl.getActiveAttrib(program, i);
        var location = gl.getAttribLocation(program, attr.name);
        
        attributes[attr.name] = {
            name : attr.name,
            type : attr.type,
            index : location
        };
    }
    
    return attributes;
}
*/
    func findUniforms() -> (uniformsByName: [Uniform], uniforms : [Uniform], samplerUniforms : [Uniform]) {
        
        var uniformsByName = [Uniform]()
        var uniforms = [Uniform]()
        var samplerUniforms = [Uniform]()
        
        var numberOfUniforms: GLint = 0
        glGetProgramiv(_program!, GLenum(GL_ACTIVE_UNIFORMS), &numberOfUniforms)
        
        var maxUniformLength: GLint = 0
        glGetProgramiv(_program!, GLenum(GL_ACTIVE_UNIFORM_MAX_LENGTH), &maxUniformLength)
        
        for var i = 0; i < Int(numberOfUniforms); ++i {
            var uniformLength: GLsizei = 0
            var uniformNameBuffer = [GLchar](count: Int(uniformLength + 1), repeatedValue: 0)
            var activeUniform = ActiveInfo()
            glGetActiveUniform(_program!, GLuint(i), GLsizei(maxUniformLength), &uniformLength, &activeUniform.size, &activeUniform.type, &uniformNameBuffer)
            activeUniform.name = String.fromCString(UnsafePointer<CChar>(uniformNameBuffer))!

            var suffix = "[0]"
            
            var uniformName = activeUniform.name
            if uniformName.hasSuffix(suffix) {
                let suffixRange = Range(
                    start: advance(activeUniform.name.endIndex, -3),
                    end: activeUniform.name.endIndex)
                activeUniform.name.removeRange(suffixRange)
            }
            
                /*if (activeUniform.name.indexOf('[') < 0) {
                // Single uniform
                var location = gl.getUniformLocation(program, uniformName);
                var uniformValue = gl.getUniform(program, location);
                var uniform = new Uniform(gl, activeUniform, uniformName, location, uniformValue);
                
                uniformsByName[uniformName] = uniform;
                uniforms.push(uniform);
                
                if (uniform._setSampler) {
                samplerUniforms.push(uniform);
                }
                } else {
                // Uniform array
                
                var uniformArray;
                var locations;
                var value;
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
                }
            }*/
        }
        
        return (
            uniformsByName : uniformsByName,
            uniforms : uniforms,
            samplerUniforms : samplerUniforms
        )
    }
/*
function partitionUniforms(uniforms) {
    var automaticUniforms = [];
    var manualUniforms = {};
    
    for ( var uniform in uniforms) {
        if (uniforms.hasOwnProperty(uniform)) {
            var automaticUniform = AutomaticUniforms[uniform];
            if (automaticUniform) {
                automaticUniforms.push({
                    uniform : uniforms[uniform],
                    automaticUniform : automaticUniform
                    });
            } else {
                manualUniforms[uniform] = uniforms[uniform];
            }
        }
    }
    
    return {
        automaticUniforms : automaticUniforms,
        manualUniforms : manualUniforms
    };
}
*/
func initialize() {

    if _program != nil {
        return
    }
    
    _program = createAndLinkProgram(_logShaderCompilation, vertexShaderSource: _vertexShaderSource, fragmentShaderSource: _fragmentShaderSource, attributeLocations: _attributeLocations)

    glGetProgramiv(_program!, GLenum(GL_ACTIVE_ATTRIBUTES), &_numberOfVertexAttributes)
    
    var uniforms = findUniforms()
    /*var partitionedUniforms = partitionUniforms(uniforms.uniformsByName);
    
    shader._program = program;
    shader._numberOfVertexAttributes = numberOfVertexAttributes;
    shader._vertexAttributes = findVertexAttributes(gl, program, numberOfVertexAttributes);
    shader._uniformsByName = uniforms.uniformsByName;
    shader._uniforms = uniforms.uniforms;
    shader._automaticUniforms = partitionedUniforms.automaticUniforms;
    shader._manualUniforms = partitionedUniforms.manualUniforms;
    
    shader.maximumTextureUnitIndex = setSamplerUniforms(gl, program, uniforms.samplerUniforms);*/
}

func bind () {
    initialize()
    glUseProgram(_program!)
}
/*
ShaderProgram.prototype._setUniforms = function(uniformMap, uniformState, validate) {
    // TODO: Performance
    
    var len;
    var i;
    
    var uniforms = this._uniforms;
    var manualUniforms = this._manualUniforms;
    var automaticUniforms = this._automaticUniforms;
    
    if (uniformMap) {
        for ( var uniform in manualUniforms) {
            if (manualUniforms.hasOwnProperty(uniform)) {
                manualUniforms[uniform].value = uniformMap[uniform]();
            }
        }
    }
    
    len = automaticUniforms.length;
    for (i = 0; i < len; ++i) {
        automaticUniforms[i].uniform.value = automaticUniforms[i].automaticUniform.getValue(uniformState);
    }
    
    ///////////////////////////////////////////////////////////////////
    
    len = uniforms.length;
    for (i = 0; i < len; ++i) {
        uniforms[i]._set();
    }
    
    if (validate) {
        var gl = this._gl;
        var program = this._program;
        
        gl.validateProgram(program);
        if (!gl.getProgramParameter(program, gl.VALIDATE_STATUS)) {
            throw new DeveloperError('Program validation failed.  Link log: ' + gl.getProgramInfoLog(program));
        }
    }
};*/
/*
ShaderProgram.prototype.isDestroyed = function() {
    return false;
};
*/
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

extension String {
    
    func indexOf(findStr:String, startIndex: String.Index? = nil) -> String.Index? {
        return self.rangeOfString(findStr, options: nil, range: nil, locale: nil)?.startIndex
        /*var startInd = startIndex ?? self.startIndex
        // check first that the first character of search string exists
        if contains(self, first(findStr)!) {
            // if so set this as the place to start searching
            startInd = find(self,first(findStr)!)!
        }
        else {
            // if not return empty array
            return nil
        }
        var i = distance(self.startIndex, startInd)
        while i<=countElements(self)-countElements(findStr) {
            if self[advance(self.startIndex, i)..<advance(self.startIndex, i+countElements(findStr))] == findStr {
                return advance(self.startIndex, i)
            }
            i++
        }
        return nil*/
    }
} // try further optimisation by jumping to next index of first search character after every find

