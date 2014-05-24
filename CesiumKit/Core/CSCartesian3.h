//
//  CSCartesian3.h
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//  Based on Openglobe C# virtual globe code - https://github.com/virtualglobebook/OpenGlobe
//

/// <summary>
/// A set of 3-dimensional cartesian coordinates where the three components,
/// <see cref="X"/>, <see cref="Y"/>, and <see cref="Z"/>, are represented as
/// double-precision (64-bit) floating point numbers.
/// </summary>

@import Foundation;

@class CSCartesian2, CSSpherical;

@interface CSCartesian3 : NSObject <NSCopying>

@property (readonly) Float64 x;
@property (readonly) Float64 y;
@property (readonly) Float64 z;

@property (readonly) UInt32 packedLength;

+(CSCartesian3 *)zero;
+(CSCartesian3 *)unitX;
+(CSCartesian3 *)unitY;
+(CSCartesian3 *)unitZ;
+(CSCartesian3 *)undefined;

-(id)initWithX:(Float64)x Y:(Float64)y Z:(Float64)z;

/**
 * Stores the provided instance into the provided array.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} value The value to pack.
 * @param {Array} array The array to pack into.
 * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
 */
-(void)pack:(Float32 *)array startingIndex:(UInt32)index;

/**
 * Retrieves an instance from a packed array.
 * @memberof Cartesian3
 *
 * @param {Array} array The packed array.
 * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
 * @param {Cartesian3} [result] The object into which to store the result.
 */
+(CSCartesian3 *)unpack:(Float32 *)array startingIndex:(UInt32)index;

+(CSCartesian3 *)cartesian3FromArray:(Float64 *)array;

+(CSCartesian3 *)cartesian3FromSpherical:(CSSpherical *)spherical;

-(CSCartesian2 *)xy;
-(Float64)magnitudeSquared;
-(Float64)magnitude;

-(BOOL)isUndefined;

/**
 * Computes the normalized form of the supplied Cartesian.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} cartesian The Cartesian to be normalized.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian3 *)normalise;

-(CSCartesian3 *)cross:(CSCartesian3 *)other;

/**
 * Computes the dot (scalar) product of two Cartesians.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} left The first Cartesian.
 * @param {Cartesian3} right The second Cartesian.
 * @returns {Number} The dot product.
 */
-(Float64)dot:(CSCartesian3 *)other;

/**
 * Computes the componentwise sum of two Cartesians.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} left The first Cartesian.
 * @param {Cartesian3} right The second Cartesian.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian3 *)add:(CSCartesian3 *)addend;

/**
 * Computes the componentwise difference of two Cartesians.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} left The first Cartesian.
 * @param {Cartesian3} right The second Cartesian.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian3 *)subtract:(CSCartesian3 *)subtrahend;

/**
 * Multiplies the provided Cartesian componentwise by the provided scalar.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} cartesian The Cartesian to be scaled.
 * @param {Number} scalar The scalar to multiply with.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian3 *)multiplyByScalar:(Float64)scalar;

/**
 * Computes the componentwise product of two Cartesians.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} left The first Cartesian.
 * @param {Cartesian3} right The second Cartesian.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian3 *)multiplyComponents:(CSCartesian3 *)scale;

-(CSCartesian3 *)divideScalar:(Float64)scalar;


/**
 * Negates the provided Cartesian.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} cartesian The Cartesian to be negated.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian3 *)negate;

/**
 * Computes the absolute value of the provided Cartesian.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} cartesian The Cartesian whose absolute value is to be computed.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian3 *)absolute;

-(Float64)maximumComponent;
-(Float64)minimumComponent;

/**
 * Compares two Cartesians and computes a Cartesian which contains the maximum components of the supplied Cartesians.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} other A cartesian to compare.
 * @returns {Cartesian3} A cartesian with the maximum components.
 */
-(CSCartesian3 *)maximumByComponent:(CSCartesian3 *)other;

/**
 * Compares two Cartesians and computes a Cartesian which contains the minimum components of the supplied Cartesians.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} other A cartesian to compare.
 * @returns {Cartesian3} A cartesian with the minimum components.
 */
-(CSCartesian3 *)minimumByComponent:(CSCartesian3 *)other;

/**
 * Computes the distance between two points
 * @memberof Cartesian3
 *
 * @param {Cartesian3} right The second point to compute the distance to.
 *
 * @returns {Number} The distance between two points.
 *
 * @example
 * // Returns 1.0
 * var d = Cesium.Cartesian3.distance(new Cesium.Cartesian3(1.0, 0.0, 0.0), new Cesium.Cartesian3(2.0, 0.0, 0.0));
 */
-(Float64)distance:(CSCartesian3 *)other;

/**
 * Computes the linear interpolation or extrapolation at t using the provided cartesians.
 * @memberof Cartesian3
 *
 * @param start The value corresponding to t at 0.0.
 * @param end The value corresponding to t at 1.0.
 * @param t The point along t at which to interpolate.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian3 *)linearExtrapolation:(CSCartesian3 *)other point:(Float64)t;

-(CSCartesian3 *)mostOrthogonalAxis;
-(Float64)angleBetween:(CSCartesian3 *)other;

-(CSCartesian3 *)rotateAroundAxis:(CSCartesian3 *)axis theta:(Float64)theta;

-(BOOL)equalsEpsilon:(CSCartesian3 *)other epsilon:(Float64)epsilon;
-(BOOL)equals:(CSCartesian3 *)other;

-(NSString *)description;

@end
