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
    private let _vertexBufferSize: Int
    private let _fragmentBufferSize: Int
    
    var bufferSize: Int {
        return _vertexBufferSize + _fragmentBufferSize
    }

    private var vertexBuffers = [Buffer]()
    private var fragmentBuffers = [Buffer]()
    
    private var memBarrierIndex: Int = 0
    
    init (device: MTLDevice, capacity: Int, vertexSize: Int, fragmentSize: Int) {
        
        self.capacity = capacity
        _vertexBufferSize = vertexSize
        _fragmentBufferSize = fragmentSize
        
        for _ in 0..<capacity {
            vertexBuffers.append(Buffer(device: device, array: nil, componentDatatype: .Byte, sizeInBytes: max(vertexSize, 256)))
            fragmentBuffers.append(Buffer(device: device, array: nil, componentDatatype: .Byte, sizeInBytes: max(fragmentSize, 256)))
        }
    }
    
    func nextBuffer() -> (vertex: Buffer, fragment: Buffer) {
        let vertexBuffer = vertexBuffers[memBarrierIndex]
        let fragmentBuffer = fragmentBuffers[memBarrierIndex]
        memBarrierIndex = (memBarrierIndex + 1) % capacity
        return (vertexBuffer, fragmentBuffer)
    }

}

