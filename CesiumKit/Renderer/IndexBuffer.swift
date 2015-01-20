//
//  IndexBuffer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

class IndexBuffer: Buffer {
    
    let indexDatatype: IndexDatatype
    
    let bytesPerIndex: Int
    
    let numberOfIndices: Int
    
    init (array: [SerializedType]? = nil, sizeInBytes: Int? = nil, usage: BufferUsage = .StaticDraw, indexDatatype: IndexDatatype) {
        
        self.indexDatatype = indexDatatype
        
        bytesPerIndex = indexDatatype.elementSize()
        
        if array != nil {
            numberOfIndices = array!.count
        } else if sizeInBytes != nil {
            numberOfIndices = sizeInBytes! / self.bytesPerIndex
        } else {
            numberOfIndices = 0
        }
        
        super.init(target: .ArrayBuffer, array: array, sizeInBytes: sizeInBytes, usage: usage)

    }
    
}