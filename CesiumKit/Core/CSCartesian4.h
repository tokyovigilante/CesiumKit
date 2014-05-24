//
//  CSCartesian4.h
//  CesiumKit
//
//  Created by Ryan Walklin on 4/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;

@class UIColor;

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

@interface CSCartesian4 : NSObject <NSCopying>

@property (readonly) Float64 x;
@property (readonly) Float64 y;
@property (readonly) Float64 z;
@property (readonly) Float64 w;

@property (readonly) UInt32 packedLength;

-(id)initWithX:(Float64)x Y:(Float64)y Z:(Float64)z W:(Float64)w;

+(CSCartesian4 *)zero;
+(CSCartesian4 *)unitX;
+(CSCartesian4 *)unitY;
+(CSCartesian4 *)unitZ;
+(CSCartesian4 *)unitW;

-(CSCartesian4 *)cartesian4WithColor:(UIColor *)color;

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
+(CSCartesian4 *)unpack:(Float32 *)array startingIndex:(UInt32)index;

+(CSCartesian4 *)cartesian4WithArray:(Float64 *)array;

/**
 * Computes the value of the maximum component for the supplied Cartesian.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} The cartesian to use.
 * @returns {Number} The value of the maximum component.
 */
-(Float64)maximumComponent;

/**
 * Computes the value of the minimum component for the supplied Cartesian.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} The cartesian to use.
 * @returns {Number} The value of the minimum component.
 */
-(Float64)minimumComponent;

/**
 * Compares two Cartesians and computes a Cartesian which contains the maximum components of the supplied Cartesians.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} first A cartesian to compare.
 * @param {Cartesian4} second A cartesian to compare.
 * @param {Cartesian4} [result] The object into which to store the result.
 * @returns {Cartesian4} A cartesian with the maximum components.
 */

-(CSCartesian4 *)maximumByComponent:(CSCartesian4 *)other;
/**
 * Compares two Cartesians and computes a Cartesian which contains the minimum components of the supplied Cartesians.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} first A cartesian to compare.
 * @param {Cartesian4} second A cartesian to compare.
 * @param {Cartesian4} [result] The object into which to store the result.
 * @returns {Cartesian4} A cartesian with the minimum components.
 */
-(CSCartesian4 *)minimumByComponent:(CSCartesian4 *)other;

/**
 * Computes the provided Cartesian's squared magnitude.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} cartesian The Cartesian instance whose squared magnitude is to be computed.
 * @returns {Number} The squared magnitude.
 */
-(Float64)magnitudeSquared;
-(Float64)magnitude;

/**
 * Computes the 4-space distance between two points
 * @memberof Cartesian4
 *
 * @param {Cartesian4} left The first point to compute the distance from.
 * @param {Cartesian4} right The second point to compute the distance to.
 *
 * @returns {Number} The distance between two points.
 *
 * @example
 * // Returns 1.0
 * var d = Cesium.Cartesian4.distance(new Cesium.Cartesian4(1.0, 0.0, 0.0, 0.0), new Cesium.Cartesian4(2.0, 0.0, 0.0, 0.0));
 */
-(Float64)distance:(CSCartesian4 *)other;

/**
 * Computes the normalized form of the supplied Cartesian.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} cartesian The Cartesian to be normalized.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 */
-(CSCartesian4 *)normalise;

/**
 * Computes the dot (scalar) product of two Cartesians.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} left The first Cartesian.
 * @param {Cartesian4} right The second Cartesian.
 * @returns {Number} The dot product.
 */
-(Float64)dot:(CSCartesian4 *)other;

/**
 * Computes the componentwise product of two Cartesians.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} left The first Cartesian.
 * @param {Cartesian4} right The second Cartesian.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 */
-(CSCartesian4 *)multiplyComponents:(CSCartesian4 *)other;

/**
 * Computes the componentwise sum of two Cartesians.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} left The first Cartesian.
 * @param {Cartesian4} right The second Cartesian.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 */
-(CSCartesian4 *)add:(CSCartesian4 *)other;

/**
 * Computes the componentwise difference of two Cartesians.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} left The first Cartesian.
 * @param {Cartesian4} right The second Cartesian.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 */
-(CSCartesian4 *)subtract:(CSCartesian4 *)other;

/**
 * Multiplies the provided Cartesian componentwise by the provided scalar.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} cartesian The Cartesian to be scaled.
 * @param {Number} scalar The scalar to multiply with.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 */
-(CSCartesian4 *)multiplyByScalar:(Float64)scalar;

/**
 * Divides the provided Cartesian componentwise by the provided scalar.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} cartesian The Cartesian to be divided.
 * @param {Number} scalar The scalar to divide by.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 */
-(CSCartesian4 *)divideByScalar:(Float64)scalar;

/**
 * Negates the provided Cartesian.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} cartesian The Cartesian to be negated.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 */
-(CSCartesian4 *)negate;

/**
 * Computes the absolute value of the provided Cartesian.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} cartesian The Cartesian whose absolute value is to be computed.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 */
-(CSCartesian4 *)absolute;

/**
 * Computes the linear interpolation or extrapolation at t using the provided cartesians.
 * @memberof Cartesian4
 *
 * @param start The value corresponding to t at 0.0.
 * @param end The value corresponding to t at 1.0.
 * @param t The point along t at which to interpolate.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 */
-(CSCartesian4 *)linearExtrapolation:(CSCartesian4 *)other point:(Float64)t;

/**
 * Returns the axis that is most orthogonal to the provided Cartesian.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} cartesian The Cartesian on which to find the most orthogonal axis.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The most orthogonal axis.
 */
-(CSCartesian4 *)mostOrthogonalAxis;

/**
 * Compares the provided Cartesians componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} [left] The first Cartesian.
 * @param {Cartesian4} [right] The second Cartesian.
 * @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
 */
-(BOOL)equals:(CSCartesian4 *)other;

/**
 * Compares the provided Cartesians componentwise and returns
 * <code>true</code> if they are within the provided epsilon,
 * <code>false</code> otherwise.
 * @memberof Cartesian4
 *
 * @param {Cartesian4} [left] The first Cartesian.
 * @param {Cartesian4} [right] The second Cartesian.
 * @param {Number} epsilon The epsilon to use for equality testing.
 * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
 */
-(BOOL)equalsEpsilon:(CSCartesian4 *)other epsilon:(double)epsilon;

-(NSString *)description;
-(id)copyWithZone:(NSZone *)zone;

@end

