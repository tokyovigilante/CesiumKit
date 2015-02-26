//
//  Uniform.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/12/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

enum UniformValue {
    case FloatVec1(Float)
    case FloatVec2(Cartesian2)
    case FloatVec3(Cartesian3)
    case FloatVec4(Cartesian4)
    case Sampler2D(Texture)
    /*    case gl.SAMPLER_2D:
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
    */
    case FloatMatrix3(Matrix3)
    case FloatMatrix4(Matrix4)
}

/*class Uniform {

private var _activeUniform: ActiveUniformInfo

var name: String {
get {
return _uniformName
}
}
private var _uniformName: String

private var _locations: [GLint]

var values: [UniformValue]

private var _textureUnitIndex: GLint = 0

var datatype: GLenum {
get {
return self._activeUniform.type
}
}

var setSampler: ((textureUnitIndex: GLint) -> GLint)?

var hasSetSampler: Bool {
get {
return setSampler != nil
}
}

init (activeUniform: ActiveUniformInfo, uniformName: String, location: GLint, value: UniformValue) {

self.value = value
_activeUniform = activeUniform
_uniformName = uniformName
_location = location

if _activeUniform.type == GLenum(GL_SAMPLER_2D) || activeUniform.type == GLenum(GL_SAMPLER_CUBE) {
setSampler = { (textureUnitIndex: GLint) -> GLint in
self._textureUnitIndex = textureUnitIndex
glUniform1i(self._location, self._textureUnitIndex)
return textureUnitIndex + 1
}
}
}

func set() {
switch self.value {
case .FloatVec1(let value):
glUniform1f(_location, GLfloat(value))
case .FloatVec2(let value):
glUniform2f(_location, GLfloat(value.x), GLfloat(value.y))
case .FloatVec3(let value):
glUniform3f(_location, GLfloat(value.x), GLfloat(value.y), GLfloat(value.z))
case .FloatVec4(let value):
glUniform4f(_location, GLfloat(value.x), GLfloat(value.y), GLfloat(value.z), GLfloat(value.w))
/*
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
*/
case .FloatMatrix3(let value):
glUniformMatrix3fv(_location, 1, GLboolean(0), value.toArray())
case .FloatMatrix4(let value):
glUniformMatrix4fv(_location, 1, GLboolean(0), value.toArray())
default:
assertionFailure("Unrecognized uniform type: \(_activeUniform.type) for uniform '\(_activeUniform.name)")
}
}
}*/

class Uniform {
    
    private var _activeUniform: ActiveUniformInfo
    
    var name: String {
        get {
            return _uniformName
        }
    }
    
    private var _uniformName: String
    
    var isSingle: Bool {
        get {
            return _activeUniform.name.indexOf("[") == nil
        }
    }
    
    private var _locations: [GLint]
    
    private var location: GLint {
        return _locations[0]
    }
    
    var values: [UniformValue] {
        get {
            return _values
        }
        set (newValues) {
            _values = newValues
        }
    }
    
    var value: UniformValue {
        get {
            return _values[0]
        }
        set (newValue) {
            _values = [newValue]
        }
        
    }
    
    private var _values = [UniformValue]()
    
    private var _textureUnitIndex: GLint = 0
    
    var datatype: GLenum {
        get {
            return self._activeUniform.type
        }
    }
    
    var setSampler: ((textureUnitIndex: GLint) -> GLint)?
    
    var hasSetSampler: Bool {
        get {
            return setSampler != nil
        }
    }
    
    init (activeUniform: ActiveUniformInfo, uniformName: String, locations: [GLint], values: [UniformValue]) {
        
        _values = values
        _activeUniform = activeUniform
        _uniformName = uniformName
        _locations = locations
        
        if _activeUniform.type == GLenum(GL_SAMPLER_2D) || activeUniform.type == GLenum(GL_SAMPLER_CUBE) {
            setSampler = { (textureUnitIndex: GLint) -> GLint in
                
                self._textureUnitIndex = textureUnitIndex

                let count = self._locations.count
                for i in 0..<count {
                    let index = textureUnitIndex + i
                    glUniform1i(self._locations[i], index)
                }
                return self._textureUnitIndex + count
            }
        }
        
    }
    
    func set() {
        
        for (index, location) in enumerate(_locations) {
            switch (_values[index]) {
            case .FloatVec1(let value):
                glUniform1f(location, GLfloat(value))
            case .FloatVec2(let value):
                glUniform2f(location, GLfloat(value.x), GLfloat(value.y))
            case .FloatVec3(let value):
                glUniform3f(location, GLfloat(value.x), GLfloat(value.y), GLfloat(value.z))
            case .FloatVec4(let value):
                glUniform4f(location, GLfloat(value.x), GLfloat(value.y), GLfloat(value.z), GLfloat(value.w))
            case .Sampler2D(let value):
                let textureIndex = self._textureUnitIndex + index
                glActiveTexture(GLenum(GL_TEXTURE0 + textureIndex))
                glBindTexture(value.textureTarget, value.textureName)
/*                case gl.SAMPLER_CUBE:
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
                }*/
            case .FloatMatrix4(let value):
                glUniformMatrix4fv(location, 1, GLboolean(0), value.toArray())
                
                /*                case gl.FLOAT_MAT4:
                return function() {
                var value = uniformArray.value;
                var length = value.length;
                for (var i = 0; i < length; ++i) {
                gl.uniformMatrix4fv(locations[i], false, Matrix4.toArray(value[i], scratchUniformMatrix4));
                }*/
                
            default:
                assertionFailure("Unrecognized uniform type: \(_activeUniform.type)")
            }
        }
    }
    //switch (_activeUniform.type) {
    
    /*case GL_FLOAT:
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
    };*/
    
    //}
    
    
    
    /*
    
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
    */
    
    
    
    /**
    * @private
    */
    
}