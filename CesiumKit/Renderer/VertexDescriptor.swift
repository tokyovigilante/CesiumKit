//
//  VertexDescriptor.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/05/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation
import Metal

let VertexDescriptorFirstBufferOffset = 3 // auto = 0, frustum = 1, manual = 2

struct VertexAttributes {
    var buffer: Buffer?
    let bufferIndex: Int
    let index: Int
    let format: VertexType
    let offset: Int
    let size: Int
    let normalize: Bool
}

class VertexDescriptor {
    
    let metalDescriptor: MTLVertexDescriptor
    
    init (attributes: [VertexAttributes]) {
        
        metalDescriptor = MTLVertexDescriptor()

        let bufferIndex = attributes.first?.bufferIndex ?? 1
        // Set up layout descriptor
        metalDescriptor.layouts[bufferIndex].stepFunction = .perVertex
        metalDescriptor.layouts[bufferIndex].stepRate = 1

        
        // Verify all attribute names are unique
        var uniqueIndices = [Bool](repeating: false, count: attributes.count)
        for (index, va) in attributes.enumerated() {
            if uniqueIndices[index] {
                assertionFailure("Index \(index) is used by more than one attribute.")
            }
            uniqueIndices[index] = true
            addAttribute(va)
        }
    }
    
    fileprivate func addAttribute(_ attribute: VertexAttributes) {
        let index = attribute.index
        metalDescriptor.attributes[index].bufferIndex = attribute.bufferIndex
        metalDescriptor.attributes[index].format = attribute.format.metalVertexFormat
        metalDescriptor.attributes[index].offset = attribute.offset
        
        metalDescriptor.layouts[attribute.bufferIndex].stride += attribute.size
    }
}
