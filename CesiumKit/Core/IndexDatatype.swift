//
//  IndexDatatype.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

/**
* Constants for WebGL index datatypes.  These corresponds to the
* <code>type</code> parameter of {@link http://www.khronos.org/opengles/sdk/docs/man/xhtml/glDrawElements.xml|drawElements}.
*
* @namespace
* @alias IndexDatatype
*/
enum IndexDatatype {
    /**
    * 0x1401.  8-bit unsigned byte corresponding to <code>UNSIGNED_BYTE</code> and the type
    * of an element in <code>Uint8Array</code>.
    *
    * @type {Number}
    * @constant
    */
    case UnsignedByte,
    
    /**
    * 0x1403.  16-bit unsigned short corresponding to <code>UNSIGNED_SHORT</code> and the type
    * of an element in <code>Uint16Array</code>.
    *
    * @type {Number}
    * @constant
    */
    UnsignedShort,
    
    /**
    * 0x1405.  32-bit unsigned int corresponding to <code>UNSIGNED_INT</code> and the type
    * of an element in <code>Uint32Array</code>.
    *
    * @type {Number}
    * @constant
    */
    UnsignedInt
    
    func toGL() -> GLenum {
        switch (self) {
        case .UnsignedByte:
            return 0x1401
        case .UnsignedShort:
            return 0x1403
        case .UnsignedInt:
            return 0x1405
        }
    }
    
    /**
    * Returns the size, in bytes, of the corresponding datatype.
    *
    * @param {IndexDatatype} indexDatatype The index datatype to get the size of.
    * @returns {Number} The size in bytes.
    *
    * @example
    * // Returns 2
    * var size = Cesium.IndexDatatype.getSizeInBytes(Cesium.IndexDatatype.UNSIGNED_SHORT);
    */
    func elementSize() -> Int {
        
        switch (self) {
        case .UnsignedByte:
            return sizeof(UInt8)
        case .UnsignedShort:
            return sizeof(UInt16)
        case .UnsignedInt:
            return sizeof(UInt32)
        }
    }
    
    /**
    * Creates a typed array that will store indices, using either <code><Uint16Array</code>
    * or <code>Uint32Array</code> depending on the number of vertices.
    *
    * @param {Number} numberOfVertices Number of vertices that the indices will reference.
    * @param {Any} indicesLengthOrArray Passed through to the typed array constructor.
    * @returns {Uint16Aray|Uint32Array} A <code>Uint16Array</code> or <code>Uint32Array</code> constructed with <code>indicesLengthOrArray</code>.
    *
    * @example
    * this.indices = Cesium.IndexDatatype.createTypedArray(positions.length / 3, numberOfIndices);
    */
    /*func typedArray(numberOfVertices: Int, indicesLength: Int?, array: SerializedArray?) -> SerializedArray {
        
    /*if (numberOfVertices > Math.SixtyFourKilobytes) {
    return new Uint32Array(indicesLengthOrArray);
    }
    
    return new Uint16Array(indicesLengthOrArray);
    };
    
    /**
    * Creates a typed array from a source array buffer.  The resulting typed array will store indices, using either <code><Uint16Array</code>
    * or <code>Uint32Array</code> depending on the number of vertices.
    *
    * @param {Number} numberOfVertices Number of vertices that the indices will reference.
    * @param {ArrayBuffer} sourceArray Passed through to the typed array constructor.
    * @param {byteOffset} byteOffset Passed through to the typed array constructor.
    * @param {length} length Passed through to the typed array constructor.
    * @returns {Uint16Aray|Uint32Array} A <code>Uint16Array</code> or <code>Uint32Array</code> constructed with <code>sourceArray</code>, <code>byteOffset</code>, and <code>length</code>.
    *
    */
    IndexDatatype.createTypedArrayFromArrayBuffer = function(numberOfVertices, sourceArray, byteOffset, length) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(numberOfVertices)) {
    throw new DeveloperError('numberOfVertices is required.');
    }
    if (!defined(sourceArray)) {
    throw new DeveloperError('sourceArray is required.');
    }
    if (!defined(byteOffset)) {
    throw new DeveloperError('byteOffset is required.');
    }
    //>>includeEnd('debug');
    
    if (numberOfVertices > CesiumMath.SIXTY_FOUR_KILOBYTES) {
    return new Uint32Array(sourceArray, byteOffset, length);
    }
    
    return new Uint16Array(sourceArray, byteOffset, length);
    };
    
    return freezeObject(IndexDatatype);
    });*/return SerializedArray()
    }*/

}