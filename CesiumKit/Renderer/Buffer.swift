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
    
    // bytes
    let length: Int
    
    fileprivate let _entireRange: NSRange
    
    var count: Int {
        return length / componentDatatype.elementSize
    }
    
    /**
     Creates a Metal GPU buffer. If an allocated memory region is passed in, it will be
     copied to the buffer and can be released (or automatically released via ARC). 
    */
    init (device: MTLDevice, array: UnsafeRawPointer? = nil, componentDatatype: ComponentDatatype, sizeInBytes: Int, label: String? = nil) {
        assert(sizeInBytes > 0, "bufferSize must be greater than zero")
        
        length = sizeInBytes
        self.componentDatatype = componentDatatype
        _entireRange = NSMakeRange(0, length)
        
        if let array = array {
            #if os(OSX)
                metalBuffer = device.newBuffer(withBytes: array, length: length, options: .storageModeManaged)
            #elseif os(iOS)
                metalBuffer = device.newBuffer(withBytes: array, length: length, options: MTLResourceOptions())
            #endif
        } else {
            #if os(OSX)
                metalBuffer = device.newBuffer(withLength: length, options: .storageModeManaged)
            #elseif os(iOS)
                metalBuffer = device.newBuffer(withLength: length, options: MTLResourceOptions())
            #endif
        }
        if let label = label {
            metalBuffer.label = label
        }
    }
    
    func read (into data: UnsafeMutableRawPointer, length readLength: Int, offset: Int = 0) {
        assert(offset + readLength <= length, "This buffer is not large enough")
        memcpy(data, metalBuffer.contents()+offset, readLength)
    }
    
    func write (from data: UnsafeRawPointer, length writeLength: Int, offset: Int = 0) {
        assert(offset + writeLength <= length, "This buffer is not large enough")
        memcpy(metalBuffer.contents()+offset, data, writeLength)
    }
    
    func copy (from other: Buffer, length copyLength: Int, sourceOffset: Int = 0, targetOffset: Int = 0) {
        assert(sourceOffset + copyLength <= other.length, "source buffer not large enough")
        assert(targetOffset + copyLength <= length, "This buffer is not large enough")
        memcpy(metalBuffer.contents()+targetOffset, other.metalBuffer.contents()+sourceOffset, copyLength)
    }
    
    func signalWriteComplete (_ range: NSRange? = nil) {
        #if os(OSX)
            metalBuffer.didModifyRange(range ?? _entireRange)
        #endif
    }
    
}
