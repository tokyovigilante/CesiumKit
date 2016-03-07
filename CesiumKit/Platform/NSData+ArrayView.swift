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
    
    func getUInt8(pos: Int) -> UInt8 {
        assert(self.length >= pos + sizeof(UInt8), "pos out of bounds")
        var result: UInt8 = 0
        getBytes(&result, range: NSMakeRange(pos, sizeof(UInt8)))
        return result
    }
    
    func getUInt32(pos: Int, littleEndian: Bool = true) -> UInt32 {
        assert(self.length >= pos + sizeof(UInt32), "pos out of bounds")
        var result: UInt32 = 0
        getBytes(&result, range: NSMakeRange(pos, sizeof(UInt32)))
        return littleEndian ? result : result.bigEndian
    }
    
    func getUInt8Array(pos: Int = 0, elementCount: Int? = nil) -> [UInt8] {
        let elementCount = elementCount ?? self.length
        assert(self.length >= pos + elementCount, "requested array out of bounds")
        var result = [UInt8](count: elementCount, repeatedValue: 0)
        result.withUnsafeMutableBufferPointer({ (inout pointer: UnsafeMutableBufferPointer<UInt8>) in
            memcpy(pointer.baseAddress, self.bytes + pos, elementCount)
        })
        return result
    }
    
    func getUInt16Array(pos: Int = 0, elementCount: Int? = nil, littleEndian: Bool = true) -> [UInt16] {
        let elementCount = elementCount ?? self.length / strideof(UInt16)
        let arrayByteLength = elementCount * strideof(UInt16)
        assert(self.length >= pos + arrayByteLength, "requested array out of bounds")
        var result = [UInt16](count: elementCount, repeatedValue: 0)
        result.withUnsafeMutableBufferPointer({ (inout pointer: UnsafeMutableBufferPointer<UInt16>) in
            memcpy(pointer.baseAddress, self.bytes + pos, arrayByteLength)
        })
        return littleEndian ? result : result.map({ $0.bigEndian })
    }
    
    func getUInt32Array(pos: Int = 0, elementCount: Int? = nil, littleEndian: Bool = true) -> [UInt32] {
        let elementCount = elementCount ?? self.length / strideof(UInt32)
        let arrayByteLength = elementCount * strideof(UInt32)
        assert(self.length >= pos + arrayByteLength, "requested array out of bounds")
        var result = [UInt32](count: elementCount, repeatedValue: 0)
        result.withUnsafeMutableBufferPointer({ (inout pointer: UnsafeMutableBufferPointer<UInt32>) in
            memcpy(pointer.baseAddress, self.bytes + pos, arrayByteLength)
        })
        return littleEndian ? result : result.map({ $0.bigEndian })
    }

    class func fromUInt8Array (array: [UInt8]) -> NSData {
        let arrayCount = array.count
        let result = NSMutableData(capacity: arrayCount)!
        result.replaceBytesInRange(NSMakeRange(0, arrayCount), withBytes: array)
        return NSData(data: result)
    }
}