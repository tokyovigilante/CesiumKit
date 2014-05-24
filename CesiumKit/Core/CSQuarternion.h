//
// CSQuarternion.h
// CesiumKit
//
// Created by Ryan on 11/05/14.
// Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;

@class CSCartesian3, CSMatrix3;

/**
 * A set of 4-dimensional coordinates used to represent rotation in 3-dimensional space.
 * @alias Quaternion
 * @constructor
 *
 * @param {Number} [x=0.0] The X component.
 * @param {Number} [y=0.0] The Y component.
 * @param {Number} [z=0.0] The Z component.
 * @param {Number} [w=0.0] The W component.
 *
 * @see PackableForInterpolation
 */
@interface CSQuarternion : NSObject <NSCopying>

@property (readonly) Float64 x;
@property (readonly) Float64 y;
@property (readonly) Float64 z;
@property (readonly) Float64 w;

@property (readonly) UInt32 packedLength; // 4
@property (readonly) UInt32 packedInterpolationLength; // 3

-(id)initWithX:(Float64)x Y:(Float64)y Z:(Float64)z W:(Float64)w;

/**
 * An immutable Quaternion instance initialized to (0.0, 0.0, 0.0, 0.0).
 * @memberof Quaternion
 */
+(CSQuarternion *)zero;

/**
 * An immutable Quaternion instance initialized to (0.0, 0.0, 0.0, 1.0).
 * @memberof Quaternion
 */
+(CSQuarternion *)identity;

/**
 * Computes a quaternion representing a rotation around an axis.
 * @memberof Quaternion
 *
 * @param {Cartesian3} axis The axis of rotation.
 * @param {Number} angle The angle in radians to rotate around the axis.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 */
+(CSQuarternion *)quarternionWithAxis:(CSCartesian3 *)axis angle:(Float64)angle;

/**
 * Computes a Quaternion from the provided Matrix3 instance.
 * @memberof Quaternion
 *
 * @param {Matrix3} matrix The rotation matrix.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 *
 * @see Matrix3.fromQuaternion
 */
+(CSQuarternion *)quarternionWithRotationMatrix:(CSMatrix3 *)matrix;

/**
 * Stores the provided instance into the provided array.
 * @memberof Quaternion
 *
 * @param {Quaternion} value The value to pack.
 * @param {Array} array The array to pack into.
 * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
 */
-(void)pack:(void *)array startingIndex:(UInt32)startingIndex;

/**
 * Retrieves an instance from a packed array.
 * @memberof Quaternion
 *
 * @param {Array} array The packed array.
 * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
 * @param {Quaternion} [result] The object into which to store the result.
 */
+(CSQuarternion *)unpack:(void *)array startingIndex:(UInt32)startingIndex;

/**
 * Converts a packed array into a form suitable for interpolation.
 * @memberof Quaternion
 *
 * @param {Array} packedArray The packed array.
 * @param {Number} [startingIndex=0] The index of the first element to be converted.
 * @param {Number} [lastIndex=packedArray.length] The index of the last element to be converted.
 * @param {Array} [result] The object into which to store the result.
 */
#warning packedArrayForInterpolation
//-(void)convertPackedArrayForInterpolation
//Quaternion.convertPackedArrayForInterpolation = function(packedArray, startingIndex, lastIndex, result) {

/**
 * Retrieves an instance from a packed array converted with {@link convertPackedArrayForInterpolation}.
 * @memberof Quaternion
 *
 * @param {Array} array The original packed array.
 * @param {Array} sourceArray The converted array.
 * @param {Number} [startingIndex=0] The startingIndex used to convert the array.
 * @param {Number} [lastIndex=packedArray.length] The lastIndex used to convert the array.
 * @param {Quaternion} [result] The object into which to store the result.
 */
//+(CSQuarternion *)unpackInterpolationResult;
//Quaternion.unpackInterpolationResult = function(array, sourceArray, firstIndex, lastIndex, result) {

/**
 * Computes the conjugate of the provided quaternion.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The quaternion to conjugate.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 */
-(CSQuarternion *)conjugate;


/**
 * Computes magnitude squared for the provided quaternion.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The quaternion to conjugate.
 * @returns {Number} The magnitude squared.
 */
-(Float64)magnitudeSquared;

/**
 * Computes magnitude for the provided quaternion.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The quaternion to conjugate.
 * @returns {Number} The magnitude.
 */
-(Float64)magnitude;

/**
 * Computes the normalized form of the provided quaternion.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The quaternion to normalize.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 */
-(CSQuarternion *)normalise;

/**
 * Computes the inverse of the provided quaternion.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The quaternion to normalize.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 */
-(CSQuarternion *)inverse;

/**
 * Computes the componentwise sum of two quaternions.
 * @memberof Quaternion
 *
 * @param {Quaternion} left The first quaternion.
 * @param {Quaternion} right The second quaternion.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 */
-(CSQuarternion *)add:(CSQuarternion *)other;

/**
 * Computes the componentwise difference of two quaternions.
 * @memberof Quaternion
 *
 * @param {Quaternion} left The first quaternion.
 * @param {Quaternion} right The second quaternion.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 */
-(CSQuarternion *)subtract:(CSQuarternion *)other;

/**
 * Negates the provided quaternion.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The quaternion to be negated.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 */
-(CSQuarternion *)negate;

/**
 * Computes the dot (scalar) product of two quaternions.
 * @memberof Quaternion
 *
 * @param {Quaternion} left The first quaternion.
 * @param {Quaternion} right The second quaternion.
 * @returns {Number} The dot product.
 */
-(Float64)dot:(CSQuarternion *)other;

/**
 * Computes the product of two quaternions.
 * @memberof Quaternion
 *
 * @param {Quaternion} left The first quaternion.
 * @param {Quaternion} right The second quaternion.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 */
-(CSQuarternion *)multiply:(CSQuarternion *)other;

/**
 * Multiplies the provided quaternion componentwise by the provided scalar.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The quaternion to be scaled.
 * @param {Number} scalar The scalar to multiply with.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 */
-(CSQuarternion *)multiplyByScalar:(Float64)scalar;

/**
 * Divides the provided quaternion componentwise by the provided scalar.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The quaternion to be divided.
 * @param {Number} scalar The scalar to divide by.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 */
-(CSQuarternion *)divideByScalar:(Float64)scalar;

/**
 * Computes the axis of rotation of the provided quaternion.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The quaternion to use.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian3 *)getAxis;

/**
 * Computes the angle of rotation of the provided quaternion.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The quaternion to use.
 * @returns {Number} The angle of rotation.
 */
-(Float64)getAngle;

/**
 * Computes the linear interpolation or extrapolation at t using the provided quaternions.
 * @memberof Quaternion
 *
 * @param {Quaternion} end The value corresponding to t at 1.0.
 * @param {Number} t The point along t at which to interpolate.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 */
-(CSQuarternion *)linearExtrapolation:(CSQuarternion *)end point:(Float64)t;

/**
 * Computes the spherical linear interpolation or extrapolation at t using the provided quaternions.
 * @memberof Quaternion
 *
 * @param {Quaternion} start The value corresponding to t at 0.0.
 * @param {Quaternion} end The value corresponding to t at 1.0.
 * @param {Number} t The point along t at which to interpolate.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 *
 * @see Quaternion#fastSlerp
 */
-(CSQuarternion *)sphericalLinearExtrapolation:(CSQuarternion *)end point:(Float64)t;

/**
 * The logarithmic quaternion function.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The unit quaternion.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new instance if one was not provided.
 */
-(CSCartesian3 *)log;

/**
 * The exponential quaternion function.
 * @memberof Quaternion
 *
 * @param {Cartesian3} cartesian The cartesian.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new instance if one was not provided.
 */
-(CSQuarternion *)exp:(CSCartesian3 *)cartesian3;

/**
 * Computes an inner quadrangle point.
 * <p>This will compute quaternions that ensure a squad curve is C<sup>1</sup>.</p>
 * @memberof Quaternion
 *
 * @param {Quaternion} q0 The first quaternion.
 * @param {Quaternion} q1 The second quaternion.
 * @param {Quaternion} q2 The third quaternion.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new instance if none was provided.
 *
 * @see Quaternion#squad
 */
+(CSQuarternion *)innerQuadrangle:(CSQuarternion *)q0 q1:(CSQuarternion *)q1 q2:(CSQuarternion *)q3;

/**
 * Computes the spherical quadrangle interpolation between quaternions.
 * @memberof Quaternion
 *
 * @param {Quaternion} q0 The first quaternion.
 * @param {Quaternion} q1 The second quaternion.
 * @param {Quaternion} s0 The first inner quadrangle.
 * @param {Quaternion} s1 The second inner quadrangle.
 * @param {Number} t The time in [0,1] used to interpolate.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new instance if none was provided.
 *
 * @see Quaternion#innerQuadrangle
 *
 * @example
 * // 1. compute the squad interpolation between two quaternions on a curve
 * var s0 = Cesium.Quaternion.innerQuadrangle(quaternions[i - 1], quaternions[i], quaternions[i + 1]);
 * var s1 = Cesium.Quaternion.innerQuadrangle(quaternions[i], quaternions[i + 1], quaternions[i + 2]);
 * var q = Cesium.Quaternion.squad(quaternions[i], quaternions[i + 1], s0, s1, t);
 *
 * // 2. compute the squad interpolation as above but where the first quaternion is a end point.
 * var s1 = Cesium.Quaternion.innerQuadrangle(quaternions[0], quaternions[1], quaternions[2]);
 * var q = Cesium.Quaternion.squad(quaternions[0], quaternions[1], quaternions[0], s1, t);
 */
+(CSQuarternion *)sphericalQuadrangleInterpolation:(CSQuarternion *)q0 q1:(CSQuarternion *)q1 s0:(CSQuarternion *)s0 s1:(CSQuarternion *)s1 t:(Float64)t;

/**
 * Computes the spherical linear interpolation or extrapolation at t using the provided quaternions.
 * This implementation is faster than {@link Quaternion#slerp}, but is only accurate up to 10<sup>-6</sup>.
 * @memberof Quaternion
 *
 * @param {Quaternion} start The value corresponding to t at 0.0.
 * @param {Quaternion} end The value corresponding to t at 1.0.
 * @param {Number} t The point along t at which to interpolate.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
 *
 * @see Quaternion#slerp
 */
-(CSQuarternion *)fastSphericalLinearExtrapolation:(CSQuarternion *)start end:(CSQuarternion *)end point:(Float64)t;

/**
 * Computes the spherical quadrangle interpolation between quaternions.
 * An implementation that is faster than {@link Quaternion#squad}, but less accurate.
 * @memberof Quaternion
 *
 * @param {Quaternion} q0 The first quaternion.
 * @param {Quaternion} q1 The second quaternion.
 * @param {Quaternion} s0 The first inner quadrangle.
 * @param {Quaternion} s1 The second inner quadrangle.
 * @param {Number} t The time in [0,1] used to interpolate.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new instance if none was provided.
 *
 * @see Quaternion#squad
 */
+(CSQuarternion *)fastSphericalQuadrangleInterpolation:(CSQuarternion *)q0 q1:(CSQuarternion *)q1 s0:(CSQuarternion *)s0 s1:(CSQuarternion *)s1 t:(Float64)t;

/**
 * Compares the provided quaternions componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 * @memberof Quaternion
 *
 * @param {Quaternion} [left] The first quaternion.
 * @param {Quaternion} [right] The second quaternion.
 * @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
 */
-(BOOL)equals:(CSQuarternion *)other;

/**
 * Compares the provided quaternions componentwise and returns
 * <code>true</code> if they are within the provided epsilon,
 * <code>false</code> otherwise.
 * @memberof Quaternion
 *
 * @param {Quaternion} [left] The first quaternion.
 * @param {Quaternion} [right] The second quaternion.
 * @param {Number} epsilon The epsilon to use for equality testing.
 * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
 */
-(BOOL)equals:(CSQuarternion *)other epsilon:(Float64)epsilon;

@end