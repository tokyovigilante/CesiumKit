//
//  Cartesian4.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A 4D Cartesian point.
* @alias Cartesian4
* @constructor
*
* @param {Number} [x=0.0] The X component.
* @param {Number} [y=0.0] The Y component.
* @param {Number} [z=0.0] The Z component.
* @param {Number} [w=0.0] The W component.
*
* @see Cartesian2
* @see Cartesian3
* @see Packable
*/
struct Cartesian4: Packable {
    /**
    * The X component.
    * @type {Number}
    * @default 0.0
    */
    var x: Double = 0.0
    
    /**
    * The Y component.
    * @type {Number}
    * @default 0.0
    */
    var y: Double = 0.0
    
    /**
    * The Z component.
    * @type {Number}
    * @default 0.0
    */
    var z: Double = 0.0
    
    /**
    * The W component.
    * @type {Number}
    * @default 0.0
    */
    var w: Double = 0.0
    
    /**
    * The number of elements used to pack the object into an array.
    * @type {Number}
    */
    static let packedLength: Int = 4
    
    /**
    * Stores the provided instance into the provided array.
    *
    * @param {Cartesian4} value The value to pack.
    * @param {Number[]} array The array to pack into.
    * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
    */
    func pack(inout array: Float[], startingIndex: Int)
    {
        /*
        //>>includeStart('debug', pragmas.debug);
        if (!defined(value)) {
            throw new DeveloperError('value is required');
        }
        
        if (!defined(array)) {
            throw new DeveloperError('array is required');
        }
        //>>includeEnd('debug');
        
        startingIndex = defaultValue(startingIndex, 0);
        
        array[startingIndex++] = value.x;
        array[startingIndex++] = value.y;
        array[startingIndex++] = value.z;
        array[startingIndex] = value.w;*/
    }

    /**
    * Retrieves an instance from a packed array.
    *
    * @param {Number[]} array The packed array.
    * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
    * @param {Cartesian4} [result] The object into which to store the result.
    */
    static func unpack(array: Float[], startingIndex: Int) -> Cartesian4 {
    /*
        //>>includeStart('debug', pragmas.debug);
        if (!defined(array)) {
            throw new DeveloperError('array is required');
        }
        //>>includeEnd('debug');
        
        startingIndex = defaultValue(startingIndex, 0);
        
        if (!defined(result)) {
            result = new Cartesian4();
        }
        result.x = array[startingIndex++];
        result.y = array[startingIndex++];
        result.z = array[startingIndex++];
        result.w = array[startingIndex];
        return result;
        */
        return Cartesian4()
    }
}



