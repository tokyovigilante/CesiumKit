//
//  VertexAttributes.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 17/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

class VertexAttributes {
    
    var index: Int
    
    var enabled: Bool
    
    var vertexBuffer: Buffer?
    
    var value: NSData? = nil
    
    var componentsPerAttribute: Int
    
    var componentDatatype: ComponentDatatype
    
    var normalize: Bool
    
    var offsetInBytes: Int
    
    var strideInBytes: Int
    
    var vertexAttrib: () -> ()
    
    var disableVertexAttribArray: () -> ()
    
    init (
        index: Int,
        enabled: Bool = true,
        vertexBuffer: Buffer? = nil,
        value: NSData? = nil,
        componentsPerAttribute: Int,
        componentDatatype: ComponentDatatype = .Float32,
        normalize: Bool = false,
        offsetInBytes: Int = 0,
        strideInBytes: Int = 0) {
            self.index = index
            self.enabled = enabled
            self.vertexBuffer = vertexBuffer
            self.componentsPerAttribute = componentsPerAttribute
            self.componentDatatype = componentDatatype
            self.normalize = normalize
            self.offsetInBytes = offsetInBytes
            self.strideInBytes = strideInBytes
            
            vertexAttrib = {}
            disableVertexAttribArray = {}
    }
    
    func copy() -> VertexAttributes {
        return VertexAttributes(
            index: self.index,
            enabled: self.enabled,
            vertexBuffer: self.vertexBuffer,
            value: self.value,
            componentsPerAttribute: self.componentsPerAttribute,
            componentDatatype: self.componentDatatype,
            normalize: self.normalize,
            offsetInBytes: self.offsetInBytes,
            strideInBytes: self.strideInBytes)
    }
    
}