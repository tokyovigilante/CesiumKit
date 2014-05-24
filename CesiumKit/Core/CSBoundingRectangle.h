//
//  CSBoundingRectangle.h
//  CesiumKit
//
//  Created by Ryan Walklin on 11/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;
@import CoreGraphics.CGGeometry;

@class CSRectangle, CSProjection, CSCartesian2;

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

@interface CSBoundingRectangle : NSObject <NSCopying>

@property (readonly) CGRect rect;

-(id)initWithX:(Float64)x Y:(Float64)y width:(Float64)width height:(Float64)height;
-(id)initWithRect:(CGRect)rect;

/**
 * Computes a bounding rectangle enclosing the list of 2D points.
 * The rectangle is oriented with the corner at the bottom left.
 * @memberof BoundingRectangle
 *
 * @param {Array} positions List of points that the bounding rectangle will enclose as NSNumber.  Each point must have <code>x</code> and <code>y</code> properties.
 * @param {BoundingRectangle} [result] The object onto which to store the result.
 * @returns {BoundingRectangle} The modified result parameter or a new BoundingRectangle instance if one was not provided.
 */
+(CSBoundingRectangle *)fromPoints:(NSArray *)points;

/**
 * Computes a bounding rectangle from an rectangle.
 * @memberof BoundingRectangle
 *
 * @param {Rectangle} rectangle The valid rectangle used to create a bounding rectangle.
 * @param {Object} [projection=GeographicProjection] The projection used to project the rectangle into 2D.
 * @param {BoundingRectangle} [result] The object onto which to store the result.
 * @returns {BoundingRectangle} The modified result parameter or a new BoundingRectangle instance if one was not provided.
 */
+(CSBoundingRectangle *)fromRectangle:(CSRectangle *)rectangle projection:(CSProjection *)projection;

/**
 * Computes a bounding rectangle that is the union of the left and right bounding rectangles.
 * @memberof BoundingRectangle
 *
 * @param {BoundingRectangle} left A rectangle to enclose in bounding rectangle.
 * @param {BoundingRectangle} right A rectangle to enclose in a bounding rectangle.
 * @param {BoundingRectangle} [result] The object onto which to store the result.
 * @returns {BoundingRectangle} The modified result parameter or a new BoundingRectangle instance if one was not provided.
 */
-(CSBoundingRectangle *)unionRect:(CSBoundingRectangle *)other;

/**
 * Computes a bounding rectangle by enlarging the provided rectangle until it contains the provided point.
 * @memberof BoundingRectangle
 *
 * @param {BoundingRectangle} rectangle A rectangle to expand.
 * @param {Cartesian2} point A point to enclose in a bounding rectangle.
 * @param {BoundingRectangle} [result] The object onto which to store the result.
 * @returns {BoundingRectangle} The modified result parameter or a new BoundingRectangle instance if one was not provided.
 */
-(CSBoundingRectangle *)expandToPoint:(CSCartesian2 *)point;

/**
 * Determines if two rectangles intersect.
 * @memberof BoundingRectangle
 *
 * @param {BoundingRectangle} left A rectangle to check for intersection.
 * @param {BoundingRectangle} right The other rectangle to check for intersection.
 * @returns {Intersect} <code>Intersect.INTESECTING</code> if the rectangles intersect, <code>Intersect.OUTSIDE</code> otherwise.
 */
-(BOOL)intersects:(CSBoundingRectangle *)other;

/**
 * Compares the provided BoundingRectangles componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 * @memberof BoundingRectangle
 *
 * @param {BoundingRectangle} [left] The first BoundingRectangle.
 * @param {BoundingRectangle} [right] The second BoundingRectangle.
 * @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
 */
-(BOOL)equals:(CSBoundingRectangle *)other;

@end
