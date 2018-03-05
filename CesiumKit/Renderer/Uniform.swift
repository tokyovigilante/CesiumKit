//
//  Uniform.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/12/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import GLSLOptimizer
import Accelerate
import simd

public enum UniformDataType: UInt {

    case floatVec1 = 5126, // GLenum(GL_FLOAT)
    floatVec2 = 35664, // GLenum(GL_FLOAT_VEC2)
    floatVec3 = 35665, // GLenum(GL_FLOAT_VEC3)
    floatVec4 = 35666, // GLenum(GL_FLOAT_VEC4)
    intVec1 = 5124, // GLenum(GL_INT)
    intVec2 = 35667, // GLenum(GL_INT_VEC2)
    intVec3 = 35668, // GLenum(GL_INT_VEC3)
    intVec4 = 35669, // GLenum(GL_INT_VEC4)
    boolVec1 = 35670, // GLenum(GL_BOOL)
    boolVec2 = 35671, // GLenum(GL_BOOL_VEC2)
    boolVec3 = 35672, // GLenum(GL_BOOL_VEC3)
    boolVec4 = 35673, // GLenum(GL_BOOL_VEC4)
    floatMatrix2 = 35674, // GLenum(GL_FLOAT_MAT2)
    floatMatrix3 = 35675, // GLenum(GL_FLOAT_MAT3)
    floatMatrix4 = 35676, // GLenum(GL_FLOAT_MAT4)
    sampler2D = 35678, // GLenum(GL_SAMPLER_2D)
    samplerCube = 35680 // GLenum(GL_SAMPLER_CUBE)

    var declarationString: String {
        switch self {
        case .floatVec1:
            return "float"
        case .floatVec2:
            return "vec2"
        case .floatVec3:
            return "vec3"
        case .floatVec4:
            return "vec4"
        case .intVec1:
            return "int"
        case .intVec2:
            return "ivec2"
        case .intVec3:
            return "ivec3"
        case .intVec4:
            return "ivec4"
        case .boolVec1:
            return "bool"
        case .boolVec2:
            return "bvec2"
        case .boolVec3:
            return "bvec3"
        case .boolVec4:
            return "bvec4"
        case .floatMatrix2:
            return "mat2"
        case .floatMatrix3:
            return "mat3"
        case .floatMatrix4:
            return "mat4"
        case .sampler2D:
            return "sampler2D"
        case .samplerCube:
            return "samplerCube"
        }
    }

    var metalDeclaration: String {
        switch self {
        case .floatVec1:
            return "float"
        case .floatVec2:
            return "float2"
        case .floatVec3:
            return "float3"
        case .floatVec4:
            return "float4"
        /*case .IntVec1:
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
            return "bvec4"*/
        case .floatMatrix2:
            return "float2x2"
        case .floatMatrix3:
            return "float3x3"
        case .floatMatrix4:
            return "float4x4"
        case .sampler2D:
            return "sampler"
        default:
            assertionFailure("unimplemented")
            return ""
        }
    }

    var elementCount: Int {
        switch self {
        case .floatVec1:
            return 1
        case .floatVec2:
            return 2
        case .floatVec3:
            return 3
        case .floatVec4:
            return 4
        case .intVec1:
            return 1
        case .intVec2:
            return 2
        case .intVec3:
            return 3
        case .intVec4:
            return 4
        case .boolVec1:
            return 1
        case .boolVec2:
            return 2
        case .boolVec3:
            return 3
        case .boolVec4:
            return 4
        case .floatMatrix2:
            return 4
        case .floatMatrix3:
            return 9
        case .floatMatrix4:
            return 16
        case .sampler2D:
            return 1
        case .samplerCube:
            return 1
        }
    }

    var alignment: Int {
        switch self {
        case .floatVec1:
            return 4
        case .floatVec2:
            return 8
        case .floatVec3:
            return 16
        case .floatVec4:
            return 16
        case .intVec1:
            return 4
        case .intVec2:
            return 8
        case .intVec3:
            return 16
        case .intVec4:
            return 16
        case .boolVec1:
            return 1
        case .boolVec2:
            return 2
        case .boolVec3:
            return 4
        case .boolVec4:
            return 4
        case .floatMatrix2:
            return 8
        case .floatMatrix3:
            return 16
        case .floatMatrix4:
            return 16
        default:
            assertionFailure("not valid uniform type")
            return 0
        }
    }

    var elementStride: Int {
        switch self {
        case .floatVec1:
            return MemoryLayout<Float>.stride
        case .floatVec2:
            return MemoryLayout<float2>.stride
        case .floatVec3:
            return MemoryLayout<float4>.stride
        case .floatVec4:
            return MemoryLayout<float4>.stride
        case .intVec1:
            return MemoryLayout<Int32>.stride
        case .intVec2:
            return MemoryLayout<int2>.stride
        case .intVec3:
            return MemoryLayout<int4>.stride
        case .intVec4:
            return MemoryLayout<int4>.stride
        case .floatMatrix2:
            return MemoryLayout<float2>.stride
        case .floatMatrix3:
            return MemoryLayout<float4>.stride
        case .floatMatrix4:
            return MemoryLayout<float4>.stride
        default:
            assertionFailure("invalid element")
            return 0
        }
    }

}

typealias UniformFunc = (_ map: LegacyUniformMap, _ buffer: Buffer, _ offset: Int) -> ()

struct AutomaticUniform {
    let size: Int
    let datatype: UniformDataType

    func declaration (_ name: String) -> String {
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
    case automatic, // czm_a
    frustum, // czm_f
    manual, // u_
    sampler
}

open class Uniform {

    fileprivate let _desc: GLSLShaderVariableDescription

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

    init (desc: GLSLShaderVariableDescription, type: UniformType, dataType: UniformDataType) {
        _desc = desc
        self.type = type
        elementCount = Int(desc.elementCount())
        self.dataType = dataType
    }

    static func create(desc: GLSLShaderVariableDescription, type: UniformType) -> Uniform {

        switch desc.type {
        case .float:
            let dataType = inferDataTypeFromGLSLDescription(desc)
            return Uniform(desc: desc, type: type, dataType: dataType)
            /*case Int // kGlslTypeInt,
            return UniformFloat(variableDescription: variableDescription)
            case Bool // kGlslTypeBool,
            return UniformBool(variableDescription: variableDescription)*/
        case .tex2D: // kGlslTypeTex2D,
            return UniformSampler(desc: desc, type: type, dataType: .sampler2D)
        //case .Tex3D: // kGlslTypeTex3D,
          //  return UniformSampler(desc: desc, type: type, dataType: .Sampler3D)
        case .texCube: // kGlslTypeTexCube,
            return UniformSampler(desc: desc, type: type, dataType: .samplerCube)
        default:
            assertionFailure("Unimplemented")
            return Uniform(desc: desc, type: type, dataType: .floatVec1)
        }
    }

    static func inferDataTypeFromGLSLDescription (_ desc: GLSLShaderVariableDescription) -> UniformDataType {

        if desc.matSize == 1 { //vector
            switch desc.vecSize {
            case 1:
                if desc.type == .float { return .floatVec1 }
                if desc.type == .int { return .intVec1 }
                if desc.type == .bool { return .boolVec1 }
            case 2:
                if desc.type == .float { return .floatVec2 }
                if desc.type == .int { return .intVec2 }
                if desc.type == .bool { return .boolVec2 }
            case 3:
                if desc.type == .float { return .floatVec3 }
                if desc.type == .int { return .intVec3 }
                if desc.type == .bool { return .boolVec3 }
            case 4:
                if desc.type == .float { return .floatVec4 }
                if desc.type == .int { return .intVec4 }
                if desc.type == .bool { return .boolVec4 }
            default:
                assertionFailure("unknown uniform type")
            }
        }
        if desc.matSize == 2 { //Matrix2
            switch desc.vecSize {
            case 2:
                if desc.type == .float { return .floatMatrix2 }
            default:
                assertionFailure("unknown uniform type")
            }
        }
        if desc.matSize == 3 { // Matrix3
            switch desc.vecSize {
            case 3:
                if desc.type == .float { return .floatMatrix3 }
            default:
                assertionFailure("unknown uniform type")
            }
        }
        if desc.matSize == 4 { // Matrix4
            switch desc.vecSize {
            case 4:
                if desc.type == .float { return .floatMatrix4 }

            default:
                assertionFailure("unknown uniform type")
            }
        }
        assertionFailure("unknown uniform type")
        return .floatVec1

    }

}

typealias UniformIndex = DictionaryIndex<String, UniformFunc>


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


open class UniformSampler: Uniform {

    fileprivate (set) var textureUnitIndex: Int = 0

    func setSampler (_ textureUnitIndex: Int) {
        self.textureUnitIndex = textureUnitIndex
    }

}
