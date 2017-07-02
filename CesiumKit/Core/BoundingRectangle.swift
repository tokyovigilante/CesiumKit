//
//  BoundingRectangle.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A bounding rectangle given by a corner, width and height.
* @alias BoundingRectangle
* @constructor
*
* @param {Number} [x=0.0] The x coordinate of the rectangle.
* @param {Number} [y=0.0] The y coordinate of the rectangle.
* @param {Number} [width=0.0] The width of the rectangle.
* @param {Number} [height=0.0] The height of the rectangle.
*
* @see BoundingSphere
*/
public struct BoundingRectangle: Equatable {
    /**
    * The x coordinate of the rectangle.
    * @type {Number}
    * @default 0.0
    */
    public var x: Double = 0.0
    
    /**
    * The y coordinate of the rectangle.
    * @type {Number}
    * @default 0.0
    */
    public var y: Double = 0.0
    
    /**
    * The width of the rectangle.
    * @type {Number}
    * @default 0.0
    */
    public var width: Double = 0.0
    
    /**
    * The height of the rectangle.
    * @type {Number}
    * @default 0.0
    */
    public var height: Double = 0.0
    
    var projection: MapProjection = GeographicProjection()
    
    public init (x: Double = 0.0, y: Double = 0.0, width: Double = 0.0, height: Double = 0.0, projection: MapProjection = GeographicProjection()) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.projection = projection
    }
    
    /**
    * Computes a bounding rectangle enclosing the list of 2D points.
    * The rectangle is oriented with the corner at the bottom left.
    *
    * @param {Cartesian2[]} positions List of points that the bounding rectangle will enclose.  Each point must have <code>x</code> and <code>y</code> properties.
    * @param {BoundingRectangle} [result] The object onto which to store the result.
    * @returns {BoundingRectangle} The modified result parameter or a new BoundingRectangle instance if one was not provided.
    */
    init(fromPoints points: [Cartesian2]) {
        
        if (points.count == 0) {
            x = 0
            y = 0
            width = 0
            height = 0
        }
        
        var minimumX = points[0].x
        var minimumY = points[0].y
        
        var maximumX = points[0].x
        var maximumY = points[0].y
        
        for cartesian2 in points {
            let x = cartesian2.x
            let y = cartesian2.y
            
            minimumX = min(x, minimumX)
            maximumX = max(x, maximumX)
            minimumY = min(y, minimumY)
            maximumY = max(y, maximumY)
        }
        
        x = minimumX
        y = minimumY
        width = maximumX - minimumX
        height = maximumY - minimumY
    }
    
    /**
    * Computes a bounding rectangle from an rectangle.
    *
    * @param {Rectangle} rectangle The valid rectangle used to create a bounding rectangle.
    * @param {Object} [projection=GeographicProjection] The projection used to project the rectangle into 2D.
    * @param {BoundingRectangle} [result] The object onto which to store the result.
    * @returns {BoundingRectangle} The modified result parameter or a new BoundingRectangle instance if one was not provided.
    */
    init(fromRectangle rectangle: Rectangle, projection: MapProjection = GeographicProjection()) {
        
        self.projection = projection
        
        let lowerLeft = projection.project(rectangle.southwest)
        let upperRight = projection.project(rectangle.northeast).subtract(lowerLeft)
        
        //upperRight.subtract(lowerLeft)
        
        x = lowerLeft.x
        y = lowerLeft.y
        width = upperRight.x
        height = upperRight.y
    }
    
    /**
    * Computes a bounding rectangle that is the union of the left and right bounding rectangles.
    *
    * @param {BoundingRectangle} left A rectangle to enclose in bounding rectangle.
    * @param {BoundingRectangle} right A rectangle to enclose in a bounding rectangle.
    * @param {BoundingRectangle} [result] The object onto which to store the result.
    * @returns {BoundingRectangle} The modified result parameter or a new BoundingRectangle instance if one was not provided.
    */
    func union(_ other: BoundingRectangle) -> BoundingRectangle {
        
        let lowerLeftX = min(x, other.x);
        let lowerLeftY = min(y, other.y);
        let upperRightX = max(x + width, other.x + other.width);
        let upperRightY = max(y + height, other.y + other.height);
        
        return BoundingRectangle(
            x: lowerLeftX,
            y: lowerLeftY,
            width: upperRightX - lowerLeftX,
            height: upperRightY - lowerLeftY)
    }
    
    /**
    * Computes a bounding rectangle by enlarging the provided rectangle until it contains the provided point.
    *
    * @param {BoundingRectangle} rectangle A rectangle to expand.
    * @param {Cartesian2} point A point to enclose in a bounding rectangle.
    * @param {BoundingRectangle} [result] The object onto which to store the result.
    * @returns {BoundingRectangle} The modified result parameter or a new BoundingRectangle instance if one was not provided.
    */
    func expand(_ point: Cartesian2) -> BoundingRectangle {
        var result = self
        let width = point.x - result.x
        let height = point.y - result.y
        
        if (width > result.width) {
            result.width = width
        } else if (width < 0) {
            result.width -= width;
            result.x = point.x
        }
        
        if (height > result.height) {
            result.height = height
        } else if (height < 0) {
            result.height -= height;
            result.y = point.y
        }
        return result
    }
    
    /**
    * Determines if two rectangles intersect.
    *
    * @param {BoundingRectangle} left A rectangle to check for intersection.
    * @param {BoundingRectangle} right The other rectangle to check for intersection.
    * @returns {Intersect} <code>Intersect.INTESECTING</code> if the rectangles intersect, <code>Intersect.OUTSIDE</code> otherwise.
    */
    func intersect(_ other: BoundingRectangle) -> Intersect {
        if !(x > other.x + other.width ||
            x + width < other.x ||
            y + height < other.y ||
            y > other.y + other.height) {
                return Intersect.intersecting
        }
        return Intersect.outside;
    }
    
}

extension BoundingRectangle: Packable {
    
    init(array: [Double], startingIndex: Int) {
        self.init()
    }

    /**
     * The number of elements used to pack the object into an array.
     * @type {Number}
     */
    static func packedLength() -> Int {
        return 4
    }
    
    func checkPackedArrayLength(_ array: [Double], startingIndex: Int) -> Bool {
        return false
    }

    /**
     * Stores the provided instance into the provided array.
     *
     * @param {BoundingRectangle} value The value to pack.
     * @param {Number[]} array The array to pack into.
     * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
     *
     * @returns {Number[]} The array that was packed into
     */
    func pack (_ array: inout [Float], startingIndex: Int = 0) {
        array[startingIndex] = Float(x)
        array[startingIndex+1] = Float(y)
        array[startingIndex+2] = Float(width)
        array[startingIndex+3] = Float(height)
    }
    
    /**
     * Retrieves an instance from a packed array.
     *
     * @param {Number[]} array The packed array.
     * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
     * @param {BoundingRectangle} [result] The object into which to store the result.
     * @returns {BoundingRectangle} The modified result parameter or a new BoundingRectangle instance if one was not provided.
     */
    static func unpack (array: [Float], startingIndex: Int = 0) -> BoundingRectangle {
        var result = BoundingRectangle()
        result.x = Double(array[startingIndex])
        result.y = Double(array[startingIndex+1])
        result.width = Double(array[startingIndex+2])
        result.height = Double(array[startingIndex+3])
        return result
    }
    
}


/**
* Compares the provided BoundingRectangles componentwise and returns
* <code>true</code> if they are equal, <code>false</code> otherwise.
*
* @param {BoundingRectangle} [left] The first BoundingRectangle.
* @param {BoundingRectangle} [right] The second BoundingRectangle.
* @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
*/
public func ==(left: BoundingRectangle, right: BoundingRectangle) -> Bool {
    return (left.x == right.x &&
        left.y == right.y &&
        left.width == right.width &&
        left.height == right.height)
}
