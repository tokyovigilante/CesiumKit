//
//  CSRectangle.h
//  CesiumKit
//
//  Created by Ryan Walklin on 11/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;

@class CSCartographic, Ellipsoid;

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
@interface CSRectangle : NSObject <NSCopying>

@property (readonly) Float64 west;
@property (readonly) Float64 south;
@property (readonly) Float64 east;
@property (readonly) Float64 north;

-(instancetype)initWithWest:(Float64)west south:(Float64)south east:(Float64)east north:(Float64)north;

/**
 * Creates an rectangle given the boundary longitude and latitude in degrees.
 *
 * @memberof Rectangle
 *
 * @param {Number} [west=0.0] The westernmost longitude in degrees in the range [-180.0, 180.0].
 * @param {Number} [south=0.0] The southernmost latitude in degrees in the range [-90.0, 90.0].
 * @param {Number} [east=0.0] The easternmost longitude in degrees in the range [-180.0, 180.0].
 * @param {Number} [north=0.0] The northernmost latitude in degrees in the range [-90.0, 90.0].
 * @param {Rectangle} [result] The object onto which to store the result, or undefined if a new instance should be created.
 *
 * @returns {Rectangle} The modified result parameter or a new Rectangle instance if none was provided.
 *
 * @example
 * var rectangle = Cesium.Rectangle.fromDegrees(0.0, 20.0, 10.0, 30.0);
 */
-(CSRectangle *)rectangleWithDegreesWest:(Float64)west south:(Float64)south east:(Float64)east north:(Float64)north;

/**
 * Creates the smallest possible Rectangle that encloses all positions in the provided array.
 * @memberof Rectangle
 *
 * @param {Cartographic[]} cartographics The list of Cartographic instances.
 * @param {Rectangle} [result] The object onto which to store the result, or undefined if a new instance should be created.
 * @returns {Rectangle} The modified result parameter or a new Rectangle instance if none was provided.
 */
-(CSRectangle *)rectangleWithCartographicArray:(NSArray *)cartographics;

/**
 * The number of elements used to pack the object into an array.
 * @type {Number}
 */
//Rectangle.packedLength = 4;

/**
 * Stores the provided instance into the provided array.
 * @memberof Rectangle
 *
 * @param {Rectangle} value The value to pack.
 * @param {Number[]} array The array to pack into.
 * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
 */
//Rectangle.pack = function(value, array, startingIndex)

/**
 * Retrieves an instance from a packed array.
 * @memberof Rectangle
 *
 * @param {Number[]} array The packed array.
 * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
 * @param {Rectangle} [result] The object into which to store the result.
 */
//Rectangle.unpack = function(array, startingIndex, result) {

/**
 * Compares the provided Rectangle with this Rectangle componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 * @memberof Rectangle
 *
 * @param {Rectangle} [other] The Rectangle to compare.
 * @returns {Boolean} <code>true</code> if the Rectangles are equal, <code>false</code> otherwise.
 */
-(BOOL)equals:(CSRectangle *)other;

/**
 * Compares the provided Rectangle with this Rectangle componentwise and returns
 * <code>true</code> if they are within the provided epsilon,
 * <code>false</code> otherwise.
 * @memberof Rectangle
 *
 * @param {Rectangle} [other] The Rectangle to compare.
 * @param {Number} epsilon The epsilon to use for equality testing.
 * @returns {Boolean} <code>true</code> if the Rectangles are within the provided epsilon, <code>false</code> otherwise.
 */
-(BOOL)equals:(CSRectangle *)other epsilon:(Float64)epsilon;

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
-(void)validate;

/**
 * Computes the southwest corner of an rectangle.
 * @memberof Rectangle
 *
 * @param {Rectangle} rectangle The rectangle for which to find the corner
 * @param {Cartographic} [result] The object onto which to store the result.
 * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
 */
-(CSCartographic *)southwest;

/**
 * Computes the northwest corner of an rectangle.
 * @memberof Rectangle
 *
 * @param {Rectangle} rectangle The rectangle for which to find the corner
 * @param {Cartographic} [result] The object onto which to store the result.
 * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
 */
-(CSCartographic *)northwest;

/**
 * Computes the northeast corner of an rectangle.
 * @memberof Rectangle
 *
 * @param {Rectangle} rectangle The rectangle for which to find the corner
 * @param {Cartographic} [result] The object onto which to store the result.
 * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
 */
-(CSCartographic *)northeast;

/**
 * Computes the southeast corner of an rectangle.
 * @memberof Rectangle
 *
 * @param {Rectangle} rectangle The rectangle for which to find the corner
 * @param {Cartographic} [result] The object onto which to store the result.
 * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
 */
-(CSCartographic *)southeast;

/**
 * Computes the center of an rectangle.
 * @memberof Rectangle
 *
 * @param {Rectangle} rectangle The rectangle for which to find the center
 * @param {Cartographic} [result] The object onto which to store the result.
 * @returns {Cartographic} The modified result parameter or a new Cartographic instance if none was provided.
 */
-(CSCartographic *)center;

/**
 * Computes the intersection of two rectangles
 * @memberof Rectangle
 *
 * @param {Rectangle} rectangle On rectangle to find an intersection
 * @param {Rectangle} otherRectangle Another rectangle to find an intersection
 * @param {Rectangle} [result] The object onto which to store the result.
 * @returns {Rectangle} The modified result parameter or a new Rectangle instance if none was provided.
 */
-(CSRectangle *)intersectWith:(CSRectangle *)other;

/**
 * Returns true if the cartographic is on or inside the rectangle, false otherwise.
 * @memberof Rectangle
 *
 * @param {Rectangle} rectangle The rectangle
 * @param {Cartographic} cartographic The cartographic to test.
 * @returns {Boolean} true if the provided cartographic is inside the rectangle, false otherwise.
 */
-(BOOL)contains:(CSCartographic *)cartographic;

/**
 * Determines if the rectangle is empty, i.e., if <code>west >= east</code>
 * or <code>south >= north</code>.
 *
 * @memberof Rectangle
 *
 * @param {Rectangle} rectangle The rectangle
 * @returns {Boolean} True if the rectangle is empty; otherwise, false.
 */
-(BOOL)isEmpty;

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
-(NSArray *)subsample:(Ellipsoid *)ellipsoid surfaceHeight:(Float64)surfaceHeight;

/**
 * The largest possible rectangle.
 * @memberof Rectangle
 * @type Rectangle
 */
+(CSRectangle *)maxValue;

@end
