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
    static func packedLength () -> Int
    
    init (array: [Double], startingIndex: Int)

    /**
    * Stores the provided instance into the provided array.
    * @function
    *
    * @param {Object} value The value to pack.
    * @param {Number[]} array The array to pack into.
    */
    func pack (_ array: inout [Float], startingIndex: Int)
    
    func toArray () -> [Double]
   
    /**
    * Retrieves an instance from a packed array.
    * @function
    *
    * @param {Number[]} array The packed array.
    * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
    * @param {Object} [result] The object into which to store the result.
    */
    static func unpack(_ array: [Float], startingIndex: Int) -> Self
    
    func checkPackedArrayLength(_ array: [Double], startingIndex: Int) -> Bool
}

extension Packable {
    
    /**
     * Stores the provided instance into the provided array.
     *
     * @param {Matrix3} value The value to pack.
     * @param {Number[]} array The array to pack into.
     * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
     */
    func pack(_ array: inout [Float], startingIndex: Int = 0) {
        
        let doubleArray = self.toArray()
        
        //let floatArray = self.toArray().map { Float($0) }
        //let fs = strideof(Float)
        //let arrayLength = array.count
        assert(array.count >= startingIndex + Self.packedLength(), "short array")

        //var grid = [Double](count: packedLength, repeatedValue: 0.0)
        /*array.withUnsafeMutableBufferPointer { (inout pointer: UnsafeMutableBufferPointer<Float>) in
            memcpy(pointer.baseAddress+startingIndex*fs, floatArray, floatArray.count*fs)
        }*/
        /*
        if array.count < startingIndex + Self.packedLength() {
            for i in doubleArray.indices {
                array.append(Float(array[i]))
            }
            //array.appendContentsOf(floatArray)
        } else {*/
            for i in doubleArray.indices {

                array[startingIndex+i] = Float(doubleArray[i])
            }
            //array.replaceRange(Range(start: startingIndex, end: startingIndex+floatArray.count), with: floatArray)
        /*}*/
    }
    
    /**
     * Creates an Array from the provided Matrix3 instance.
     * The array will be in column-major order.
     *
     * @param {Matrix3} matrix The matrix to use..
     * @param {Number[]} [result] The Array onto which to store the result.
     * @returns {Number[]} The modified Array parameter or a new Array instance if one was not provided.
     */
    func toArray() -> [Double] {
        let packedLength = Self.packedLength()
        var grid = [Double](repeating: 0.0, count: packedLength)
        memcpy(&grid, [self], packedLength * strideof(Double))
        /*grid.withUnsafeMutableBufferPointer { (inout pointer: UnsafeMutableBufferPointer<Double>) in
            memcpy(pointer.baseAddress, [self], packedLength * strideof(Double))
        }*/
        return grid
    }
    
    /**
     * Retrieves an instance from a packed array.
     *
     * @param {Number[]} array The packed array.
     * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
     * @param {Matrix3} [result] The object into which to store the result.
     */
    static func unpack(_ array: [Float], startingIndex: Int = 0) -> Self {
        return Self(array: array.map { Double($0) }, startingIndex: startingIndex)
    }
    
    func checkPackedArrayLength(_ array: [Double], startingIndex: Int) -> Bool {
        return array.count - startingIndex >= Self.packedLength()
    }
    
}


