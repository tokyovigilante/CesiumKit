//
//  Packable.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* Static interface for types which can store their values as packed
* elements in an array.  These methods and properties are expected to be
* defined on a constructor function.
*
* @exports Packable
*
* @see PackableForInterpolation
*/
protocol Packable {
    /**
    * The number of elements used to pack the object into an array.
    * @type {Number}
    */
    //static let packedLength: Int
    
    /**
    * Stores the provided instance into the provided array.
    * @function
    *
    * @param {Object} value The value to pack.
    * @param {Number[]} array The array to pack into.
    */
    func pack(inout array: [Float], startingIndex: Int)
   
    /**
    * Retrieves an instance from a packed array.
    * @function
    *
    * @param {Number[]} array The packed array.
    * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
    * @param {Object} [result] The object into which to store the result.
    */
    static func unpack(array: [Float], startingIndex: Int) -> Self
}


