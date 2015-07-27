//
//  Uniform.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/12/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import GLSLOptimizer

enum UniformDataType: UInt {
    
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
    
    func elementCount () -> Int {
        switch self {
        case .FloatVec1:
            return 1
        case .FloatVec2:
            return 2
        case .FloatVec3:
            return 3
        case .FloatVec4:
            return 4
        case .IntVec1:
            return 1
        case .IntVec2:
            return 2
        case .IntVec3:
            return 3
        case .IntVec4:
            return 4
        case .BoolVec1:
            return 1
        case .BoolVec2:
            return 2
        case .BoolVec3:
            return 3
        case .BoolVec4:
            return 4
        case .FloatMatrix2:
            return 4
        case .FloatMatrix3:
            return 9
        case .FloatMatrix4:
            return 16
        case .Sampler2D:
            return 1
        case .SamplerCube:
            return 1
        }
    }
}

enum UniformType {
    case Manual, // u_
    Automatic, // czm_
    Sampler
}

class Uniform {
    
    private let _desc: GLSLShaderVariableDescription

    var type: UniformType

    let elementCount: Int

    var name: String {
        return _desc.name
    }
    
    var location: Int {
        return Int(_desc.location)
    }
    
    var rawSize: Int {
        return Int(_desc.rawSize())
    }
    
    var isSingle: Bool {
        return _desc.arraySize == -1
    }
    
    var datatype: GLSLOptBasicType {
        return self._desc.type
    }
    
    init (desc: GLSLShaderVariableDescription, type: UniformType) {
        _desc = desc
        self.type = type
        elementCount = Int(desc.elementCount())
    }
    
    func setValues(newValues: [Any]) {
        assertionFailure("Invalid base class")
    }
    
    func set(buffer: Buffer) {
        assertionFailure("Invalid base class")
    }
    
    static func create(desc desc: GLSLShaderVariableDescription, type: UniformType) -> Uniform {
        switch desc.type {
        case .Float:
            return UniformFloat(desc: desc, type: type)
            /*case Int // kGlslTypeInt,
            return UniformFloat(variableDescription: variableDescription)
            case Bool // kGlslTypeBool,
            return UniformBool(variableDescription: variableDescription)*/
        case .Tex2D: // kGlslTypeTex2D,
            return UniformSampler(desc: desc, type: type)
        case .Tex3D: // kGlslTypeTex3D,
            return UniformSampler(desc: desc, type: type)
        case .TexCube: // kGlslTypeTexCube,
            return UniformSampler(desc: desc, type: type)
        default:
            assertionFailure("Unimplemented")
            return UniformFloat(desc: desc, type: type)
        }
    }
    
}

class UniformFloat: Uniform {
    
    private var _values: [Float]
    private var _newValues: [Float]
    
    func setFloatValues(newValues: [Float]) {
        /*assert(newValues.count >= _locations.count * _activeUniform.type.elementCount(), "wrong count")
        memcpy(&_newValues, newValues, _locations.count * _activeUniform.type.elementCount() * sizeof(Float))*/
        //_newValues = newValues
    }
    
    override func set(buffer: Buffer) {
        memcpy(buffer.data+Int(_desc.location), _values, Int(_desc.rawSize()))
    }
    
    func isChanged () -> Bool {
        /*    if (memcmp(&_values, &_newValues, _locations.count * _activeUniform.type.elementCount() * sizeof(Float))) != 0 {
        memcpy(&_values, _newValues, _locations.count * _activeUniform.type.elementCount() * sizeof(Float))
        return true
        }*/
        return false
    }
    
    override init(desc: GLSLShaderVariableDescription, type: UniformType) {
        
        _values = [Float](count: Int(desc.elementCount()), repeatedValue: 0.0)
        _newValues = _values
        
        super.init(desc: desc, type: type)
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
/*
class UniformFloatMatrix4: FloatUniform {

override init(activeUniform: ActiveUniformInfo, name: String, locations: [GLint]) {
super.init(activeUniform: activeUniform, name: name, locations: locations)
}

override func set () {
if isChanged() {
glUniformMatrix4fv(_locations[0], GLsizei(_locations.count), GLboolean(GL_FALSE), UnsafePointer<GLfloat>(_values))
}
}

}*/


class UniformSampler: Uniform {
    
    private var _textureUnitIndex: Int = 0
    
    private var _values: [Texture]!
    
    override func setValues(newValues: [Any]) {
        _values = newValues.map({ $0 as! Texture })
    }
    
    override func set(buffer: Buffer) {
        
        //let textureUnitIndex = GLenum(GL_TEXTURE0) + GLenum(_textureUnitIndex)
        
        /*for (index, location) in enumerate(_locations) {
        
        glActiveTexture(textureUnitIndex + GLenum(index))
        glBindTexture(_values[index].textureTarget, _values[index].textureName)
        }*/
    }
    
    func setSampler (textureUnitIndex: Int) -> Int {
        
        self._textureUnitIndex = textureUnitIndex
        
        /*let count = self._locations.count
        for i in 0..<count {
        let index = textureUnitIndex + i
        glUniform1i(self._locations[i], index)
        }
        */
        return self._textureUnitIndex// + count
    }
    
}
