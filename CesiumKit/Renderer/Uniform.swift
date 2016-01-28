//
//  Uniform.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/12/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import GLSLOptimizer
import simd

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
    SamplerCube = 35680 // GLenum(GL_SAMPLER_CUBE)
    
    var declarationString: String {
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
    
    var elementCount: Int {
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

    var alignment: Int {
        switch self {
        case .FloatVec1:
            return 4
        case .FloatVec2:
            return 8
        case .FloatVec3:
            return 16
        case .FloatVec4:
            return 16
        case .IntVec1:
            return 4
        case .IntVec2:
            return 8
        case .IntVec3:
            return 16
        case .IntVec4:
            return 16
        case .BoolVec1:
            return 1
        case .BoolVec2:
            return 2
        case .BoolVec3:
            return 4
        case .BoolVec4:
            return 4
        case .FloatMatrix2:
            return 8
        case .FloatMatrix3:
            return 16
        case .FloatMatrix4:
            return 16
        default:
            assertionFailure("not valid uniform type")
            return 0
        }
    }
    
    var elementStride: Int {
        switch self {
        case .FloatVec1:
            return strideof(Float)
        case .FloatVec2:
            return strideof(float2)
        case .FloatVec3:
            return strideof(float4)
        case .FloatVec4:
            return strideof(float4)
        case .IntVec1:
            return strideof(Int32)
        case .IntVec2:
            return strideof(int2)
        case .IntVec3:
            return strideof(int4)
        case .IntVec4:
            return strideof(int4)
        case .FloatMatrix2:
            return strideof(float2)
        case .FloatMatrix3:
            return strideof(float4)
        case .FloatMatrix4:
            return strideof(float4)
        default:
            assertionFailure("invalid element")
            return 0
        }
    }
    
}

typealias UniformFunc = (map: UniformMap, buffer: UnsafeMutablePointer<Void>, count: Int) -> ()

typealias AutomaticUniformFunc = (uniformState: UniformState, buffer: UnsafeMutablePointer<Void>) -> ()

struct AutomaticUniform {
    let size: Int
    let datatype: UniformDataType
    let writeToBuffer: AutomaticUniformFunc
    
    func declaration (name: String) -> String {
        var declaration = "uniform \(datatype.declarationString) \(name)"
        
        if size == 1 {
            declaration += ";"
        } else {
            declaration += "[\(size)];"
        }
        
        return declaration
    }
}

enum UniformType {
    case Manual, // u_
    Automatic, // czm_
    Sampler
}

class Uniform {
    
    private let _desc: GLSLShaderVariableDescription
    
    let dataType: UniformDataType

    let type: UniformType

    let elementCount: Int
    
    var offset: Int = -1

    var name: String {
        return _desc.name
    }
    
    var rawSize: Int {
        return Int(_desc.rawSize())
    }
    
    var alignedSize: Int {
        return dataType.elementStride * Int(_desc.matSize > 0 ? _desc.matSize : 1) * Int(_desc.arraySize > 0 ? _desc.arraySize : 1)
    }
    
    var isSingle: Bool {
        return _desc.arraySize == -1
    }

    var basicType: GLSLOptBasicType {
        return self._desc.type
    }
    
    var mapIndex: UniformIndex? = nil
    
    var automaticIndex: AutomaticUniformIndex? = nil
    
    init (desc: GLSLShaderVariableDescription, type: UniformType, dataType: UniformDataType) {
        _desc = desc
        self.type = type
        elementCount = Int(desc.elementCount())
        self.dataType = dataType
    }
    
    static func create(desc desc: GLSLShaderVariableDescription, type: UniformType) -> Uniform {
        
        switch desc.type {
        case .Float:
            let dataType = inferDataTypeFromGLSLDescription(desc)
            return Uniform(desc: desc, type: type, dataType: dataType)
            /*case Int // kGlslTypeInt,
            return UniformFloat(variableDescription: variableDescription)
            case Bool // kGlslTypeBool,
            return UniformBool(variableDescription: variableDescription)*/
        case .Tex2D: // kGlslTypeTex2D,
            return UniformSampler(desc: desc, type: type, dataType: .Sampler2D)
        //case .Tex3D: // kGlslTypeTex3D,
          //  return UniformSampler(desc: desc, type: type, dataType: .Sampler3D)
        case .TexCube: // kGlslTypeTexCube,
            return UniformSampler(desc: desc, type: type, dataType: .SamplerCube)
        default:
            assertionFailure("Unimplemented")
            return Uniform(desc: desc, type: type, dataType: .FloatVec1)
        }
    }
    
    static func inferDataTypeFromGLSLDescription (desc: GLSLShaderVariableDescription) -> UniformDataType {
        
        if desc.matSize == 1 { //vector
            switch desc.vecSize {
            case 1:
                if desc.type == .Float { return .FloatVec1 }
                if desc.type == .Int { return .IntVec1 }
                if desc.type == .Bool { return .BoolVec1 }
            case 2:
                if desc.type == .Float { return .FloatVec2 }
                if desc.type == .Int { return .IntVec2 }
                if desc.type == .Bool { return .BoolVec2 }
            case 3:
                if desc.type == .Float { return .FloatVec3 }
                if desc.type == .Int { return .IntVec3 }
                if desc.type == .Bool { return .BoolVec3 }
            case 4:
                if desc.type == .Float { return .FloatVec4 }
                if desc.type == .Int { return .IntVec4 }
                if desc.type == .Bool { return .BoolVec4 }
            default:
                assertionFailure("unknown uniform type")
            }
        }
        if desc.matSize == 2 { //Matrix2
            switch desc.vecSize {
            case 2:
                if desc.type == .Float { return .FloatMatrix2 }
            default:
                assertionFailure("unknown uniform type")
            }
        }
        if desc.matSize == 3 { // Matrix3
            switch desc.vecSize {
            case 3:
                if desc.type == .Float { return .FloatMatrix3 }
            default:
                assertionFailure("unknown uniform type")
            }
        }
        if desc.matSize == 4 { // Matrix4
            switch desc.vecSize {
            case 4:
                if desc.type == .Float { return .FloatMatrix4 }

            default:
                assertionFailure("unknown uniform type")
            }
        }
        assertionFailure("unknown uniform type")
        return .FloatVec1
        
    }
    
}

typealias UniformIndex = DictionaryIndex<String, UniformFunc>

typealias AutomaticUniformIndex = DictionaryIndex<String, AutomaticUniform>


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
    
    private (set) var textureUnitIndex: Int = 0
        
    func setSampler (textureUnitIndex: Int) {
        self.textureUnitIndex = textureUnitIndex
    }
    
}
