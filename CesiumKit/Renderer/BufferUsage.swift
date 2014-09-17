//
//  BufferUsage.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 14/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

enum BufferUsage {
    case StreamDraw,
    StaticDraw,
    DynamicDraw
    
    func toGL() -> GLenum {
        switch self {
        case .StreamDraw:
            return GL_STREAM_DRAW
        case .StaticDraw:
            return GL_STATIC_DRAW
        case .DynamicDraw:
            return GL_DYNAMIC_DRAW
        }
    }
    
}