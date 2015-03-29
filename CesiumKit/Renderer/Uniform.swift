//
//  Uniform.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/12/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

enum UniformDataType: GLenum {
    
    case FloatVec1 = 5126, // GLenum(GL_FLOAT)
    FloatVec2 = 35664, // GLenum(GL_FLOAT_VEC2)
    FloatVec3 = 35665, // GLenum(GL_FLOAT_VEC3)
    FloatVec4 = 35666, // GLenum(GL_FLOAT_VEC4)
    IntVec1 = 5124, // GLenum(GL_INT)
    IntVec2 = 35667, // GLenum(GL_INT_VEC2)
    IntVec3 = 35668, // GLenum(GL_INT_VEC3)
    IntVec4 = 35669, // GLenum(GL_INT_VEC4)
    BoolVec1 = 35670, // GLenum(GL_BOOL)
    BoolVec2 = 35671, // GLenum(GL_BOOL_VEC2)
    BoolVec3 = 35672, // GLenum(GL_BOOL_VEC3)
    BoolVec4 = 35673, // GLenum(GL_BOOL_VEC4)
    FloatMatrix2 = 35674, // GLenum(GL_FLOAT_MAT2)
    FloatMatrix3 = 35675, // GLenum(GL_FLOAT_MAT3)
    FloatMatrix4 = 35676, // GLenum(GL_FLOAT_MAT4)
    Sampler2D = 35678, // GLenum(GL_SAMPLER_2D)
    SamplerCube = 35680 // GLenum(GL_SAMPLER_CUBE
    
    func declarationString() -> String {
        switch self {
        case .FloatVec1:
            return "float"
        case .FloatVec2:
            return "vec2"
        case .FloatVec3:
            return "vec3"
        case .FloatVec4:
            return "vec4"
        case .IntVec1:
            return "int"
        case .IntVec2:
            return "ivec2"
        case .IntVec3:
            return "ivec3"
        case .IntVec4:
            return "ivec4"
        case .BoolVec1:
            return "bool"
        case .BoolVec2:
            return "bvec2"
        case .BoolVec3:
            return "bvec3"
        case .BoolVec4:
            return "bvec4"
        case .FloatMatrix2:
            return "mat2"
        case .FloatMatrix3:
            return "mat3"
        case .FloatMatrix4:
            return "mat4"
        case .Sampler2D:
            return "sampler2D"
        case .SamplerCube:
            return "samplerCube"
        }
    }
    
}

// represents WebGLActiveInfo
struct ActiveUniformInfo {
    
    let name: String
    
    let size: GLsizei
    
    let type: UniformDataType
    
    static func dataType (rawType: GLenum) -> UniformDataType {
        
        let dataType = UniformDataType(rawValue: rawType)
        assert(dataType != nil, "Invalid raw uniform datatype enum")
        
        return dataType!
    }
}

class Uniform {
    
    let name: String
    
    private let _activeUniform: ActiveUniformInfo
    
    private let _locations: [GLint]
    
    private var location: GLint {
        return _locations[0]
    }
    
    var isSingle: Bool {
        get {
            return _activeUniform.name.indexOf("[") == nil
        }
    }
    
    var datatype: GLenum {
        get {
            return self._activeUniform.type.rawValue
        }
    }
    
    init (activeUniform: ActiveUniformInfo, name: String, locations: [GLint]) {
        
        _activeUniform = activeUniform
        self.name = name
        _locations = locations
        
    }

    func setValues(newValues: [Any]) {
        assertionFailure("Invalid base class")
    }
    
    func set() {
        assertionFailure("Invalid base class")
    }
    
    static func create(#activeUniform: ActiveUniformInfo, name: String, locations: [GLint]) -> Uniform {
        switch activeUniform.type {
            case .FloatVec1:
            return UniformFloatVec1(activeUniform: activeUniform, name: name, locations: locations)
            case .FloatVec2:
            return UniformFloatVec2(activeUniform: activeUniform, name: name, locations: locations)
            case .FloatVec3:
            return UniformFloatVec3(activeUniform: activeUniform, name: name, locations: locations)
            case .FloatVec4:
            return UniformFloatVec4(activeUniform: activeUniform, name: name, locations: locations)
            /*case .IntVec1:
            return UniformIntVec1(activeUniform: activeUniform, name: name, locations: locations)
            case .IntVec2:
            return UniformIntVec2(activeUniform: activeUniform, name: name, locations: locations)
            case .IntVec3:
            return UniformIntVec3(activeUniform: activeUniform, name: name, locations: locations)
            case .IntVec4:
            return UniformIntVec4(activeUniform: activeUniform, name: name, locations: locations)
            case .BoolVec1:
            return UniformBoolVec1(activeUniform: activeUniform, name: name, locations: locations)
            case .BoolVec2:
            return UniformBoolVec2(activeUniform: activeUniform, name: name, locations: locations)
            case .BoolVec3:
            return UniformBoolVec3(activeUniform: activeUniform, name: name, locations: locations)
            case .BoolVec4:
            return UniformBoolVec4(activeUniform: activeUniform, name: name, locations: locations)
            case .FloatMatrix2:
            return UniformFloatMatrix2(activeUniform: activeUniform, name: name, locations: locations)
            case .FloatMatrix3:
            return UniformFloatMatrix3(activeUniform: activeUniform, name: name, locations: locations)*/
            case .FloatMatrix4:
            return UniformFloatMatrix4(activeUniform: activeUniform, name: name, locations: locations)
        case .Sampler2D:
            return UniformSampler(activeUniform: activeUniform, name: name, locations: locations)
            /*case .SamplerCube:
            return UniformSampler(activeUniform: activeUniform, name: name, locations: locations)*/
        default:
            assertionFailure("Unimplemented")
            return UniformFloatVec1(activeUniform: activeUniform, name: name, locations: locations)
        }
    }
    
}

/*
for (index, location) in enumerate(_locations) {
switch _values[index] {
case .FloatVec1(let value):
if _isDirty[index] {
glUniform1f(location, GLfloat(value))
}*/
class UniformFloatVec1: Uniform {
    
    private var _values: [Float]
    
    private var _changed = false
    
    override init(activeUniform: ActiveUniformInfo, name: String, locations: [GLint]) {
        
        _values = [Float]()
        
        super.init(activeUniform: activeUniform, name: name, locations: locations)
    }
    
    override func setValues(newValues: [Any]) {
        var values = newValues.map({ Float($0 as! Double) })
        for i in 0..<_locations.count {
            let value = _values[i]
            if values[i] != _values[i] {
                _values[i] = values[i]
                _changed = true
            }
        }
    }
    
    override func set () {

        if _changed {
            _changed = false
            glUniform1fv(_locations[0], GLsizei(_locations.count), UnsafePointer<GLfloat>(_values))
        }
    }
}


class UniformFloatVec2: Uniform {
    
    private var _values: [Cartesian2]
    
    private var _arrayBuffer: [Float]
    
    override init(activeUniform: ActiveUniformInfo, name: String, locations: [GLint]) {
        
        _arrayBuffer = [Float](count: locations.count * 2, repeatedValue: 0.0)
        _values = [Cartesian2]()
        
        super.init(activeUniform: activeUniform, name: name, locations: locations)
    }
    
    override func setValues(newValues: [Any]) {
        _values = newValues.map({ $0 as! Cartesian2 })
    }
    
    override func set () {
        var changed = false
        
        for i in 0..<_locations.count {
            let cartesian = _values[i]
            if !cartesian.equalsArray(_arrayBuffer, offset: i*2) {
                cartesian.pack(&_arrayBuffer, startingIndex: i*2)
                changed = true
            }
        }
        
        if changed {
            glUniform2fv(_locations[0], GLsizei(_locations.count), UnsafePointer<GLfloat>(_arrayBuffer))
        }
    }
}


class UniformFloatVec3: Uniform {
    
    private var _values: [Cartesian3]
    
    private var _arrayBuffer: [Float]
    
    override init(activeUniform: ActiveUniformInfo, name: String, locations: [GLint]) {
        
        _arrayBuffer = [Float](count: locations.count * 3, repeatedValue: 0.0)
        _values = [Cartesian3]()
        
        super.init(activeUniform: activeUniform, name: name, locations: locations)
    }
    
    override func setValues(newValues: [Any]) {
        _values = newValues.map({ $0 as! Cartesian3 })
    }
    
    override func set () {
        var changed = false
        
        for i in 0..<_locations.count {
            let cartesian = _values[i]
            if !cartesian.equalsArray(_arrayBuffer, offset: i*3) {
                cartesian.pack(&_arrayBuffer, startingIndex: i*3)
                changed = true
            }
        }
        
        if changed {
            glUniform3fv(_locations[0], GLsizei(_locations.count), UnsafePointer<GLfloat>(_arrayBuffer))
        }
    }
    
}

class UniformFloatVec4: Uniform {
    
    private var _values: [Cartesian4]
    
    private var _arrayBuffer: [Float]
    
    override init(activeUniform: ActiveUniformInfo, name: String, locations: [GLint]) {
        
        _arrayBuffer = [Float](count: locations.count * 4, repeatedValue: 0.0)
        _values = [Cartesian4]()
        
        super.init(activeUniform: activeUniform, name: name, locations: locations)
    }
    
    override func setValues(newValues: [Any]) {
        /*_values = [Cartesian4]()
        for newValue in newValues {
            _values.append(newValue as! Cartesian4)
        }*/
        _values = newValues.map({ $0 as! Cartesian4 })
    }
    
    override func set () {
        var changed = false
        
        for i in 0..<_locations.count {
            let cartesian = _values[i]
            if !cartesian.equalsArray(_arrayBuffer, offset: i*4) {
                cartesian.pack(&_arrayBuffer, startingIndex: i*4)
                changed = true
            }
        }
        
        if changed {
            glUniform4fv(_locations[0], GLsizei(_locations.count), UnsafePointer<GLfloat>(_arrayBuffer))
        }
    }
}
/*
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
}*/


class UniformFloatMatrix4: Uniform {
    
    private var _values: [Matrix4]
    
    private var _arrayBuffer: [Float]
    
    override init(activeUniform: ActiveUniformInfo, name: String, locations: [GLint]) {
        
        _arrayBuffer = [Float](count: locations.count * 16, repeatedValue: 0.0)
        _values = [Matrix4]()
        
        super.init(activeUniform: activeUniform, name: name, locations: locations)
    }
    
    override func setValues(newValues: [Any]) {
        _values = newValues.map({ $0 as! Matrix4 })
    }
    
    override func set () {
        var changed = false
        
        for i in 0..<_locations.count {
            let matrix = _values[i]
            if !matrix.equalsArray(_arrayBuffer, offset: i*16) {
                matrix.pack(&_arrayBuffer, startingIndex: i*16)
                changed = true
            }
        }
        
        if changed {
            glUniformMatrix4fv(_locations[0], GLsizei(_locations.count), GLboolean(GL_FALSE), UnsafePointer<GLfloat>(_arrayBuffer))
        }
    }
    
}


class UniformSampler: Uniform {
    
    private var _textureUnitIndex: GLint = 0
    
    private var _values: [Texture]!
    
    override init(activeUniform: ActiveUniformInfo, name: String, locations: [GLint]) {
        super.init(activeUniform: activeUniform, name: name, locations: locations)
    }
    
    override func setValues(newValues: [Any]) {
        _values = newValues.map({ $0 as! Texture })
    }
    
    override func set () {
        
        let textureUnitIndex = GLenum(GL_TEXTURE0) + GLenum(_textureUnitIndex)
        
        for (index, location) in enumerate(_locations) {
            
            glActiveTexture(textureUnitIndex + GLenum(index))
            glBindTexture(_values[index].textureTarget, _values[index].textureName)
        }
    }
    
    func setSampler (textureUnitIndex: GLint) -> GLint {
        
        self._textureUnitIndex = textureUnitIndex
        
        let count = self._locations.count
        for i in 0..<count {
            let index = textureUnitIndex + i
            glUniform1i(self._locations[i], index)
        }
        
        return self._textureUnitIndex + count
    }
    
}
