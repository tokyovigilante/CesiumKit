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
    /*
    var scratchUniformMatrix2;
    var scratchUniformMatrix3;
    var scratchUniformMatrix4;
    if (FeatureDetection.supportsTypedArrays()) {
    scratchUniformMatrix2 = new Float32Array(4);
    scratchUniformMatrix3 = new Float32Array(9);
    scratchUniformMatrix4 = new Float32Array(16);
    }
    function setUniform (uniform) {
    var gl = uniform._gl;
    var location = uniform._location;
    switch (uniform._activeUniform.type) {
    case gl.FLOAT:
    return function() {
    gl.uniform1f(location, uniform.value);
    };
    case gl.FLOAT_VEC2:
    return function() {
    var v = uniform.value;
    gl.uniform2f(location, v.x, v.y);
    };
    case gl.FLOAT_VEC3:
    return function() {
    var v = uniform.value;
    gl.uniform3f(location, v.x, v.y, v.z);
    };
    case gl.FLOAT_VEC4:
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
    };
    default:
    throw new RuntimeError('Unrecognized uniform type: ' + uniform._activeUniform.type + ' for uniform "' + uniform._activeUniform.name + '".');
    }
    /**
    * @private
    */
*/*/
class Uniform {
/*
    var activeUniform: 
    var Uniform = function(gl, activeUniform, uniformName, location, value) {
    this.value = value;
    
    this._gl = gl;
    this._activeUniform = activeUniform;
    this._uniformName = uniformName;
    this._location = location;
    
    /**
    * @private
    */
    this.textureUnitIndex = undefined;
    
    this._set = setUniform(this);
    
    if ((activeUniform.type === gl.SAMPLER_2D) || (activeUniform.type === gl.SAMPLER_CUBE)) {
    this._setSampler = function(textureUnitIndex) {
    this.textureUnitIndex = textureUnitIndex;
    gl.uniform1i(location, textureUnitIndex);
    return textureUnitIndex + 1;
    };
    }
    };
    
    defineProperties(Uniform.prototype, {
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
    */
}
class UniformArray {
/*
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

private class DependencyNode {
    
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
    
    let _attributeLocations: [String: Int]
    
    private var _program: GLuint? = nil
    
    var keyword: String {
        get {
            return _vertexShaderSource + _fragmentShaderSource + _attributeLocations.description
        }
    }
    
    //FIXME: Uniform in ShaderProgram
    
    var numberOfVertexAttributes: Int {
        get {
            initialize()
            return _numberOfVertexAttributes
        }
        
    }
    private var _numberOfVertexAttributes: Int = 0

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
    
    var maximumTextureUnitIndex: Int? = nil
    
    var count: Int = 0
    
    let _id: Int
    
    init(logShaderCompilation: Bool = false, vertexShaderSource: String, fragmentShaderSource: String, attributeLocations: [String: Int], id: Int) {
        
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
    
    /*
    /**
    * For ShaderProgram testing
    * @private
    */
    ShaderProgram._czmBuiltinsAndUniforms = {};
    
    // combine automatic uniforms and Cesium built-ins
    for ( var builtinName in CzmBuiltins) {
    if (CzmBuiltins.hasOwnProperty(builtinName)) {
    ShaderProgram._czmBuiltinsAndUniforms[builtinName] = CzmBuiltins[builtinName];
    }
    }
    for ( var uniformName in AutomaticUniforms) {
    if (AutomaticUniforms.hasOwnProperty(uniformName)) {
    var uniform = AutomaticUniforms[uniformName];
    if (typeof uniform.getDeclaration === 'function') {
    ShaderProgram._czmBuiltinsAndUniforms[uniformName] = uniform.getDeclaration(uniformName);
    }
    }
    }
*/
    
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
            // strip doc comments so we don't accidentally try to determine a dependency for something found
            // in a comment
            /*var commentBlocks = glslSource.match(/\/\*\*[\s\S]*?\*\//gm);
            if (defined(commentBlocks) && commentBlocks !== null) {
            for (i = 0; i < commentBlocks.length; ++i) {
            var commentBlock = commentBlocks[i];
            
            // preserve the number of lines in the comment block so the line numbers will be correct when debugging shaders
            var numberOfLines = commentBlock.match(/\n/gm).length;
            var modifiedComment = '';
            for (var lineNumber = 0; lineNumber < numberOfLines; ++lineNumber) {
            if (lineNumber === 0) {
            modifiedComment += '// Comment replaced to prevent problems when determining dependencies on built-in functions\n';
            } else {
            modifiedComment += '//\n';
            }
            }
            
            //glslSource = glslSource.replace(commentBlock, modifiedComment);
            }*/
            
            
            // create new node
            dependencyNode = DependencyNode(name: name, glslSource: glslSource)
            nodes << dependencyNode!
        }

        return dependencyNode!
}
    /*
    function generateDependencies(currentNode, dependencyNodes) {
    if (currentNode.evaluated) {
    return;
    }
    
    currentNode.evaluated = true;
    /*
    // identify all dependencies that are referenced from this glsl source code
    // var czmMatches = currentNode.glslSource.match(/\bczm_[a-zA-Z0-9_]*/g);
    if (defined(czmMatches) && czmMatches !== null) {
    // remove duplicates
    czmMatches = czmMatches.filter(function(elem, pos) {
    return czmMatches.indexOf(elem) === pos;
    });
    
    czmMatches.forEach(function(element, index, array) {
    if (element !== currentNode.name && ShaderProgram._czmBuiltinsAndUniforms.hasOwnProperty(element)) {
    var referencedNode = getDependencyNode(element, ShaderProgram._czmBuiltinsAndUniforms[element], dependencyNodes);
    currentNode.dependsOn.push(referencedNode);
    referencedNode.requiredBy.push(currentNode);
    
    // recursive call to find any dependencies of the new node
    generateDependencies(referencedNode, dependencyNodes);
    }
    });
    }


function sortDependencies(dependencyNodes) {
    var nodesWithoutIncomingEdges = [];
    var allNodes = [];
    
    while (dependencyNodes.length > 0) {
        var node = dependencyNodes.pop();
        allNodes.push(node);
        
        if (node.requiredBy.length === 0) {
            nodesWithoutIncomingEdges.push(node);
        }
    }
    
    while (nodesWithoutIncomingEdges.length > 0) {
        var currentNode = nodesWithoutIncomingEdges.shift();
        
        dependencyNodes.push(currentNode);
        
        for (var i = 0; i < currentNode.dependsOn.length; ++i) {
            // remove the edge from the graph
            var referencedNode = currentNode.dependsOn[i];
            var index = referencedNode.requiredBy.indexOf(currentNode);
            referencedNode.requiredBy.splice(index, 1);
            
            // if referenced node has no more incoming edges, add to list
            if (referencedNode.requiredBy.length === 0) {
                nodesWithoutIncomingEdges.push(referencedNode);
            }
        }
    }
    
    // if there are any nodes left with incoming edges, then there was a circular dependency somewhere in the graph
    var badNodes = [];
    for (var j = 0; j < allNodes.length; ++j) {
        if (allNodes[j].requiredBy.length !== 0) {
            badNodes.push(allNodes[j]);
        }
    }
    if (badNodes.length !== 0) {
        var message = 'A circular dependency was found in the following built-in functions/structs/constants: \n';
        for (j = 0; j < badNodes.length; ++j) {
            message = message + badNodes[j].name + '\n';
        }
        throw new DeveloperError(message);
    }
}
*/
    func getBuiltinsAndAutomaticUniforms(shaderSource: String) -> String {
    // generate a dependency graph for builtin functions
        
    var dependencyNodes = [DependencyNode]()
    var root = getDependencyNode("main", glslSource: shaderSource, nodes: &dependencyNodes)
    /*generateDependencies(root, dependencyNodes)
    sortDependencies(dependencyNodes);
    
    // Concatenate the source code for the function dependencies.
    // Iterate in reverse so that dependent items are declared before they are used.
    var builtinsSource = '';
    for (var i = dependencyNodes.length - 1; i >= 0; --i) {
        builtinsSource = builtinsSource + dependencyNodes[i].glslSource + '\n';
    }
    */
    //return builtinsSource.replace(root.glslSource, "")
        return shaderSource
    }
/*
function getFragmentShaderPrecision() {
    return '#ifdef GL_FRAGMENT_PRECISION_HIGH \n' +
    '  precision highp float; \n' +
    '#else \n' +
    '  precision mediump float; \n' +
    '#endif \n\n';
}
*/
    func createAndLinkProgram(logShaderCompilation: Bool, vertexShaderSource: String, fragmentShaderSource: String, attributeLocations: [String: Int]) -> GLuint {

        let vsSourceVersioned = extractShaderVersion(vertexShaderSource)
        let fsSourceVersioned = extractShaderVersion(fragmentShaderSource)
        
        var vsSource = vsSourceVersioned.version +
        getBuiltinsAndAutomaticUniforms(vsSourceVersioned.source) +
        "\n#line 0\n" +
        vsSourceVersioned.source
/*        var fsSource =
        fsSourceVersioned.version +
        getFragmentShaderPrecision() +
        getBuiltinsAndAutomaticUniforms(fsSourceVersioned.source) +
        '\n#line 0\n' +
        fsSourceVersioned.source;
        var log;*/
        
        var vertexShader: GLuint = glCreateShader(GLenum(GL_VERTEX_SHADER))
        var vertexShaderUTF8 = UnsafePointer<GLchar>((vsSource as NSString).UTF8String)
        var vertexShaderLength = GLint(vsSource.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        var shaderCount: GLsizei = 1
        glShaderSource(vertexShader, shaderCount, &vertexShaderUTF8, &vertexShaderLength)
        glCompileShader(vertexShader)
        
        var status: GLint = 0
        glGetShaderiv(vertexShader, GLenum(GL_COMPILE_STATUS), &status)
        
        if (status == GL_FALSE)
        {
            var infoLogLength: GLint = 0
            glGetShaderiv(vertexShader, GLenum(GL_INFO_LOG_LENGTH), &infoLogLength)
            var strInfoLog = [GLchar](count: Int(infoLogLength + 1), repeatedValue: 0)
            var actualLength: GLsizei = 0
            glGetShaderInfoLog(vertexShader, infoLogLength, &actualLength, &strInfoLog)
            let compileError = String.fromCString(UnsafePointer<CChar>(strInfoLog))
            println(compileError)

        }
        
        /*println(gl
        var fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
        gl.shaderSource(fragmentShader, fsSource);
        gl.compileShader(fragmentShader);*/
        
        let program = glCreateProgram()
        /*gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);
        
        gl.deleteShader(vertexShader);
        gl.deleteShader(fragmentShader);
        
        if (defined(attributeLocations)) {
        for ( var attribute in attributeLocations) {
        if (attributeLocations.hasOwnProperty(attribute)) {
        gl.bindAttribLocation(program, attributeLocations[attribute], attribute);
        }
        }
        }
        
        gl.linkProgram(program);
        
        if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
        // For performance, only check compile errors if there is a linker error.
        if (!gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)) {
        log = gl.getShaderInfoLog(fragmentShader);
        gl.deleteProgram(program);
        console.error('[GL] Fragment shader compile log: ' + log);
        throw new RuntimeError('Fragment shader failed to compile.  Compile log: ' + log);
        }
        
        if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) {
        log = gl.getShaderInfoLog(vertexShader);
        gl.deleteProgram(program);
        console.error('[GL] Vertex shader compile log: ' + log);
        throw new RuntimeError('Vertex shader failed to compile.  Compile log: ' + log);
        }
        
        log = gl.getProgramInfoLog(program);
        gl.deleteProgram(program);
        console.error('[GL] Shader program link log: ' + log);
        throw new RuntimeError('Program failed to link.  Link log: ' + log);
        }
        
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
        return program;
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

function findUniforms(gl, program) {
    var uniformsByName = {};
    var uniforms = [];
    var samplerUniforms = [];
    
    var numberOfUniforms = gl.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
    
    for (var i = 0; i < numberOfUniforms; ++i) {
        var activeUniform = gl.getActiveUniform(program, i);
        var suffix = '[0]';
        var uniformName = activeUniform.name.indexOf(suffix, activeUniform.name.length - suffix.length) !== -1 ? activeUniform.name.slice(0, activeUniform.name.length - 3) : activeUniform.name;
        
        // Ignore GLSL built-in uniforms returned in Firefox.
        if (uniformName.indexOf('gl_') !== 0) {
            if (activeUniform.name.indexOf('[') < 0) {
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
}
}

return {
    uniformsByName : uniformsByName,
    uniforms : uniforms,
    samplerUniforms : samplerUniforms
};
}

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
    /*var numberOfVertexAttributes = gl.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
    var uniforms = findUniforms(gl, program);
    var partitionedUniforms = partitionUniforms(uniforms.uniformsByName);
    
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
        var startInd = startIndex ?? self.startIndex
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
        return nil
    }
} // try further optimisation by jumping to next index of first search character after every find

