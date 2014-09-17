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
    
    var vertexArrayDestroyable = true

    init(target: BufferTarget, sizeInBytes: Int, buffer: GLuint, usage: BufferUsage = .StaticDraw) {
        self.target = target
        self.sizeInBytes = sizeInBytes
        self.buffer = buffer
        self.usage = usage
    }

    func copyFromArrayView (arrayView: SerializedArray, offsetInBytes: Int = 0) {
        
        assert(offsetInBytes + arrayView.sizeInBytes <= sizeInBytes, "This buffer is not large enough.")
        
        glBindBuffer(target.toGL(), buffer)
        glBufferSubData(target.toGL(), offsetInBytes, arrayView.sizeInBytes, arrayView.bytes())
        glBindBuffer(target.toGL(), 0)
    }
    
    deinit {
        glDeleteBuffers(1, &buffer)
    }
}
