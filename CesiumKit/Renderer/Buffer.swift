//
//  Buffer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/05/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Metal

class Buffer {
    
    private let _metalBuffer: MTLBuffer
    
    var componentDatatype: ComponentDatatype
    
    var data: UnsafeMutablePointer<Void> {
        return _metalBuffer.contents()
    }
    
    var length: Int {
        return _metalBuffer.length
    }
    
    init (context: Context, array: UnsafePointer<Void> = nil, componentDatatype: ComponentDatatype, sizeInBytes: Int) {
        
        assert(sizeInBytes > 0, "bufferSize must be greater than zero")
        
        if array != nil {
            _metalBuffer = context.device.newBufferWithBytes(array, length: sizeInBytes, options: nil)
        } else {
            _metalBuffer = context.device.newBufferWithLength(sizeInBytes, options: nil)
        }
        
        self.componentDatatype = componentDatatype
    }
    
}