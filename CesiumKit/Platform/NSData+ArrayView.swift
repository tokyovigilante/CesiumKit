//
//  NSData+ArrayView.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

extension Data {
    
    func getFloat32(_ pos: Int, littleEndian: Bool = true) -> Float {
        assert(self.count >= pos + MemoryLayout<Float>.size, "pos out of bounds")
        var result: Float = 0.0
        _ = withUnsafeBytes { pointer in
            memcpy(&result, pointer+pos, MemoryLayout.size(ofValue: result))
        }
        return result
    }
    
    func getFloat64(_ pos: Int, littleEndian: Bool = true) -> Double {
        assert(self.count >= pos + MemoryLayout<Double>.size, "pos out of bounds")
        var result: Double = 0.0
        Float()
        _ = withUnsafeBytes { pointer in
            memcpy(&result, pointer+pos, MemoryLayout.size(ofValue: result))
        }
        return result
    }
    
    func getUInt8(_ pos: Int) -> UInt8 {
        assert(self.count >= pos + MemoryLayout<UInt8>.size, "pos out of bounds")
        var result: UInt8 = 0
        _ = withUnsafeBytes { pointer in
            memcpy(&result, pointer+pos, MemoryLayout.size(ofValue: result))
        }
        return result
    }
    
    func getUInt32(_ pos: Int, littleEndian: Bool = true) -> UInt32 {
        assert(self.count >= pos + MemoryLayout<UInt32>.size, "pos out of bounds")
        var result: UInt32 = 0
        _ = withUnsafeBytes { pointer in
            memcpy(&result, pointer+pos, MemoryLayout.size(ofValue: result))
        }
        return littleEndian ? result : result.bigEndian
    }
    
    func getUInt8Array(_ pos: Int = 0, elementCount: Int? = nil) -> [UInt8] {
        let elementCount = elementCount ?? self.count
        assert(self.count >= pos + elementCount, "requested array out of bounds")
        var result = [UInt8](repeating: 0, count: elementCount)
        copyBytes(to: &result, from: Range(uncheckedBounds: (lower: pos, upper: pos+elementCount)))
        return result
    }
    
    func getUInt16Array(_ pos: Int = 0, elementCount: Int? = nil, littleEndian: Bool = true) -> [UInt16] {
        let elementCount = elementCount ?? self.count / MemoryLayout<UInt16>.stride
        let arrayByteLength = elementCount * MemoryLayout<UInt16>.stride
        assert(self.count >= pos + arrayByteLength, "requested array out of bounds")
        var result = [UInt16](repeating: 0, count: elementCount)
        _ = result.withUnsafeMutableBufferPointer { (pointer: inout UnsafeMutableBufferPointer<UInt16>) in
            memcpy(pointer.baseAddress, (self as NSData).bytes + pos, arrayByteLength)
        }
        return littleEndian ? result : result.map { $0.bigEndian }
    }
    
    func getUInt32Array(_ pos: Int = 0, elementCount: Int? = nil, littleEndian: Bool = true) -> [UInt32] {
        let elementCount = elementCount ?? self.count / MemoryLayout<UInt32>.stride
        let arrayByteLength = elementCount * MemoryLayout<UInt32>.stride
        assert(self.count >= pos + arrayByteLength, "requested array out of bounds")
        var result = [UInt32](repeating: 0, count: elementCount)
        _ = result.withUnsafeMutableBufferPointer { (pointer: inout UnsafeMutableBufferPointer<UInt32>) in
            memcpy(pointer.baseAddress, (self as NSData).bytes + pos, arrayByteLength)
        }
        return littleEndian ? result : result.map { $0.bigEndian }
    }

}
