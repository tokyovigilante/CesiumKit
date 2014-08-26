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

var pixelData: NSData? {
get {
    if format == .Raw {
    return _compressedData
}
if _pixelData == nil {
    return decompress() ? _compressedData! : nil
}
return _pixelData!
}
}

var _pixelData: NSData?

let compressedData: NSData

private func decompress () -> Bool {
 //   case
}
}