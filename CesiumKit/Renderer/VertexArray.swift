//
//  VertexArray.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

class VertexArray {
        
    var vertexBuffer: Buffer
    
    var vertexCount: Int
    
    let indexBuffer: Buffer?
    
    let indexType: MTLIndexType
    
    var numberOfIndices: Int {
        return indexBuffer == nil ? 0 : indexBuffer!.length / indexBuffer!.componentDatatype.elementSize
    }

    init(vertexBuffer: Buffer, vertexCount: Int, indexType: MTLIndexType = .UInt16, indexBuffer: Buffer? = nil) {
        
        self.vertexBuffer = vertexBuffer
        self.vertexCount = vertexCount
        self.indexType = indexType
        self.indexBuffer = indexBuffer
        
    }
    
}

