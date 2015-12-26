//
//  NSData+ArrayView.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

extension NSData {
    
    func getFloat32(pos: Int, littleEndian: Bool = true) -> Float {
        assert(self.length >= pos + sizeof(Float), "pos out of bounds")
        var result: Float = 0.0
        getBytes(&result, range: NSMakeRange(pos, sizeof(Float)))
        return result
    }
    
    func getFloat64(pos: Int, littleEndian: Bool = true) -> Double {
        assert(self.length >= pos + sizeof(Double), "pos out of bounds")
        var result: Double = 0.0
        getBytes(&result, range: NSMakeRange(pos, sizeof(Double)))
        return result
    }
    
    func getUInt32(pos: Int, littleEndian: Bool = true) -> UInt32 {
        assert(self.length >= pos + sizeof(UInt32), "pos out of bounds")
        var result: UInt32 = 0
        getBytes(&result, range: NSMakeRange(pos, sizeof(UInt32)))
        return littleEndian ? result : result.bigEndian
    }
    
    func getUInt16Array(pos: Int, elementCount: Int, littleEndian: Bool = true) -> [UInt16] {
        let arrayByteLength = elementCount * sizeof(UInt16)
        assert(self.length >= pos + arrayByteLength, "pos out of bounds")
        var result = [UInt16](count: elementCount, repeatedValue: 0)
        result.withUnsafeMutableBufferPointer({ (inout pointer: UnsafeMutableBufferPointer<UInt16>) in
            memcpy(pointer.baseAddress, self.bytes + pos, arrayByteLength)
        })
        return littleEndian ? result : result.map({ $0.bigEndian })
    }

}