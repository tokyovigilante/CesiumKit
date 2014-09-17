//
//  BufferTarget.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 17/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

enum BufferTarget {
    case ArrayBuffer
    case ElementArrayBuffer
    
    func toGL() -> GLenum {
        switch self {
        case .ArrayBuffer:
            return GLenum(GL_ARRAY_BUFFER)
        case .ElementArrayBuffer:
            return GLenum(GL_ELEMENT_ARRAY_BUFFER)
        }
    }
}
