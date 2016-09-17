//
//  ComponentDataType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* WebGL component datatypes.  Components are intrinsics,
* which form attributes, which form vertices.
*
* @alias ComponentDatatype
*/

import Metal

enum ComponentDatatype {
    /**
    * 8-bit signed byte corresponding to <code>gl.BYTE</code> and the type
    * of an element in <code>Int8Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1400
    */
    case byte,
    
    /**
    * 8-bit unsigned byte corresponding to <code>UNSIGNED_BYTE</code> and the type
    * of an element in <code>Uint8Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1401
    */
    unsignedByte,
    
    /**
    * 16-bit signed short corresponding to <code>SHORT</code> and the type
    * of an element in <code>Int16Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1402
    */
    short,
    
    /**
    * 16-bit unsigned short corresponding to <code>UNSIGNED_SHORT</code> and the type
    * of an element in <code>Uint16Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1403
    */
    unsignedShort,
    
    unsignedInt,
    
    /**
    * 32-bit floating-point corresponding to <code>FLOAT</code> and the type
    * of an element in <code>Float32Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1406
    */
    float32,
    
    /**
    * 64-bit floating-point corresponding to <code>gl.DOUBLE</code> (in Desktop OpenGL;
    * this is not supported in WebGL, and is emulated in Cesium via {@link GeometryPipeline.encodeAttribute})
    * and the type of an element in <code>Float64Array</code>.
    *
    * @memberOf ComponentDatatype
    *
    * @type {Number}
    * @constant
    * @default 0x140A
    */
    float64
    
    /**
    * Returns the size, in bytes, of the corresponding datatype.
    *
    * @param {ComponentDatatype} componentDatatype The component datatype to get the size of.
    * @returns {Number} The size in bytes.
    *
    * @exception {DeveloperError} componentDatatype is not a valid value.
    *
    * @example
    * // Returns Int8Array.BYTES_PER_ELEMENT
    * var size = Cesium.ComponentDatatype.getSizeInBytes(Cesium.ComponentDatatype.BYTE);
    */
    var elementSize: Int {
        switch (self) {
        case .byte:
            return MemoryLayout<Int8>.size
        case .unsignedByte:
            return MemoryLayout<UInt8>.size
        case .short:
            return MemoryLayout<Int16>.size
        case .unsignedShort:
            return MemoryLayout<UInt16>.size
        case .unsignedInt:
            return MemoryLayout<UInt32>.size
        case .float32:
            return MemoryLayout<Float>.size
        case .float64:
            return MemoryLayout<Double>.size
        }
    }
    
    func toVertexType (_ attributeCount: Int) -> VertexType {
        var metalIndex: UInt = 0
        let attributeCount: UInt = UInt(attributeCount)
        switch (self) {
        case .byte:
            metalIndex = VertexType.char2.rawValue + attributeCount > 2 ? UInt(attributeCount-2) : 0
        case .unsignedByte:
            metalIndex = VertexType.uChar2.rawValue  + (attributeCount > 2 ? UInt(attributeCount-2) : 0)
        case .short:
            metalIndex = VertexType.short2.rawValue + (attributeCount > 2 ? UInt(attributeCount-2) : 0)
        case .unsignedShort:
            metalIndex = VertexType.uShort2.rawValue + (attributeCount > 2 ? UInt(attributeCount-2) : 0)
        case .unsignedInt:
            metalIndex = VertexType.uInt.rawValue + (attributeCount > 1 ? UInt(attributeCount-1) : 0)
        case .float32:
            metalIndex = VertexType.float.rawValue + (attributeCount > 1 ? UInt(attributeCount-1) : 0)
        case .float64:
            metalIndex = VertexType.float.rawValue + (attributeCount > 1 ? UInt(attributeCount-1) : 0)
        }
        return VertexType(rawValue: metalIndex) ?? .invalid
    }
    
    func toMTLIndexType () -> MTLIndexType {
        switch (self) {
        case .unsignedShort:
            return .uint16
        case .unsignedInt:
            return .uint32
        default:
            assertionFailure("invalid type for indices")
            return .uint16
        }
    }
    
}

