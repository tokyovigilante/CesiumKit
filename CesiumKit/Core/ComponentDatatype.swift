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

enum ComponentDatatype {
    /**
    * 8-bit signed byte corresponding to <code>gl.BYTE</code> and the type
    * of an element in <code>Int8Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1400
    */
    case Byte,
    
    /**
    * 8-bit unsigned byte corresponding to <code>UNSIGNED_BYTE</code> and the type
    * of an element in <code>Uint8Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1401
    */
    UnsignedByte,
    
    /**
    * 16-bit signed short corresponding to <code>SHORT</code> and the type
    * of an element in <code>Int16Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1402
    */
    Short,
    
    /**
    * 16-bit unsigned short corresponding to <code>UNSIGNED_SHORT</code> and the type
    * of an element in <code>Uint16Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1403
    */
    UnsignedShort,
    
    UnsignedInt,
    
    /**
    * 32-bit floating-point corresponding to <code>FLOAT</code> and the type
    * of an element in <code>Float32Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1406
    */
    Float32,
    
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
    Float64
    
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
        case .Byte:
            return sizeof(Int8)
        case .UnsignedByte:
            return sizeof(UInt8)
        case .Short:
            return sizeof(Int16)
        case .UnsignedShort:
            return sizeof(UInt16)
        case .UnsignedInt:
            return sizeof(UInt32)
        case .Float32:
            return sizeof(Float)
        case .Float64:
            return sizeof(Double)
        }
    }
    
    func toVertexType (attributeCount: Int) -> VertexType {
        var metalIndex: UInt = 0
        switch (self) {
        case .Byte:
            metalIndex = VertexType.Char2.rawValue + (attributeCount > 2 ? UInt(attributeCount-2) : 0)
        case .UnsignedByte:
            metalIndex = VertexType.UChar2.rawValue  + (attributeCount > 2 ? UInt(attributeCount-2) : 0)
        case .Short:
            metalIndex = VertexType.Short2.rawValue + (attributeCount > 2 ? UInt(attributeCount-2) : 0)
        case .UnsignedShort:
            metalIndex = VertexType.UShort2.rawValue + (attributeCount > 2 ? UInt(attributeCount-2) : 0)
        case .UnsignedInt:
            metalIndex = VertexType.UInt.rawValue + (attributeCount > 1 ? UInt(attributeCount-1) : 0)
        case .Float32:
            metalIndex = VertexType.Float.rawValue + (attributeCount > 1 ? UInt(attributeCount-1) : 0)
        case .Float64:
            metalIndex = VertexType.Float.rawValue + (attributeCount > 1 ? UInt(attributeCount-1) : 0)
        }
        return VertexType(rawValue: metalIndex) ?? .Invalid
    }
    
}

