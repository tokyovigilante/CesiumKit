//
//  Buffer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 14/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

class Buffer {
    
    var bufferTarget: GLenum = 0
    
    var sizeInBytes: Int = 0
    
    var usage: BufferUsage = BufferUsage.StaticDraw
    
    var buffer: GLuint = 0
    
    var vertexArrayDestroyable = true


    func copyFromArrayView (arrayView: [Serializable], offsetInBytes: Int = 0) {
        
        /*assert(offsetInBytes + arrayView.byteLength <= _sizeInBytes, "This buffer is not large enough."
        
        var target = this._bufferTarget;
        glBindBuffer(bufferTarget, buffer)
        glBufferSubData(<#target: GLenum#>, <#offset: GLintptr#>, <#size: GLsizeiptr#>, <#data: UnsafePointer<Void>#>)
        gl.bufferSubData(target, offsetInBytes, arrayView);
        gl.bindBuffer(target, null);*/
    }
    
    deinit {
        glDeleteBuffers(1, &buffer)
    }
}
