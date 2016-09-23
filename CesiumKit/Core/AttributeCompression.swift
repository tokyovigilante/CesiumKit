//
//  AttributeCompression.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 4/10/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation


/**
* Attribute compression and decompression functions.
*
* @namespace
* @alias AttributeCompression
*
* @private
*/
class AttributeCompression {
    
    /**
     * Encodes a normalized vector into 2 SNORM values in the range of [0-255] following the 'oct' encoding.
     *
     * Oct encoding is a compact representation of unit length vectors.  The encoding and decoding functions are low cost, and represent the normalized vector within 1 degree of error.
     * The 'oct' encoding is described in "A Survey of Efficient Representations of Independent Unit Vectors",
     * Cigolle et al 2014: {@link http://jcgt.org/published/0003/02/01/}
     *
     * @param {Cartesian3} vector The normalized vector to be compressed into 2 byte 'oct' encoding.
     * @param {Cartesian2} result The 2 byte oct-encoded unit length vector.
     * @returns {Cartesian2} The 2 byte oct-encoded unit length vector.
     *
     * @exception {DeveloperError} vector must be defined.
     * @exception {DeveloperError} result must be defined.
     * @exception {DeveloperError} vector must be normalized.
     *
     * @see AttributeCompression.octDecode
     */
    class func octEncode (_ vector: Cartesian3) -> Cartesian2 {
        
        let magSquared = vector.magnitudeSquared
        assert(abs(magSquared - 1.0) <= Math.Epsilon6, "vector must be normalized.")
        
        var result = Cartesian2()
        
        result.x = vector.x / (abs(vector.x) + abs(vector.y) + abs(vector.z))
        result.y = vector.y / (abs(vector.x) + abs(vector.y) + abs(vector.z))
        if (vector.z < 0) {
            let x = result.x
            let y = result.y
            result.x = (1.0 - abs(y)) * Double(Math.signNotZero(x))
            result.y = (1.0 - abs(x)) * Double(Math.signNotZero(y))
        }
        
        result.x = Double(Math.toSNorm(result.x))
        result.y = Double(Math.toSNorm(result.y))
        
        return result
    }

    /**
     * Decodes a unit-length vector in 'oct' encoding to a normalized 3-component vector.
     *
     * @param {Number} x The x component of the oct-encoded unit length vector.
     * @param {Number} y The y component of the oct-encoded unit length vector.
     * @param {Cartesian3} result The decoded and normalized vector
     * @returns {Cartesian3} The decoded and normalized vector.
     *
     * @exception {DeveloperError} result must be defined.
     * @exception {DeveloperError} x and y must be a signed normalized integer between 0 and 255.
     *
     * @see AttributeCompression.octEncode
     */
    class func octDecode (x: UInt8, y: UInt8) -> Cartesian3 {
        
        assert(x >= 0 && x <= 255 && y >= 0 && y <= 255, "x and y must be a signed normalized integer between 0 and 255")
        
        var result = Cartesian3()
        result.x = Math.fromSNorm(x)
        result.y = Math.fromSNorm(y)
        result.z = 1.0 - (abs(result.x) + abs(result.y))
        
        if (result.z < 0.0)
        {
            let oldVX = result.x
            result.x = (1.0 - abs(result.y)) * Double(Math.signNotZero(oldVX))
            result.y = (1.0 - abs(oldVX)) * Double(Math.signNotZero(result.y))
        }
        
        return result.normalize()
    }

    /**
     * Packs an oct encoded vector into a single floating-point number.
     *
     * @param {Cartesian2} encoded The oct encoded vector.
     * @returns {Number} The oct encoded vector packed into a single float.
     *
     * @exception {DeveloperError} encoded is required.
     */
    class func octPackFloat (_ encoded: Cartesian2) -> Float32 {
        return Float(256.0 * encoded.x + encoded.y)
    }
/*
var scratchEncodeCart2 = new Cartesian2();

/**
* Encodes a normalized vector into 2 SNORM values in the range of [0-255] following the 'oct' encoding and
* stores those values in a single float-point number.
*
* @param {Cartesian3} vector The normalized vector to be compressed into 2 byte 'oct' encoding.
* @returns {Number} The 2 byte oct-encoded unit length vector.
*
* @exception {DeveloperError} vector must be defined.
* @exception {DeveloperError} vector must be normalized.
*/
AttributeCompression.octEncodeFloat = function(vector) {
AttributeCompression.octEncode(vector, scratchEncodeCart2);
return AttributeCompression.octPackFloat(scratchEncodeCart2);
};

/**
* Decodes a unit-length vector in 'oct' encoding packed in a floating-point number to a normalized 3-component vector.
*
* @param {Number} value The oct-encoded unit length vector stored as a single floating-point number.
* @param {Cartesian3} result The decoded and normalized vector
* @returns {Cartesian3} The decoded and normalized vector.
*
* @exception {DeveloperError} value must be defined.
* @exception {DeveloperError} result must be defined.
*/
AttributeCompression.octDecodeFloat = function(value, result) {
//>>includeStart('debug', pragmas.debug);
if (!defined(value)) {
throw new DeveloperError('value is required.');
}
//>>includeEnd('debug');

var temp = value / 256.0;
var x = Math.floor(temp);
var y = (temp - x) * 256.0;

return AttributeCompression.octDecode(x, y, result);
};

/**
* Encodes three normalized vectors into 6 SNORM values in the range of [0-255] following the 'oct' encoding and
* packs those into two floating-point numbers.
*
* @param {Cartesian3} v1 A normalized vector to be compressed.
* @param {Cartesian3} v2 A normalized vector to be compressed.
* @param {Cartesian3} v3 A normalized vector to be compressed.
* @param {Cartesian2} result The 'oct' encoded vectors packed into two floating-point numbers.
* @returns {Cartesian2} The 'oct' encoded vectors packed into two floating-point numbers.
*
* @exception {DeveloperError} v1 must be defined.
* @exception {DeveloperError} v2 must be defined.
* @exception {DeveloperError} v3 must be defined.
* @exception {DeveloperError} result must be defined.
*/
AttributeCompression.octPack = function(v1, v2, v3, result) {
//>>includeStart('debug', pragmas.debug);
if (!defined(v1)) {
throw new DeveloperError('v1 is required.');
}
if (!defined(v2)) {
throw new DeveloperError('v2 is required.');
}
if (!defined(v3)) {
throw new DeveloperError('v3 is required.');
}
if (!defined(result)) {
throw new DeveloperError('result is required.');
}
//>>includeEnd('debug');

var encoded1 = AttributeCompression.octEncodeFloat(v1);
var encoded2 = AttributeCompression.octEncodeFloat(v2);

var encoded3 = AttributeCompression.octEncode(v3, scratchEncodeCart2);
result.x = 65536.0 * encoded3.x + encoded1;
result.y = 65536.0 * encoded3.y + encoded2;
return result;
};

/**
* Decodes three unit-length vectors in 'oct' encoding packed into a floating-point number to a normalized 3-component vector.
*
* @param {Cartesian2} packed The three oct-encoded unit length vectors stored as two floating-point number.
* @param {Cartesian3} v1 One decoded and normalized vector.
* @param {Cartesian3} v2 One decoded and normalized vector.
* @param {Cartesian3} v3 One decoded and normalized vector.
*
* @exception {DeveloperError} packed must be defined.
* @exception {DeveloperError} v1 must be defined.
* @exception {DeveloperError} v2 must be defined.
* @exception {DeveloperError} v3 must be defined.
*/
AttributeCompression.octUnpack = function(packed, v1, v2, v3) {
//>>includeStart('debug', pragmas.debug);
if (!defined(packed)) {
throw new DeveloperError('packed is required.');
}
if (!defined(v1)) {
throw new DeveloperError('v1 is required.');
}
if (!defined(v2)) {
throw new DeveloperError('v2 is required.');
}
if (!defined(v3)) {
throw new DeveloperError('v3 is required.');
}
//>>includeEnd('debug');

var temp = packed.x / 65536.0;
var x = Math.floor(temp);
var encodedFloat1 = (temp - x) * 65536.0;

temp = packed.y / 65536.0;
var y = Math.floor(temp);
var encodedFloat2 = (temp - y) * 65536.0;

AttributeCompression.octDecodeFloat(encodedFloat1, v1);
AttributeCompression.octDecodeFloat(encodedFloat2, v2);
AttributeCompression.octDecode(x, y, v3);
};
*/
/**
* Pack texture coordinates into a single float. The texture coordinates will only preserve 12 bits of precision.
*
* @param {Cartesian2} textureCoordinates The texture coordinates to compress
* @returns {Number} The packed texture coordinates.
*
* @exception {DeveloperError} textureCoordinates is required.
*/
    static func compressTextureCoordinates (_ textureCoordinates: Cartesian2) -> Float {
        
        let x = textureCoordinates.x == 1.0 ? 4095.0 : floor(textureCoordinates.x * 4096.0)
        let y = textureCoordinates.y == 1.0 ? 4095.0 : floor(textureCoordinates.y * 4096.0)
        return 4096.0 * Float(x) + Float(y)
    }
    
    /**
     * Decompresses texture coordinates that were packed into a single float.
     *
     * @param {Number} compressed The compressed texture coordinates.
     * @param {Cartesian2} result The decompressed texture coordinates.
     * @returns {Cartesian2} The modified result parameter.
     *
     * @exception {DeveloperError} compressed is required.
     * @exception {DeveloperError} result is required.
     */
    static func decompressTextureCoordinates(_ compressed: Float) -> Cartesian2 {
        let temp = Double(compressed) / 4096.0
        return Cartesian2(
            x: floor(temp) / 4096.0,
            y: temp - floor(temp)
        )
    }

}
