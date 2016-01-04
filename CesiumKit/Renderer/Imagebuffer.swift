//
//  ImageBuffer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/// RGBA image data
class Imagebuffer {
    let array: [UInt8]
    let width: Int
    let height: Int
    
    init(array: [UInt8], width: Int, height: Int) {
        self.array = array
        self.width = width
        self.height = height
    }
    
}