//
//  VertexArray.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

class VertexArray {
    
    var vertexDescriptor: MTLVertexDescriptor
    
    var vertexBuffer: Buffer
    
    var vertexCount: Int
    
    let indexBuffer: Buffer?

    init(vertexBuffer: Buffer, vertexCount: Int, attributes: [VertexAttributes], indexBuffer: Buffer?) {
        
        self.vertexDescriptor = MTLVertexDescriptor()
        self.vertexBuffer = vertexBuffer
        self.vertexCount = vertexCount
        self.indexBuffer = indexBuffer
        
        // Set up layout descriptor
        var layout = vertexDescriptor.layouts[0]
        layout.stepFunction = .PerVertex

        // Verify all attribute names are unique
        var uniqueIndices = [Bool](count: attributes.count, repeatedValue: false)
        for (i, va) in enumerate(attributes) {
            let index = va.bufferIndex
            if uniqueIndices[index] {
                assertionFailure("Index \(index) is used by more than one attribute.")
            }
            uniqueIndices[index] = true
            addAttribute(va, index: i)
        }
    }
    
    func addAttribute(attribute: VertexAttributes, index: Int) {
        
        vertexDescriptor.attributes[index].bufferIndex = attribute.bufferIndex
        vertexDescriptor.attributes[index].format = attribute.format.metalVertexFormat
        vertexDescriptor.attributes[index].offset = attribute.offset
        
        vertexDescriptor.layouts[0].stride += attribute.size
        
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
    
/**
* index is the location in the array of attributes, not the index property of an attribute.
*/
    /*func attribute(index: Int) -> VertexAttributes {
        return _attributes[index]
    }*/

}

