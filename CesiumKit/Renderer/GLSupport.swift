//
//  GLSupport.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

//helper extensions to pass arguments to GL land
import OpenGLES

extension Array {
    func size () -> Int {
        return self.count * sizeofValue(self[0])
    }
}

extension Int32 {
    func __conversion() -> GLenum {
        return GLenum(self)
    }
    
    func __conversion() -> GLboolean {
        return GLboolean.convertFromIntegerLiteral(UInt8(self))
    }
}

extension Int {
    func __conversion() -> GLenum {
        return GLenum(self)
    }
    
    func __conversion() -> Int32 {
        return Int32(self)
    }
    
    func __conversion() -> GLubyte {
        return GLubyte(self)
    }
    
}