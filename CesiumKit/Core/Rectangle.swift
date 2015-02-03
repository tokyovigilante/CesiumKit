//
//  Rectangle.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A two dimensional region specified as longitude and latitude coordinates.
*
* @alias Rectangle
* @constructor
*
* @param {Number} [west=0.0] The westernmost longitude, in radians, in the range [-Pi, Pi].
* @param {Number} [south=0.0] The southernmost latitude, in radians, in the range [-Pi/2, Pi/2].
* @param {Number} [east=0.0] The easternmost longitude, in radians, in the range [-Pi, Pi].
* @param {Number} [north=0.0] The northernmost latitude, in radians, in the range [-Pi/2, Pi/2].
*
* @see Packable
*/
// FIXME: Packable
public struct Rectangle/*: Packable*/ {
    var west: Double
    var south: Double
    var east: Double
    var north: Double
    
    static var packedLength: Int = 4
    
    init(west: Double = 0.0, south: Double = 0.0, east: Double = 0.0, north: Double = 0.0) {
        self.west = west
        self.south = south
        self.east = east
        self.north = north
    }
    /**
    * Creates an rectangle given the boundary longitude and latitude in degrees.
    *
    * @param {Number} [west=0.0] The westernmost longitude in degrees in the range [-180.0, 180.0].
    * @param {Number} [south=0.0] The southernmost latitude in degrees in the range [-90.0, 90.0].
    * @param {Number} [east=0.0] The easternmost longitude in degrees in the range [-180.0, 180.0].
    * @param {Number} [north=0.0] The northernmost latitude in degrees in the range [-90.0, 90.0].
    * @param {Rectangle} [result] The object onto which to store the result, or undefined if a new instance should be created.
    * @returns {Rectangle} The modified result parameter or a new Rectangle instance if none was provided.
    *
    * @example
    * var rectangle = Cesium.Rectangle.fromDegrees(0.0, 20.0, 10.0, 30.0);
    */
    static func fromDegrees(west: Double = 0.0, south: Double = 0.0, east: Double = 0.0, north: Double = 0.0) -> Rectangle {
        return Rectangle(
            west: Math.toRadians(west),
            south: Math.toRadians(south),
            east: Math.toRadians(east),
            north: Math.toRadians(north))
    }
    
    
    /**
    * Creates the smallest possible Rectangle that encloses all positions in the provided array.
    *
    * @param {Cartographic[]} cartographics The list of Cartographic instances.
    * @param {Rectangle} [result] The object onto which to store the result, or undefined if a new instance should be created.
    * @returns {Rectangle} The modified result parameter or a new Rectangle instance if none was provided.
    */
    static func fromCartographicArray(cartographics: [Cartographic]) -> Rectangle {
        
        var minLon = Double.infinity
        var maxLon = -Double.infinity
        var minLat = Double.infinity
        var maxLat = -Double.infinity
        
        for cartographic in cartographics {
            minLon = min(minLon, cartographic.longitude);
            maxLon = max(maxLon, cartographic.longitude);
            minLat = min(minLat, cartographic.latitude);
            maxLat = max(maxLat, cartographic.latitude);
        }
        return Rectangle(west: minLon, south: minLat, east: maxLon, north: maxLat)
    }
    
    /**
    * Stores the provided instance into the provided array.
    *
    * @param {Rectangle} value The value to pack.
    * @param {Number[]} array The array to pack into.
    * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
    */
    func pack(inout array: [Float], startingIndex: Int = 0)  {
        
        if array.count < startingIndex - Int(Rectangle.packedLength)
        {
            array.append(Float(west))
            array.append(Float(south))
            array.append(Float(east))
            array.append(Float(north))
        }
        array.insert(Float(west), atIndex: startingIndex)
        array.insert(Float(south), atIndex: startingIndex+1)
        array.insert(Float(east), atIndex: startingIndex+2)
        array.insert(Float(north), atIndex: startingIndex+3)
    }
    
    /**
    * Retrieves an instance from a packed array.
    *
    * @param {Number[]} array The packed array.
    * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
    * @param {Rectangle} [result] The object into which to store the result.
    */
    static func unpack(array: [Float32], startingIndex: Int) -> Rectangle {
        assert((startingIndex + packedLength < array.count), "Invalid starting index")
        return Rectangle(
            west: Double(array[startingIndex]),
            south: Double(array[startingIndex+1]),
            east: Double(array[startingIndex+2]),
            north: Double(array[startingIndex+3]))
    }
    
    
    /**
    * Compares the provided rectangles and returns <code>true</code> if they are equal,
    * <code>false</code> otherwise.
    *
    * @param {Rectangle} [left] The first Rectangle.
    * @param {Rectangle} [right] The second Rectangle.
    * @returns {Boolean} <code>true</code> if left and right are equal; otherwise <code>false</code>.
    */
    func equals(other: Rectangle) -> Bool {
        return (west == other.west) && (south == other.south) && (east == other.east) && (north == other.north)
    }
    
    /**
    * Compares the provided Rectangle with this Rectangle componentwise and returns
    * <code>true</code> if they are within the provided epsilon,
    * <code>false</code> otherwise.
    *
    * @param {Rectangle} [other] The Rectangle to compare.
    * @param {Number} epsilon The epsilon to use for equality testing.
    * @returns {Boolean} <code>true</code> if the Rectangles are within the provided epsilon, <code>false</code> otherwise.
    */
    func equalsEpsilon(other: Rectangle, epsilon: Double) -> Bool {
        return abs(west - other.west) <= epsilon &&
            abs(south - other.south) <= epsilon &&
            abs(east - other.east) <= epsilon &&
            abs(north - other.north) <= epsilon
    }
    
    /**
    * Checks an Rectangle's properties and throws if they are not in valid ranges.
    *
    * @param {Rectangle} rectangle The rectangle to validate
    *
    * @exception {DeveloperError} <code>north</code> must be in the interval [<code>-Pi/2</code>, <code>Pi/2</code>].
    * @exception {DeveloperError} <code>south</code> must be in the interval [<code>-Pi/2</code>, <code>Pi/2</code>].
    * @exception {DeveloperError} <code>east</code> must be in the interval [<code>-Pi</code>, <code>Pi</code>].
    * @exception {DeveloperError} <code>west</code> must be in the interval [<code>-Pi</code>, <code>Pi</code>].
    */
    func validate() {
        assert(north > -M_PI_2 && north < M_PI_2, "north must be in the interval [-Pi/2, Pi/2].")
        assert(south > -M_PI_2 && south < M_PI_2, "south must be in the interval [-Pi/2, Pi/2].")
        assert(west > -M_PI && west < M_PI, "west must be in the interval [-Pi, Pi].")
        assert(east > -M_PI && east < M_PI, "east must be in the interval [-Pi, Pi].")
    }
    
    /**
    * Computes the southwest corner of an rectangle.
    *
    * @param {Rectangle} rectangle The rectangle for which to find the corner
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
    */
    func southwest() -> Cartographic {
        return Cartographic(longitude: west, latitude: south, height:0.0)
    }
    
    /**
    * Computes the northwest corner of an rectangle.
    *
    * @param {Rectangle} rectangle The rectangle for which to find the corner
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
    */
    func northwest() -> Cartographic {
        return Cartographic(longitude: west, latitude: north, height:0.0)
    }
    
    
    /**
    * Computes the northeast corner of an rectangle.
    *
    * @param {Rectangle} rectangle The rectangle for which to find the corner
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
    */
    func northeast() -> Cartographic {
        return Cartographic(longitude: east, latitude: north, height:0.0)
    }
    
    
    /**
    * Computes the southeast corner of an rectangle.
    *
    * @param {Rectangle} rectangle The rectangle for which to find the corner
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
    */
    func southeast() -> Cartographic {
        return Cartographic(longitude: east, latitude: south, height:0.0)
    }
    
    /**
    * Computes the center of an rectangle.
    *
    * @param {Rectangle} rectangle The rectangle for which to find the center
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
    */
    func center() -> Cartographic {
        return Cartographic(longitude: (west + east) * 0.5, latitude: (south + north) * 0.5, height:0.0)
    }
    
    /**
    * Computes the intersection of two rectangles
    *
    * @param {Rectangle} rectangle On rectangle to find an intersection
    * @param {Rectangle} otherRectangle Another rectangle to find an intersection
    * @param {Rectangle} [result] The object onto which to store the result.
    * @returns {Rectangle} The modified result parameter or a new Rectangle instance if none was provided.
    */
    func intersectWith(other: Rectangle) -> Rectangle {
        var westIntersect = max(west, other.west)
        var southIntersect = max(south, other.south)
        var eastIntersect = min(east, other.east)
        var northIntersect = min(north, other.north)
        return Rectangle(west: westIntersect, south: southIntersect, east: eastIntersect, north: northIntersect)
    }
    
    /**
    * Returns true if the cartographic is on or inside the rectangle, false otherwise.
    *
    * @param {Rectangle} rectangle The rectangle
    * @param {Cartographic} cartographic The cartographic to test.
    * @returns {Boolean} true if the provided cartographic is inside the rectangle, false otherwise.
    */
    func contains(cartographic: Cartographic) -> Bool {
        return cartographic.longitude >= west &&
            cartographic.longitude <= east &&
            cartographic.latitude >= south &&
            cartographic.latitude <= north
    }
    
    /**
    * Determines if the rectangle is empty, i.e., if <code>west >= east</code>
    * or <code>south >= north</code>.
    *
    * @param {Rectangle} rectangle The rectangle
    * @returns {Boolean} True if the rectangle is empty; otherwise, false.
    */
    func isEmpty() -> Bool {
        return west >= east || south >= north
    }
    
    /**
    * Samples an rectangle so that it includes a list of Cartesian points suitable for passing to
    * {@link BoundingSphere#fromPoints}.  Sampling is necessary to account
    * for rectangles that cover the poles or cross the equator.
    *
    * @param {Rectangle} rectangle The rectangle to subsample.
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid to use.
    * @param {Number} [surfaceHeight=0.0] The height of the rectangle above the ellipsoid.
    * @param {Cartesian3[]} [result] The array of Cartesians onto which to store the result.
    * @returns {Cartesian3[]} The modified result parameter or a new Array of Cartesians instances if none was provided.
    */
    func subsample(ellipsoid: Ellipsoid = Ellipsoid.wgs84(), surfaceHeight: Double = 0.0) -> [Cartesian3] {
        
        var result = [Cartesian3]()
        
        var lla = Cartographic()
        lla.height = surfaceHeight
        
        lla.longitude = west
        lla.latitude = north
        result.append(ellipsoid.cartographicToCartesian(lla))
        
        lla.longitude = east;
        result.append(ellipsoid.cartographicToCartesian(lla))
        
        lla.latitude = south;
        result.append(ellipsoid.cartographicToCartesian(lla))
        
        lla.longitude = west;
        result.append(ellipsoid.cartographicToCartesian(lla))
        
        if (north < 0.0) {
            lla.latitude = north;
        } else if (south > 0.0) {
            lla.latitude = south;
        } else {
            lla.latitude = 0.0;
        }
        
        for i in 1..<8 {
            var temp = -M_PI + Double(i) * M_PI_2;
            if (west < temp && temp < east) {
                lla.longitude = temp;
                result.append(ellipsoid.cartographicToCartesian(lla))
            }
        }
        
        if (lla.latitude == 0.0) {
            lla.longitude = west;
            result.append(ellipsoid.cartographicToCartesian(lla))
            
            lla.longitude = east;
            result.append(ellipsoid.cartographicToCartesian(lla))
        }
        return result;
    }
    
    /**
    * The largest possible rectangle.
    *
    * @type {Rectangle}
    * @constant
    */
    static func maxValue() -> Rectangle {
        return Rectangle(west: -M_PI, south: -M_PI_2, east: M_PI, north: M_PI_2)
    }
    
}



