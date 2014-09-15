//
//  VertexAttribute.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 14/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

struct VertexAttribute {
    
    var index: Int
    
    var enabled: Bool
    
    var vertexBuffer: VertexBuffer
    
    var componentsPerAttribute: Int
    
    var componentDatatype: ComponentDatatype
    
    var normalize: Bool
    
    var offsetInBytes: Int
    
    var strideInBytes: Int

    init (
        index: Int,
        enabled: Bool = true,
        vertexBuffer: VertexBuffer,
        componentsPerAttribute: Int,
        componentDatatype: ComponentDatatype = ComponentDatatype.Float32(0),
        normalize: Bool = false,
        offsetInBytes: Int = 0,
        strideInBytes: Int = 0) {
            self.index = index
            self.enabled = enabled
            self.vertexBuffer = vertexBuffer
            self.componentsPerAttribute = componentsPerAttribute
            self.componentDatatype = componentDatatype
            self.offsetInBytes = offsetInBytes
            self.strideInBytes = strideInBytes
    }
    
}
