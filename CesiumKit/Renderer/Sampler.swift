//
//  Sampler.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

class Sampler {
    var wrapS = TextureWrap.Edge
    var wrapT = TextureWrap.Edge
    var minificationFilter = TextureMinificationFilter.Linear
    var magnificationFilter = TextureMagnificationFilter.Linear
    var maximumAnisotropy: GLint = 1
}

enum TextureWrap {
    case Edge, Repeat, MirroredRepeat
    
    func toGL() -> GLint {
        switch self {
        case .Edge:
            return GLint(GL_CLAMP_TO_EDGE)
        case .Repeat:
            return GLint(GL_REPEAT)
        case .MirroredRepeat:
            return GLint(GL_MIRRORED_REPEAT)
        }
    }
}

enum TextureMagnificationFilter {
    case Nearest, Linear
    
    func toGL() -> GLint {
        switch self {
        case .Nearest:
            return GLint(GL_NEAREST)
        case .Linear:
            return GLint(GL_LINEAR)
        }
    }
}

enum TextureMinificationFilter {
    case Nearest, Linear, NearestMipmapNearest, LinearMipmapNearest, NearestMipmapLinear, LinearMipmapLinear
    
    func toGL() -> GLint {
        switch self {
        case .Nearest:
            return GLint(GL_NEAREST)
        case .Linear:
            return GLint(GL_LINEAR)
        case .NearestMipmapNearest:
            return GLint(GL_NEAREST_MIPMAP_NEAREST)
        case .LinearMipmapLinear:
            return GLint(GL_LINEAR_MIPMAP_LINEAR)
        case .NearestMipmapLinear:
            return GLint(GL_NEAREST_MIPMAP_LINEAR)
        case .LinearMipmapNearest:
            return GLint(GL_LINEAR_MIPMAP_NEAREST)
        }
    }
}

enum MipmapHint {
    case DontCare, Fastest, Nicest
    
    func toGL() -> GLenum {
        switch self {
        case .DontCare:
            return GLenum(GL_DONT_CARE)
        case .Fastest:
            return GLenum(GL_FASTEST)
        case .Nicest:
            return GLenum(GL_NICEST)
        }
    }
}