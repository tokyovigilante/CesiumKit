//
//  BufferProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/06/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation
import Metal

class BufferProvider {
    
    let inflightBuffersCount: Int
    
    private var buffers = [Buffer]()
    
    private var availableBufferIndex: Int = 0
    
    private let resourceSemaphore: dispatch_semaphore_t
    
    init (device: MTLDevice, inflightBuffersCount: Int, sizeInBytes: Int) {
        
        self.inflightBuffersCount = inflightBuffersCount
        
        resourceSemaphore = dispatch_semaphore_create(inflightBuffersCount)

        for i in 0..<inflightBuffersCount {
            buffers.append(Buffer(device: device, array: nil, componentDatatype: .Byte, sizeInBytes: sizeInBytes))
        }
    }
    
    func nextBuffer() -> Buffer {
        
        dispatch_semaphore_wait(resourceSemaphore, DISPATCH_TIME_FOREVER)
        
        if availableBufferIndex == inflightBuffersCount {
            availableBufferIndex = 0
        }
        return buffers[availableBufferIndex++]
    }
    
    deinit {
        for i in 0..<inflightBuffersCount {
            dispatch_semaphore_signal(resourceSemaphore)
        }
    }
}

