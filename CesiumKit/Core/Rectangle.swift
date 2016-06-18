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
public struct Rectangle {
    var west: Double
    var south: Double
    var east: Double
    var north: Double
    
    /**
    * Gets the width of the rectangle in radians.
    * @memberof Rectangle.prototype
    * @type {Number}
    */
    var width: Double {
        get {
            if (east < west) {
                return east - west + Math.TwoPi
            } else {
                return east - west
            }
        }
    }
    
    /**
    * Gets the height of the rectangle in radians.
    * @memberof Rectangle.prototype
    * @type {Number}
    */
    var height: Double {
        get {
            return north - south
        }
    }
    
    public init(west: Double = 0.0, south: Double = 0.0, east: Double = 0.0, north: Double = 0.0) {
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
    public init (fromDegreesWest west: Double, south: Double, east: Double, north: Double) {
        self.west = Math.toRadians(west)
        self.south = Math.toRadians(south)
        self.east = Math.toRadians(east)
        self.north = Math.toRadians(north)
    }
    
    
    /**
    * Creates the smallest possible Rectangle that encloses all positions in the provided array.
    *
    * @param {Cartographic[]} cartographics The list of Cartographic instances.
    * @param {Rectangle} [result] The object onto which to store the result, or undefined if a new instance should be created.
    * @returns {Rectangle} The modified result parameter or a new Rectangle instance if none was provided.
    */
    static func fromCartographicArray(_ cartographics: [Cartographic]) -> Rectangle {
        
        var west = Double.infinity
        var east = -Double.infinity
        var westOverIDL = Double.infinity
        var eastOverIDL = -Double.infinity
        var south = Double.infinity
        var north = -Double.infinity
        
        for cartographic in cartographics {
            west = min(west, cartographic.longitude)
            east = max(east, cartographic.longitude)
            south = min(south, cartographic.latitude)
            north = max(north, cartographic.latitude)
            
            let lonAdjusted = cartographic.longitude >= 0 ? cartographic.longitude : cartographic.longitude +  Math.TwoPi
            westOverIDL = min(westOverIDL, lonAdjusted)
            eastOverIDL = max(eastOverIDL, lonAdjusted)
        }
        
        if east - west > eastOverIDL - westOverIDL {
            west = westOverIDL
            east = eastOverIDL
            
            if east > M_PI {
                east = east - Math.TwoPi
            }
            if west > M_PI {
                west = west - Math.TwoPi
            }
        }
        return Rectangle(west: west, south: south, east: east, north: north)
    }
    
    /**
    * Stores the provided instance into the provided array.
    *
    * @param {Rectangle} value The value to pack.
    * @param {Number[]} array The array to pack into.
    * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
    */
    /*func pack(inout array: [Float], startingIndex: Int = 0)  {
    
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
    }*/
    
    
    /**
    * Compares the provided rectangles and returns <code>true</code> if they are equal,
    * <code>false</code> otherwise.
    *
    * @param {Rectangle} [left] The first Rectangle.
    * @param {Rectangle} [right] The second Rectangle.
    * @returns {Boolean} <code>true</code> if left and right are equal; otherwise <code>false</code>.
    */
    func equals(_ other: Rectangle) -> Bool {
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
    func equalsEpsilon(_ other: Rectangle, epsilon: Double) -> Bool {
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
    var southwest: Cartographic {
        return Cartographic(longitude: west, latitude: south, height:0.0)
    }
    
    /**
    * Computes the northwest corner of an rectangle.
    *
    * @param {Rectangle} rectangle The rectangle for which to find the corner
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
    */
    var northwest: Cartographic {
        return Cartographic(longitude: west, latitude: north, height:0.0)
    }
    
    
    /**
    * Computes the northeast corner of an rectangle.
    *
    * @param {Rectangle} rectangle The rectangle for which to find the corner
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
    */
    var northeast: Cartographic {
        return Cartographic(longitude: east, latitude: north, height:0.0)
    }
    
    
    /**
    * Computes the southeast corner of an rectangle.
    *
    * @param {Rectangle} rectangle The rectangle for which to find the corner
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
    */
    var southeast: Cartographic {
        return Cartographic(longitude: east, latitude: south, height:0.0)
    }
    
    /**
    * Computes the center of an rectangle.
    *
    * @param {Rectangle} rectangle The rectangle for which to find the center
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
    */
    var center: Cartographic {
        let east: Double
        if (self.east < west) {
            east = self.east + Math.TwoPi
        } else {
            east = self.east
        }
        let longitude = Math.negativePiToPi((west + east) * 0.5)
        let latitude = (south + north) * 0.5
        
        return Cartographic(longitude: longitude, latitude: latitude)
    }
    
    /**
    * Computes the intersection of two rectangles
    *
    * @param {Rectangle} rectangle On rectangle to find an intersection
    * @param {Rectangle} otherRectangle Another rectangle to find an intersection
    * @param {Rectangle} [result] The object onto which to store the result.
    * @returns {Rectangle|undefined} The modified result parameter, a new Rectangle instance if none was provided or undefined if there is no intersection.
    */
    func intersection(_ other: Rectangle) -> Rectangle? {
        
        var thisEast = self.east
        var thisWest = self.west
        
        var otherEast = other.east
        var otherWest = other.west
        
        if (thisEast < thisWest && otherEast > 0.0) {
            thisEast += Math.TwoPi
        } else if (otherEast < otherWest && thisEast > 0.0) {
            otherEast += Math.TwoPi
        }
        
        if (thisEast < thisWest && otherWest < 0.0) {
            otherWest += Math.TwoPi
        } else if (otherEast < otherWest && thisWest < 0.0) {
            thisWest += Math.TwoPi
        }
        
        let west = Math.negativePiToPi(max(thisWest, otherWest))
        let east = Math.negativePiToPi(min(thisEast, otherEast))
        
        if (self.west < self.east || other.west < other.east) && east <= west {
            return nil
        }
        
        let south = max(self.south, other.south)
        let north = min(self.north, other.north)
        
        if south > north {
            return nil
        }
        
        return Rectangle(west: west, south: south, east: east, north: north)
    }
    /*
    /**
     * Computes a rectangle that is the union of two rectangles.
     *
     * @param {Rectangle} rectangle A rectangle to enclose in rectangle.
     * @param {Rectangle} otherRectangle A rectangle to enclose in a rectangle.
     * @param {Rectangle} [result] The object onto which to store the result.
     * @returns {Rectangle} The modified result parameter or a new Rectangle instance if none was provided.
     */
    Rectangle.union = function(rectangle, otherRectangle, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(rectangle)) {
    throw new DeveloperError('rectangle is required');
    }
    if (!defined(otherRectangle)) {
    throw new DeveloperError('otherRectangle is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    result = new Rectangle();
    }
    
    result.west = Math.min(rectangle.west, otherRectangle.west);
    result.south = Math.min(rectangle.south, otherRectangle.south);
    result.east = Math.max(rectangle.east, otherRectangle.east);
    result.north = Math.max(rectangle.north, otherRectangle.north);
    
    return result;
    };
    
    /**
     * Computes a rectangle by enlarging the provided rectangle until it contains the provided cartographic.
     *
     * @param {Rectangle} rectangle A rectangle to expand.
     * @param {Cartographic} cartographic A cartographic to enclose in a rectangle.
     * @param {Rectangle} [result] The object onto which to store the result.
     * @returns {Rectangle} The modified result parameter or a new Rectangle instance if one was not provided.
     */
    Rectangle.expand = function(rectangle, cartographic, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(rectangle)) {
    throw new DeveloperError('rectangle is required.');
    }
    if (!defined(cartographic)) {
    throw new DeveloperError('cartographic is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    result = new Rectangle();
    }
    
    result.west = Math.min(rectangle.west, cartographic.longitude);
    result.south = Math.min(rectangle.south, cartographic.latitude);
    result.east = Math.max(rectangle.east, cartographic.longitude);
    result.north = Math.max(rectangle.north, cartographic.latitude);
    
    return result;
    }

*/
    /**
    * Returns true if the cartographic is on or inside the rectangle, false otherwise.
    *
    * @param {Rectangle} rectangle The rectangle
    * @param {Cartographic} cartographic The cartographic to test.
    * @returns {Boolean} true if the provided cartographic is inside the rectangle, false otherwise.
    */
    func contains(_ cartographic: Cartographic) -> Bool {
        var longitude = cartographic.longitude
        let latitude = cartographic.latitude
        
        let west = self.west
        var east = self.east
        if east < west {
            east += Math.TwoPi
            if longitude < 0.0 {
                longitude += Math.TwoPi
            }
        }
        return (longitude > west || Math.equalsEpsilon(longitude, west, relativeEpsilon: Math.Epsilon14)) &&
            (longitude < east || Math.equalsEpsilon(longitude, east, relativeEpsilon: Math.Epsilon14)) &&
            latitude >= south &&
            latitude <= north
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
    func subsample(_ ellipsoid: Ellipsoid = Ellipsoid.wgs84(), surfaceHeight: Double = 0.0) -> [Cartesian3] {
        
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
            lla.latitude = north
        } else if (south > 0.0) {
            lla.latitude = south
        } else {
            lla.latitude = 0.0
        }
        
        for i in 1..<8 {
            lla.longitude = -M_PI + Double(i) * M_PI_2
            if (contains(lla)) {
                result.append(ellipsoid.cartographicToCartesian(lla))
            }
        }
        
        if (lla.latitude == 0.0) {
            lla.longitude = west
            result.append(ellipsoid.cartographicToCartesian(lla))
            
            lla.longitude = east
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

extension Rectangle: Packable {
    
    /**
     * The number of elements used to pack the object into an array.
     * @type {Number}
     */
    static func packedLength () -> Int {
        return 4
    }
    
    init(array: [Double], startingIndex: Int = 0) {
        self.init()
        assert(checkPackedArrayLength(array, startingIndex: startingIndex), "Invalid packed array length")
        array.withUnsafeBufferPointer { (pointer: UnsafeBufferPointer<Double>) in
            memcpy(&self, pointer.baseAddress, Rectangle.packedLength() * strideof(Double))
        }
    }
    
    
}



