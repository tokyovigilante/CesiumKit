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
struct BoundingRectangle: Equatable {
    /**
    * The x coordinate of the rectangle.
    * @type {Number}
    * @default 0.0
    */
    var x: Double = 0.0
    
    /**
    * The y coordinate of the rectangle.
    * @type {Number}
    * @default 0.0
    */
    var y: Double = 0.0
    
    /**
    * The width of the rectangle.
    * @type {Number}
    * @default 0.0
    */
    var width: Double = 0.0
    
    /**
    * The height of the rectangle.
    * @type {Number}
    * @default 0.0
    */
    var height: Double = 0.0
    
    var projection: Projection = GeographicProjection()
    
    init (var x: Double = 0.0, y: Double = 0.0, width: Double = 0.0, height: Double = 0.0, projection: Projection = GeographicProjection()) {
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
            var x = cartesian2.x
            var y = cartesian2.y
            
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
    init(fromRectangle rectangle: Rectangle, projection: Projection = GeographicProjection()) {
        
        self.projection = projection
        
        var lowerLeft = projection.project(rectangle.southwest())
        var upperRight = projection.project(rectangle.northeast())
        
        upperRight.subtract(lowerLeft);
        
        x = lowerLeft.x;
        y = lowerLeft.y;
        width = upperRight.x;
        height = upperRight.y;
    }
    
    /**
    * Computes a bounding rectangle that is the union of the left and right bounding rectangles.
    *
    * @param {BoundingRectangle} left A rectangle to enclose in bounding rectangle.
    * @param {BoundingRectangle} right A rectangle to enclose in a bounding rectangle.
    * @param {BoundingRectangle} [result] The object onto which to store the result.
    * @returns {BoundingRectangle} The modified result parameter or a new BoundingRectangle instance if one was not provided.
    */
    func union(other: BoundingRectangle) -> BoundingRectangle {
        
        var lowerLeftX = min(x, other.x);
        var lowerLeftY = min(y, other.y);
        var upperRightX = max(x + width, other.x + other.width);
        var upperRightY = max(y + height, other.y + other.height);
        
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
    func expand(point: Cartesian2) -> BoundingRectangle {
        var result = self
        var width = point.x - result.x
        var height = point.y - result.y
        
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
    func intersect(other: BoundingRectangle) -> Intersect {
        if !(x > other.x + other.width ||
            x + width < other.x ||
            y + height < other.y ||
            y > other.y + other.height) {
                return Intersect.Intersecting
        }
        return Intersect.Outside;
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
func ==(left: BoundingRectangle, right: BoundingRectangle) -> Bool {
    return (left.x == right.x &&
        left.y == right.y &&
        left.width == right.width &&
        left.height == right.height)
}
