//
//  BufferProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/06/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation
import Metal

public class UniformBufferProvider {
    
    let bufferSize: Int
    
    private var _buffers = [Buffer]()
    
    let deallocationBlock: UniformMapDeallocBlock?
    
    init (device: MTLDevice, bufferSize: Int, deallocationBlock: UniformMapDeallocBlock?) {
        
        self.bufferSize = bufferSize
        self.deallocationBlock = deallocationBlock
        
        for _ in 0..<BufferSyncState.count {
            _buffers.append(Buffer(device: device, array: nil, componentDatatype: .Byte, sizeInBytes: self.bufferSize))
        }
    }
    
    func currentBuffer(index: BufferSyncState) -> Buffer {
        return _buffers[index.rawValue]
    }
}

