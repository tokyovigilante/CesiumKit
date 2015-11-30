//
//  Buffer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/05/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Metal

class Buffer {
    
    let metalBuffer: MTLBuffer
    
    var componentDatatype: ComponentDatatype
    
    var data: UnsafeMutablePointer<Void> {
        return metalBuffer.contents()
    }
    
    let length: Int
    
    /**
    * Creates a Metal GPU buffer. If an allocated memory region is passed in, it will be
    * copied to the buffer and can be released (or automatically released via ARC)
    */
    init (device: MTLDevice, array: UnsafePointer<Void> = nil, componentDatatype: ComponentDatatype, sizeInBytes: Int) {
        
        assert(sizeInBytes > 0, "bufferSize must be greater than zero")
        
        if array != nil {
            #if os(OSX)
                metalBuffer = device.newBufferWithBytes(array, length: sizeInBytes, options: .StorageModeManaged)
            #elseif os(iOS)
                metalBuffer = device.newBufferWithBytes(array, length: sizeInBytes, options: .StorageModeShared)
            #endif
        } else {
            #if os(OSX)
                metalBuffer = device.newBufferWithLength(sizeInBytes, options: .StorageModeManaged)

            #elseif os(iOS)
                metalBuffer = device.newBufferWithLength(sizeInBytes, options: .StorageModeShared)
            #endif
        }
        
        self.componentDatatype = componentDatatype
        self.length = sizeInBytes
    }
    
}