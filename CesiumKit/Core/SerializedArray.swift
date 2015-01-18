//
//  SerializableArray.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

class SerializedArray {
    
    private let _storageBuffer: NSData
    
    let datatype: ComponentDatatype
    
    var sizeInBytes: Int {
        get {
            return _storageBuffer.length
        }
    }
    
    var count: Int {
        get {
            return _storageBuffer.length / datatype.elementSize()
        }
    }
    
    init(data: NSData, type: ComponentDatatype) {
        
        datatype = type
        _storageBuffer = data
    }
    
    func bytes () -> UnsafePointer<Void> {
        return _storageBuffer.bytes
    }
    
    subscript(index: Int) -> Int {
        get {
            var value: Int8 = 0
            // return an appropriate subscript value here
            _storageBuffer.getBytes(&value, range: NSMakeRange(index, sizeof(Int8)))
            return Int(value)
        }
    /*set(newValue) {
    // perform a suitable setting action here
    _storageBuffer.replaceBytesInRange(<#range: NSRange#>, withBytes: <#UnsafePointer<Void>#>)
    }*/
    }
    
    func description () -> String {
        return "\(count) objects"
    }
    
    /*func deserializeFloat32 () -> [Float] {
        return Float.deserializeFromArray(self._storageBuffer)
    }*/
}

protocol Serializable {
    
    class func serialize<SerializedType>(value: SerializedType) -> NSData
    class func serializeArray<SerializedType>(values:[SerializedType]) -> NSData
    func hexStringValue() -> String
}

protocol Deserializable {

    class func deserialize<SerializedType>(start: Int?) -> SerializedType
    class func deserializeArray<SerializedType>(array: SerializedArray) -> [SerializedType]
}

extension NSData: Serializable {
    
    public class func serialize<SerializedType>(value: SerializedType) -> NSData {
        let values = [value]
        return NSData(bytes:values, length:sizeof(SerializedType))
    }
    
    public class func serializeArray<SerializedType>(values:[SerializedType]) -> NSData {
        return NSData(bytes:values, length:values.count*sizeof(SerializedType))
    }

    
    public func hexStringValue() -> String {
        var dataBytes = Array<Byte>(count:self.length, repeatedValue:0x0)
        self.getBytes(&dataBytes, length:self.length)
        var hexString = dataBytes.reduce(""){(out:String, dataByte:Byte) in
            out +  NSString(format:"%02lx", dataByte)
        }
        return hexString
    }
    
}

// MARK: - Serializable Protocol
/*
protocol Serializable {}
typealias SelfType
class func fromString(data:String) -> SelfType?

class func deserialize(data:NSData) -> SelfType
class func deserialize(data:NSData, start:Int) -> SelfType

class func deserializeFromLittleEndian(data:NSData) -> SelfType
class func deserializeArrayFromLittleEndian(data:NSData) -> [SelfType]
class func deserializeFromLittleEndian(data:NSData, start:Int) -> SelfType

class func deserializeFromBigEndian(data:NSData) -> SelfType
class func deserializeArrayFromBigEndian(data:NSData) -> [SelfType]
class func deserializeFromBigEndian(data:NSData, start:Int) -> SelfType

class func serialize<SerializedType>(value:SerializedType) -> NSData
class func serializeArray<SerializedType>(values:[SerializedType]) -> NSData

class func serializeToLittleEndian<SerializedType>(value:SerializedType) -> NSData
class func serializeArrayToLittleEndian<SerializedType>(values:[SerializedType]) -> NSData
class func serializeArrayPairToLittleEndian<SerializedType1, SerializedType2>(values:([SerializedType1], [SerializedType2])) -> NSData

class func serializeToBigEndian<SerializedType>(value:SerializedType) -> NSData
class func serializeArrayToBigEndian<SerializedType>(values:[SerializedType]) -> NSData
class func serializeArrayPairToBigEndian<SerializedType1, SerializedType2>(values:([SerializedType1], [SerializedType2])) -> NSData
}
//}
*/
// MARK: - Deserializable Protocol


/*
public static func deserializeArrayFromBigEndian(data:NSData) -> [Int16] {
let size = sizeof(Int16)
let count = data.length/size
return [Int](0..<count).map{self.deserializeFromBigEndian(data, start:$0*size)}
}

// MARK: - UInt8

extension UInt8 : Deserializable {
    
    public static func fromString(data:String) -> UInt8? {
        if let intVal = data.toInt() {
            if intVal > 255 {
                return Byte(255)
            } else if intVal < 0 {
                return Byte(0)
            } else {
                return Byte(intVal)
            }
        } else {
            return nil
        }
    }
    
    public static func deserialize(data:NSData) -> UInt8 {
        var value : Byte = 0
        if data.length >= sizeof(UInt8) {
            data.getBytes(&value, length:sizeof(Byte))
        }
        return value
    }
    
    public static func deserialize(data:NSData, start:Int) -> UInt8 {
        var value : Byte = 0
        if data.length >= start + sizeof(UInt8) {
            data.getBytes(&value, range: NSMakeRange(start, sizeof(UInt8)))
        }
        return value
    }
    
    public static func deserializeFromLittleEndian(data:NSData) -> UInt8 {
        return deserialize(data)
    }
    
    public static func deserializeArrayFromLittleEndian(data:NSData) -> [UInt8] {
        let count = data.length / sizeof(Byte)
        return [Int](0..<count).map{self.deserializeFromLittleEndian(data, start:$0)}
    }
    
    public static func deserializeFromLittleEndian(data:NSData, start:Int) -> UInt8 {
        return deserialize(data, start:start)
    }
    
    public static func deserializeFromBigEndian(data:NSData) -> UInt8 {
        return deserialize(data)
    }
    
    public static func deserializeArrayFromBigEndian(data:NSData) -> [UInt8] {
        let count = data.length / sizeof(Byte)
        return [Int](0..<count).map{self.deserializeFromBigEndian(data, start:$0)}
    }
    
    public static func deserializeFromBigEndian(data:NSData, start:Int) -> UInt8 {
        return deserialize(data, start:start)
    }
    
}*/
/*extension Int16: Serializable {} // Short
extension UInt16: Serializable {} // UnsignedShort*/
/*extension Float: Deserializable {

    public static func deserialize<Float>(data: NSData, start: Int? = 0) -> Float {
        var value: Float = 0.0
        let size = sizeof(Float)
        let offset = (start ?? 0) * size
        if data.length >= (offset + size) {
            data.getBytes(&value, range: NSMakeRange(offset, size))
        }
        return value
    }

    public static func deserializeFromArray<SerializedType>(data: NSData) -> [Float] {
        let size = sizeof(Float)
        let count = data.length/size
        return [Float](0..<count).map { Float.deserialize(data, start:$0*size) }
    }
}*/
/*extension Double: Serializable {} // Float64*/

enum SerializableType {
    case Float32(Float)
    case Float64(Double)
    
    func deserializeFloat32() -> Float {
        switch self {
        case .Float32(let value):
            return value
        default:
            return 0.0
        }
    }
    
    func deserializeFloat64() -> Double {
        switch self {
        case .Float64(let value):
            return value
        default:
            return 0.0
        }
    }
}
