//
//  CSTypedArray
//  CesiumKit
//
//  Created by Ryan Walklin on 24/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSTypedArray.h"

@interface CSTypedArray () {
    
    void *bytes;
    UInt32 length;
}

@property (readonly) BOOL is32Bit;

@end

@implementation CSTypedArray

/**
 * Returns the size, in bytes, of the corresponding datatype.
 *
 * @param {IndexDatatype} indexDatatype The index datatype to get the size of.
 *
 * @returns {Number} The size in bytes.
 *
 * @example
 * // Returns 2
 * var size = Cesium.IndexDatatype.getSizeInBytes(Cesium.IndexDatatype.UNSIGNED_SHORT);
 *
IndexDatatype.getSizeInBytes = function(indexDatatype)
{
    if (self.is3)
    switch(indexDatatype) {
        case IndexDatatype.UNSIGNED_BYTE:
            return Uint8Array.BYTES_PER_ELEMENT;
        case IndexDatatype.UNSIGNED_SHORT:
            return Uint16Array.BYTES_PER_ELEMENT;
        case IndexDatatype.UNSIGNED_INT:
            return Uint32Array.BYTES_PER_ELEMENT;
    }
    
    //>>includeStart('debug', pragmas.debug);
    throw new DeveloperError('indexDatatype is required and must be a valid IndexDatatype constant.');
    //>>includeEnd('debug');
};

/**
 * Validates that the provided index datatype is a valid {@link IndexDatatype}.
 *
 * @param {IndexDatatype} indexDatatype The index datatype to validate.
 *
 * @returns {Boolean} <code>true</code> if the provided index datatype is a valid value; otherwise, <code>false</code>.
 *
 * @example
 * if (!Cesium.IndexDatatype.validate(indexDatatype)) {
 *   throw new Cesium.DeveloperError('indexDatatype must be a valid value.');
 * }
 *
IndexDatatype.validate = function(indexDatatype) {
    return defined(indexDatatype) &&
    (indexDatatype === IndexDatatype.UNSIGNED_BYTE ||
     indexDatatype === IndexDatatype.UNSIGNED_SHORT ||
     indexDatatype === IndexDatatype.UNSIGNED_INT);
};

/**
 * Creates a typed array that will store indices, using either <code><Uint16Array</code>
 * or <code>Uint32Array</code> depending on the number of vertices.
 *
 * @param {Number} numberOfVertices Number of vertices that the indices will reference.
 * @param {Any} indicesLengthOrArray Passed through to the typed array constructor.
 *
 * @returns {Uint16Aray|Uint32Array} A <code>Uint16Array</code> or <code>Uint32Array</code> constructed with <code>indicesLengthOrArray</code>.
 *
 * @example
 * this.indices = Cesium.IndexDatatype.createTypedArray(positions.length / 3, numberOfIndices);
 *
IndexDatatype.createTypedArray = function(numberOfVertices, indicesLengthOrArray) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(numberOfVertices)) {
        throw new DeveloperError('numberOfVertices is required.');
    }
    //>>includeEnd('debug');
    
    if (numberOfVertices > CesiumMath.SIXTY_FOUR_KILOBYTES) {
        return new Uint32Array(indicesLengthOrArray);
    }
    
    return new Uint16Array(indicesLengthOrArray);
};

return IndexDatatype;


-(void)dealloc
{
    
}*/

@end
