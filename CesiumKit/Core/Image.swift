//
//  File.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 24/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

enum ImageFormat {
    case JPEG, PNG, Raw
}

/// HTML5-equivalent image wrapper
class Image {
    
    let format: ImageFormat
    
    let height: Int?
    
    let width: Int?
    
    var pixelData: [UInt8]? {
        get {
            if _pixelData == nil {
                return decompress() ? _pixelData! : nil
            }
            return _pixelData!
        }
    }
    
    var _pixelData: [UInt8]? = nil
    
    let _compressedData: [UInt8]? = nil
    
    init (format: ImageFormat, height: Int? = nil, width: Int? = nil, data: [UInt8]) {
        
        self.format = format
        
        self.height = height
        self.width = width
        
        if self.format == .Raw {
            _pixelData = data
        }
        else {
            _compressedData = data
        }
    }
    
    private func decompress () -> Bool {
        //   case
        return false
    }
}