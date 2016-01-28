//
//  BufferProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/06/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation
import Metal

class UniformBufferProvider {
    
    let capacity: Int
    
    private (set) var bufferSize: Int
    
    private var _buffers = [Buffer]()
    
    private var _memBarrierIndex: Int = 0
    
    init (device: MTLDevice, capacity: Int, bufferSize: Int) {
        
        self.capacity = capacity
        self.bufferSize = bufferSize
        
        for _ in 0..<capacity {
            _buffers.append(Buffer(device: device, array: nil, componentDatatype: .Byte, sizeInBytes: bufferSize))
        }
    }
    
    func nextBuffer() -> Buffer {
        let buffer = _buffers[_memBarrierIndex]
        _memBarrierIndex = (_memBarrierIndex + 1) % capacity
        bzero(buffer.data, bufferSize)
        return buffer
    }

}

