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
    
    let bufferSize: Int
    
    var currentBuffer: Buffer {
        return _buffers[_memBarrierIndex]
    }
    
    private var _buffers = [Buffer]()
    
    private var _memBarrierIndex: Int = 0
    
    private let _entireRange: NSRange
    
    init (device: MTLDevice, capacity: Int, bufferSize: Int) {
        
        self.capacity = capacity
        self.bufferSize = bufferSize
        _entireRange = NSMakeRange(0, self.bufferSize)
        
        for _ in 0..<capacity {
            _buffers.append(Buffer(device: device, array: nil, componentDatatype: .Byte, sizeInBytes: self.bufferSize))
        }
    }
    func advanceBuffer () -> Buffer {
        _memBarrierIndex = (_memBarrierIndex + 1) % capacity
        return currentBuffer
    }

    func signalWriteComplete (range: NSRange? = nil) {
        #if os(OSX)
            _buffers[_memBarrierIndex].metalBuffer.didModifyRange(range ?? _entireRange)
        #endif
    }

}

