//
//  Buffer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 14/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

class Buffer {
    
    var target: BufferTarget
    
    var sizeInBytes: Int
    
    var usage: BufferUsage
    
    var buffer: GLuint
    
    //var vertexArrayDestroyable = true
    
    init (target: BufferTarget, array: SerializedArray? = nil, sizeInBytes: Int? = nil, usage: BufferUsage = .StaticDraw) {
        assert(array != nil || sizeInBytes  != nil, "typedArrayOrSizeInBytes must be either a typed array or a number")
        
        var bufferSize: Int
        if array != nil {
            bufferSize = array!.sizeInBytes
        } else {
            bufferSize = sizeInBytes!
        }
        assert(bufferSize > 0, "typedArrayOrSizeInBytes must be greater than zero")
        
        var buffer: GLuint = 0
        glGenBuffers(1, &buffer)
        assert(glGetError() == GLenum(GL_NO_ERROR), "GL call failed")
        glBindBuffer(target.toGL(), buffer)
        assert(glGetError() == GLenum(GL_NO_ERROR), "GL call failed")
        var data: UnsafePointer<Void>
        if array != nil {
            data = array!.bytes()
        } else {
            data = nil
        }
        glBufferData(target.toGL(), GLsizeiptr(bufferSize), data, usage.toGL())
        assert(glGetError() == GLenum(GL_NO_ERROR), "GL call failed")
        glBindBuffer(target.toGL(), 0)
        assert(glGetError() == GLenum(GL_NO_ERROR), "GL call failed")

        self.target = target
        self.sizeInBytes = bufferSize
        self.buffer = buffer
        self.usage = usage
    }

    func copyFromArrayView (arrayView: SerializedArray, offsetInBytes: Int = 0) {
        
        assert(offsetInBytes + arrayView.sizeInBytes <= sizeInBytes, "This buffer is not large enough.")
        
        glBindBuffer(target.toGL(), buffer)
        assert(glGetError() == GLenum(GL_NO_ERROR), "GL call failed")
        glBufferSubData(target.toGL(), offsetInBytes, arrayView.sizeInBytes, arrayView.bytes())
        assert(glGetError() == GLenum(GL_NO_ERROR), "GL call failed")
        glBindBuffer(target.toGL(), 0)
        assert(glGetError() == GLenum(GL_NO_ERROR), "GL call failed")
    }
    
    deinit {
        glDeleteBuffers(1, &buffer)
        assert(glGetError() == GLenum(GL_NO_ERROR), "GL call failed")
    }
}
