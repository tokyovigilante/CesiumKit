//
//  SerializableArray.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/*class SerializableArray: Printable {
    
    private let _storageBuffer: NSMutableData
    
    let datatype: ComponentDatatype
    
    var byteLength: Int {
        get {
            return _storageBuffer.length
        }
    }
    
    var count: Int {
        get {
            return _storageBuffer.length / datatype.elementSize()
        }
    }
    
    init(count: Int, type: ComponentDatatype) {
        _storageBuffer = NSMutableData(length: count * type.elementSize())
        datatype = type
    }
    
    init(array: [Serializable], type: ComponentDatatype) {
        
        datatype = type
        _storageBuffer = NSMutableData(bytes:array, length:array.count * type.elementSize())
    }
    
    subscript(index: Int) -> Int {
        get {
            // return an appropriate subscript value here
            data.getBytes(&value, range: NSMakeRange(start, sizeof(UInt8)))
        }
        set(newValue) {
            // perform a suitable setting action here
        }
    }
    
    func description () -> String {
        return "\(count) objects"
    }*/
    

public protocol Serialized {
    class func serialize<SerializedType>(value:SerializedType) -> NSData
    class func serializeArray<SerializedType>(values:[SerializedType]) -> NSData
    
}

extension NSData : Serialized {
    
    public class func serialize<SerializedType>(value:SerializedType) -> NSData {
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

/*protocol Serializable {}
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
}*/
//}
// MARK: - Serializable Protocol

protocol Serializable {}

extension Int8: Serializable {} // Byte
extension UInt8: Serializable {} // UnsignedByte
extension Int16: Serializable {} // Short
extension UInt16: Serializable {} // UnsignedShort
extension Float: Serializable {} // Float32
extension Double: Serializable {} // Float64


/*    public static func fromString(data:String) -> Int8? {
        if let intVal = data.toInt() {
            if intVal > 127 {
                return Int8(127)
            } else if intVal < -128 {
                return Int8(-128)
            }
            return Int8(intVal)
        } else {
            return nil
        }
    }
    
    public static func deserialize(data:NSData) -> Int8 {
        var value : Int8 = 0
        if data.length >= sizeof(Int8) {
            data.getBytes(&value, length:sizeof(Int8))
        }
        return value
    }
    
    public static func deserialize(data:NSData, start:Int) -> Int8 {
        var value : Int8 = 0
        if data.length >= start + sizeof(Int8) {
            data.getBytes(&value, range: NSMakeRange(start, sizeof(Int8)))
        }
        return value
    }
    
    public static func deserializeFromLittleEndian(data:NSData) -> Int8 {
        return deserialize(data)
    }
    
    public static func deserializeArrayFromLittleEndian(data:NSData) -> [Int8] {
        let count = data.length / sizeof(Int8)
        return [Int](0..<count).map{self.deserializeFromLittleEndian(data, start:$0)}
    }
    
    public static func deserializeFromLittleEndian(data:NSData, start:Int) -> Int8 {
        return deserialize(data, start:start)
    }
    
    public static func deserializeFromBigEndian(data:NSData) -> Int8 {
        return deserialize(data)
    }
    
    public static func deserializeArrayFromBigEndian(data:NSData) -> [Int8] {
        let count = data.length / sizeof(Int8)
        return [Int](0..<count).map{self.deserializeFromBigEndian(data, start:$0)}
    }
    
    public static func deserializeFromBigEndian(data:NSData, start:Int) -> Int8 {
        return deserialize(data, start:start)
    }
    
}*/