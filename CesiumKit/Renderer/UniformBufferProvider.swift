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

    private var buffers = [Buffer]()
    
    private var memBarrierIndex: Int = 0
    
    
    init (device: MTLDevice, capacity: Int, sizeInBytes: Int) {
        
        self.capacity = capacity
        self.bufferSize = sizeInBytes
        
        for i in 0..<capacity {
            buffers.append(Buffer(device: device, array: nil, componentDatatype: .Byte, sizeInBytes: sizeInBytes))
        }
    }
    
    func nextBuffer() -> Buffer {
        
        let buffer = buffers[memBarrierIndex]

        memBarrierIndex = (memBarrierIndex + 1) % capacity

        return buffer
    }

}

