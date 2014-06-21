//
//  ComponentDataType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

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
    case Byte = 0x1400,
    
    /**
    * 8-bit unsigned byte corresponding to <code>UNSIGNED_BYTE</code> and the type
    * of an element in <code>Uint8Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1401
    */
    UnsignedByte = 0x1401,
    
    /**
    * 16-bit signed short corresponding to <code>SHORT</code> and the type
    * of an element in <code>Int16Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1402
    */
    Short = 0x1402,
    
    /**
    * 16-bit unsigned short corresponding to <code>UNSIGNED_SHORT</code> and the type
    * of an element in <code>Uint16Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1403
    */
    UnsignedShort = 0x1403,
    
    /**
    * 32-bit floating-point corresponding to <code>FLOAT</code> and the type
    * of an element in <code>Float32Array</code>.
    *
    * @type {Number}
    * @constant
    * @default 0x1406
    */
    Float = 0x1406,
    
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
    Double = 0x140A
    
    
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
    func getSizeInBytes() {
        
        switch (self) {
        case ComponentDatatype.Byte:
            return sizeof(Int8)
        case ComponentDatatype.UnsignedByte:
            return sizeof(UInt8)
        case ComponentDatatype.Short:
            return sizeof(Int16)
        case ComponentDatatype.UnsignedShort:
            return sizeof(UInt16)
        case ComponentDatatype.Float:
            return sizeof(Float32)
        case ComponentDatatype.Double:
            return sizeof(Double)
        default:
            assert("Invalid componentDataType")
        }
    }
    
    /**
    * Gets the ComponentDatatype for the provided TypedArray instance.
    *
    * @param {TypedArray} array The typed array.
    * @returns {ComponentDatatype} The ComponentDatatype for the provided array, or undefined if the array is not a TypedArray.
    */
    static func fromTypedArray(array) -> ComponentDatatype {
        if array is Int8[] {
            return ComponentDatatype.Byte
        }
        if array is Uint8[] {
            return ComponentDatatype.UnsignedByte
        }
        if array is Int16[] {
            return ComponentDatatype.Short
        }
        if array is Uint16[] {
            return ComponentDatatype.UnsignedShort
        }
        if array is Float32[] {
            return ComponentDatatype.Float32
        }
        if array is Double[] {
            return ComponentDatatype.Double
        }
    }
    
    func getType<T>() -> T {
        switch (self) {
        case ComponentDatatype.Byte:
            return Int8.dynamicType
        case ComponentDatatype.UnsignedByte:
            return UInt8.dynamicType
        case ComponentDatatype.Short:
            return Int16.dynamicType
        case ComponentDatatype.UnsignedShort:
            return UInt16.dynamicType
        case ComponentDatatype.Float:
            return Float32.dynamicType
        case ComponentDatatype.Double:
            return Double.dynamicType
        }
    }
    
    /**
    * Creates a typed array corresponding to component data type.
    *
    * @param {ComponentDatatype} componentDatatype The component data type.
    * @param {Number|Array} valuesOrLength The length of the array to create or an array.
    * @returns {Int8Array|Uint8Array|Int16Array|Uint16Array|Float32Array|Float64Array} A typed array.
    *
    * @exception {DeveloperError} componentDatatype is not a valid value.
    *
    * @example
    * // creates a Float32Array with length of 100
    * var typedArray = Cesium.ComponentDatatype.createTypedArray(Cesium.ComponentDatatype.FLOAT, 100);
    */
    func createTypedArray<T>(length: Int) -> T {
        return Array<self.self>(count: length, defaultValue: 0)
    }
    /*
    /**
    * Creates a typed view of an array of bytes.
    *
    * @param {ComponentDatatype} componentDatatype The type of the view to create.
    * @param {ArrayBuffer} buffer The buffer storage to use for the view.
    * @param {Number} [byteOffset] The offset, in bytes, to the first element in the view.
    * @param {Number} [length] The number of elements in the view.
    * @returns {Int8Array|Uint8Array|Int16Array|Uint16Array|Float32Array|Float64Array} A typed array view of the buffer.
    *
    * @exception {DeveloperError} componentDatatype is not a valid value.
    */
    ComponentDatatype.createArrayBufferView = function(componentDatatype, buffer, byteOffset, length) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(componentDatatype)) {
    throw new DeveloperError('componentDatatype is required.');
    }
    if (!defined(buffer)) {
    throw new DeveloperError('buffer is required.');
    }
    //>>includeEnd('debug');
    
    byteOffset = defaultValue(byteOffset, 0);
    length = defaultValue(length, (buffer.byteLength - byteOffset) / ComponentDatatype.getSizeInBytes(componentDatatype));
    
    switch (componentDatatype) {
    case ComponentDatatype.BYTE:
    return new Int8Array(buffer, byteOffset, length);
    case ComponentDatatype.UNSIGNED_BYTE:
    return new Uint8Array(buffer, byteOffset, length);
    case ComponentDatatype.SHORT:
    return new Int16Array(buffer, byteOffset, length);
    case ComponentDatatype.UNSIGNED_SHORT:
    return new Uint16Array(buffer, byteOffset, length);
    case ComponentDatatype.FLOAT:
    return new Float32Array(buffer, byteOffset, length);
    case ComponentDatatype.DOUBLE:
    return new Float64Array(buffer, byteOffset, length);
    default:
    throw new DeveloperError('componentDatatype is not a valid value.');
    }
    }*/
}