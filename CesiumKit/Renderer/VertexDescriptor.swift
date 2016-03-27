//
//  VertexDescriptor.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/05/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

let VertexDescriptorFirstBufferOffset = 1

struct VertexAttributes {
    var buffer: Buffer?
    let bufferIndex: Int
    let index: Int
    let format: VertexType
    let offset: Int
    let size: Int
    let normalize: Bool
}

import Metal

class VertexDescriptor {
    
    let metalDescriptor: MTLVertexDescriptor
    
    init (attributes: [VertexAttributes]) {
        
        metalDescriptor = MTLVertexDescriptor()

        let bufferIndex = attributes.first?.bufferIndex ?? 1
        // Set up layout descriptor
        metalDescriptor.layouts[bufferIndex].stepFunction = .PerVertex
        metalDescriptor.layouts[bufferIndex].stepRate = 1

        
        // Verify all attribute names are unique
        var uniqueIndices = [Bool](count: attributes.count, repeatedValue: false)
        for (index, va) in attributes.enumerate() {
            if uniqueIndices[index] {
                assertionFailure("Index \(index) is used by more than one attribute.")
            }
            uniqueIndices[index] = true
            addAttribute(va)
        }
    }
    
    private func addAttribute(attribute: VertexAttributes) {
        let index = attribute.index
        metalDescriptor.attributes[index].bufferIndex = attribute.bufferIndex
        metalDescriptor.attributes[index].format = attribute.format.metalVertexFormat
        metalDescriptor.attributes[index].offset = attribute.offset
        
        metalDescriptor.layouts[attribute.bufferIndex].stride += attribute.size
    }
}
