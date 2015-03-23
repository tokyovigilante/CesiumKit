//
//  SerializedType
//  CesiumKit
//
//  Created by Ryan Walklin on 16/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

protocol SerializableContainer {
    
    var sizeInBytes: Int { get }
    
    func data() -> NSData
}

extension Array: SerializableContainer {
    
    var sizeInBytes: Int {
        get {
            if !self.isEmpty {
                if self.first is SerializedType? {
                    return (self.first as! SerializedType!).elementSize() * self.count
                }
            }
            return 0
        }
    }
    
    func data() -> NSData {
        
        let length = sizeInBytes

        if length == 0 {
            return NSData()
        }
        
        let firstValue = self.first! as! SerializedType

        switch firstValue {
        case .UnsignedInt8:
            let array = self.map ({ ($0 as! SerializedType).unsignedInt8Value() })
            
            return NSData(bytes: array, length: sizeInBytes)
        case .UnsignedInt16:
            let array = self.map ({ ($0 as! SerializedType).unsignedInt16Value() })
            
            return NSData(bytes: array, length: sizeInBytes)
        case .UnsignedInt32:
            let array = self.map ({ ($0 as! SerializedType).unsignedInt32Value() })
            
            return NSData(bytes: array, length: sizeInBytes)
        case .Float32(let value):
            let array = self.map ({ ($0 as! SerializedType).floatValue() })
            
            return NSData(bytes: array, length: sizeInBytes)
        case .Float64(let value):
            let array = self.map ({ ($0 as! SerializedType).doubleValue() })
            
            return NSData(bytes: array, length: sizeInBytes)
        }
    }
    
}

enum SerializedType {
    case UnsignedInt8(UInt8)
    case UnsignedInt16(UInt16)
    case UnsignedInt32(UInt32)
    case Float32(Float)
    case Float64(Double)
    
    func elementSize() -> Int {
        switch self {
        case UnsignedInt8:
            return sizeof(UInt8)
        case UnsignedInt16:
            return sizeof(UInt16)
        case .UnsignedInt32:
            return sizeof(UInt32)
        case .Float32(let value):
            return sizeof(Float)
        case .Float64(let value):
            return sizeof(Double)
        }
    }
    
    func datatype() -> ComponentDatatype {
        switch self {
        case UnsignedInt8:
            return .UnsignedByte
        case UnsignedInt16:
            return .UnsignedShort
        case .UnsignedInt32:
            return .UnsignedInt
        case .Float32:
            return .Float32
        case .Float64:
            return .Float64
        }
    }
    
    func unsignedInt8Value() -> UInt8 {
        switch self {
        case .UnsignedInt8(let value):
            return value
        case .UnsignedInt16(let value):
            return UInt8(value)
        case .UnsignedInt32(let value):
            return UInt8(value)
        case .Float32(let value):
            return UInt8(value)
        case .Float64(let value):
            return UInt8(value)
        }
    }
    
    func unsignedInt16Value() -> UInt16 {
        switch self {
        case .UnsignedInt8(let value):
            return UInt16(value)
        case .UnsignedInt16(let value):
            return value
        case .UnsignedInt32(let value):
            return UInt16(value)
        case .Float32(let value):
            return UInt16(value)
        case .Float64(let value):
            return UInt16(value)
        }
    }
    
    func unsignedInt32Value() -> UInt32 {
        switch self {
        case .UnsignedInt8(let value):
            return UInt32(value)
        case .UnsignedInt16(let value):
            return UInt32(value)
        case .UnsignedInt32(let value):
            return value
        case .Float32(let value):
            return UInt32(value)
        case .Float64(let value):
            return UInt32(value)
        }
    }
    
    static func unsignedInt32Array(values: [SerializedType]) -> [UInt32] {
        return values.map { return $0.unsignedInt32Value() }
    }
    
    static func fromIntArray(values: [Int], datatype: ComponentDatatype) -> [SerializedType] {
        switch datatype {
        case .Byte:
            return values.map({ .UnsignedInt8(UInt8($0)) })
        case .UnsignedByte:
            return values.map({ .UnsignedInt8(UInt8($0)) })
        case .Short:
            return values.map({ .UnsignedInt16(UInt16($0)) })
        case .UnsignedShort:
            return values.map({ .UnsignedInt16(UInt16($0)) })
        case .UnsignedInt:
            return values.map({ .UnsignedInt32(UInt32($0)) })
        case .Float32(let value):
            return values.map({ .Float32(Float($0)) })
        case .Float64(let value):
            return values.map({ .Float64(Double($0)) })
        }
    }
    
    static func fromUInt16Array(values: [UInt16]) -> [SerializedType] {
        return values.map({ return .UnsignedInt16($0) })
    }
    
    func floatValue() -> Float {
        switch self {
        case .UnsignedInt32(let value):
            return Float(value)
        case .Float32(let value):
            return value
        case .Float64(let value):
            return Float(value)
        default:
            return 0.0
        }
    }
    
    static func floatArray(values: [SerializedType]) -> [Float] {
        return values.map { return $0.floatValue() }
    }
    
    static func fromFloatArray(values: [Float]) -> [SerializedType] {
        return values.map { return .Float32($0) }
    }
    
    func doubleValue() -> Double {
        switch self {
        case .UnsignedInt32(let value):
            return Double(value)
        case .Float32(let value):
            return Double(value)
        case .Float64(let value):
            return value
        default:
            return 0.0
        }
    }

}

protocol SerializableNumber {}

extension Int: SerializableNumber {}
extension UInt16: SerializableNumber {}
extension UInt32: SerializableNumber {}


