//
//  CSCartesian2.h
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//  Based on Openglobe C# virtual globe code - https://github.com/virtualglobebook/OpenGlobe and Cesium.js - http://www.cesium.org
//

@import Foundation;

@class Cartesian3, CSCartesian4;

@interface CSCartesian2 : NSObject <NSCopying>

@property (assign) Float64 x;
@property (assign) Float64 y;

@property (readonly) UInt32 packedLength;

-(id)initWithX:(Float64)x Y:(Float64)y;

+(CSCartesian2 *)zero;
+(CSCartesian2 *)unitX;
+(CSCartesian2 *)unitY;
+(CSCartesian2 *)undefined;

+(CSCartesian2 *)cartesian2FromCartesian3:(Cartesian3 *)cartesian3;
+(CSCartesian2 *)cartesian2FromCartesian4:(CSCartesian4 *)cartesian4;


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
+(CSCartesian2 *)unpack:(Float32 *)array startingIndex:(UInt32)index;

-(Float64)maximumComponent;
-(Float64)minimumComponent;

/**
 * Compares two Cartesians and computes a Cartesian which contains the maximum components of the supplied Cartesians.
 * @memberof Cartesian3
 *
 * @param {CSCartesian2} other A cartesian to compare.
 * @returns {CSCartesian2} A cartesian with the maximum components.
 */
-(CSCartesian2 *)maximumByComponent:(CSCartesian2 *)other;

/**
 * Compares two Cartesians and computes a Cartesian which contains the minimum components of the supplied Cartesians.
 * @memberof Cartesian3
 *
 * @param {CSCartesian2} other A cartesian to compare.
 * @returns {CSCartesian2} A cartesian with the minimum components.
 */
-(CSCartesian2 *)minimumByComponent:(CSCartesian2 *)other;

-(Float64)magnitudeSquared;
-(Float64)magnitude;

/**
 * Computes the distance between two points
 * @memberof Cartesian2
 *
 * @param {Cartesian2} left The first point to compute the distance from.
 * @param {Cartesian2} right The second point to compute the distance to.
 *
 * @returns {Number} The distance between two points.
 *
 * @example
 * // Returns 1.0
 * var d = Cesium.Cartesian2.distance(new Cesium.Cartesian2(1.0, 0.0), new Cesium.Cartesian2(2.0, 0.0));
 */
-(Float64)distance:(CSCartesian2 *)other;

/**
 * Computes the normalized form of the supplied Cartesian.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} cartesian The Cartesian to be normalized.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian2 *)normalise;

/**
 * Computes the dot (scalar) product of two Cartesians.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} left The first Cartesian.
 * @param {Cartesian3} right The second Cartesian.
 * @returns {Number} The dot product.
 */
-(Float64)dot:(CSCartesian2 *)other;

/**
 * Computes the componentwise product of two Cartesians.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} left The first Cartesian.
 * @param {Cartesian3} right The second Cartesian.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian2 *)multiplyComponents:(CSCartesian2 *)scale;

/**
 * Computes the componentwise sum of two Cartesians.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} left The first Cartesian.
 * @param {Cartesian3} right The second Cartesian.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian2 *)add:(CSCartesian2 *)other;

/**
 * Computes the componentwise difference of two Cartesians.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} left The first Cartesian.
 * @param {Cartesian3} right The second Cartesian.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian2 *)subtract:(CSCartesian2 *)other;

/**
 * Multiplies the provided Cartesian componentwise by the provided scalar.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} cartesian The Cartesian to be scaled.
 * @param {Number} scalar The scalar to multiply with.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian2 *)multiplyByScalar:(Float64)scalar;

-(CSCartesian2 *)divideByScalar:(Float64)scalar;


/**
 * Negates the provided Cartesian.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} cartesian The Cartesian to be negated.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian2 *)negate;

/**
 * Computes the absolute value of the provided Cartesian.
 * @memberof Cartesian3
 *
 * @param {Cartesian3} cartesian The Cartesian whose absolute value is to be computed.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian2 *)absolute;

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
-(CSCartesian2 *)linearExtrapolation:(CSCartesian2 *)end point:(Float64)t;

-(Float64)angleBetween:(CSCartesian2 *)other;
-(CSCartesian2 *)mostOrthogonalAxis;

-(BOOL)equalsEpsilon:(CSCartesian2 *)other epsilon:(Float64)epsilon;
-(BOOL)equals:(CSCartesian2 *)other;

-(NSString *)description;

@end
