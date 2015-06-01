//
//  VertexDescriptor.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/05/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

struct VertexAttributes {
    let bufferIndex: Int
    let format: VertexType
    let offset: Int
    let size: Int
}

import Metal

class VertexDescriptor {
    
    let metalDescriptor: MTLVertexDescriptor
    
    init (attributes: [VertexAttributes]) {
        
        metalDescriptor = MTLVertexDescriptor()

        // Set up layout descriptor
        metalDescriptor.layouts[0].stepFunction = .PerVertex
        
        // Verify all attribute names are unique
        var uniqueIndices = [Bool](count: attributes.count, repeatedValue: false)
        for (index, va) in enumerate(attributes) {
            if uniqueIndices[index] {
                assertionFailure("Index \(index) is used by more than one attribute.")
            }
            uniqueIndices[index] = true
            addAttribute(va, index: index)
        }
    }
    
    private func addAttribute(attribute: VertexAttributes, index: Int) {
        
        metalDescriptor.attributes[index].bufferIndex = attribute.bufferIndex
        metalDescriptor.attributes[index].format = attribute.format.metalVertexFormat
        metalDescriptor.attributes[index].offset = attribute.offset
        
        metalDescriptor.layouts[0].stride += attribute.size
        
        /*var hasVertexBuffer = attribute.vertexBuffer != nil
        var hasValue = attribute.value != nil
        var componentsPerAttribute = (attribute.value != nil) ? attribute.value!.length : attribute.componentsPerAttribute
        
        // FIXME: vertexbuffer.value
        assert(hasVertexBuffer != hasValue, "attribute must have a vertexBuffer or a value. It must have either a vertexBuffer property defining per-vertex data or a value property defining data for all vertices")
        
        assert(componentsPerAttribute >= 1 && componentsPerAttribute <= 4, "attribute.value.length must be in the range [1, 4]")
        
        if (defined(attribute.strideInBytes) && (attribute.strideInBytes > 255)) {
        // WebGL limit.  Not in GL ES.
        throw new DeveloperError('attribute must have a strideInBytes less than or equal to 255 or not specify it.');
        }*/
    }
}
