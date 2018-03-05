//
//  ImageBuffer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/// raw image data, default 32-bit RGBA
class Imagebuffer {
    let array: [UInt8]
    let width: Int
    let height: Int
    let bytesPerPixel: Int

    init(array: [UInt8], width: Int, height: Int, bytesPerPixel bpp: Int = 4) {
        self.array = array
        self.width = width
        self.height = height
        self.bytesPerPixel = bpp
    }

}
