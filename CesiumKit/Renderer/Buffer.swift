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
    
    // bytes
    let length: Int
    
    private let _entireRange: NSRange
    
    var count: Int {
        return length / componentDatatype.elementSize
    }
    
    /**
     Creates a Metal GPU buffer. If an allocated memory region is passed in, it will be
     copied to the buffer and can be released (or automatically released via ARC). 
    */
    init (device: MTLDevice, array: UnsafePointer<Void> = nil, componentDatatype: ComponentDatatype, sizeInBytes: Int, label: String? = nil) {
        assert(sizeInBytes > 0, "bufferSize must be greater than zero")
        
        length = sizeInBytes
        self.componentDatatype = componentDatatype
        _entireRange = NSMakeRange(0, length)
        
        if array != nil {
            #if os(OSX)
                metalBuffer = device.newBufferWithBytes(array, length: length, options: .StorageModeManaged)
            #elseif os(iOS)
                metalBuffer = device.newBufferWithBytes(array, length: length, options: .StorageModeShared)
            #endif
        } else {
            #if os(OSX)
                metalBuffer = device.newBufferWithLength(length, options: .StorageModeManaged)
            #elseif os(iOS)
                metalBuffer = device.newBufferWithLength(length, options: .StorageModeShared)
            #endif
        }
        if let label = label {
            metalBuffer.label = label
        }
    }
    
    func copyFromArray (array: UnsafePointer<Void>, length arrayLength: Int, offset: Int = 0) {
        assert(offset + arrayLength <= length, "This buffer is not large enough")
        
        memcpy(data, array+offset, arrayLength)
        signalWriteComplete()
    }
    
    
    func signalWriteComplete (range: NSRange? = nil) {
        #if os(OSX)
            metalBuffer.didModifyRange(range ?? _entireRange)
        #endif
    }
    
}