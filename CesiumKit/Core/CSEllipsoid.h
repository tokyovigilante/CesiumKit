//
//  CSEllipsoid.h
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//  Based on Openglobe C# virtual globe code - https://github.com/virtualglobebook/OpenGlobe
//

@import Foundation;

@class Cartesian3, CSCartographic;

/**
 * A quadratic surface defined in Cartesian coordinates by the equation
 * <code>(x / a)^2 + (y / b)^2 + (z / c)^2 = 1</code>.  Primarily used
 * by Cesium to represent the shape of planetary bodies.
 *
 * Rather than constructing this object directly, one of the provided
 * constants is normally used.
 * @alias Ellipsoid
 * @constructor
 * @immutable
 *
 * @param {Number} [x=0] The radius in the x direction.
 * @param {Number} [y=0] The radius in the y direction.
 * @param {Number} [z=0] The radius in the z direction.
 *
 * @exception {DeveloperError} All radii components must be greater than or equal to zero.
 *
 * @see Ellipsoid.fromCartesian3
 * @see Ellipsoid.WGS84
 * @see Ellipsoid.UNIT_SPHERE
 */
@interface CSEllipsoid : NSObject <NSCopying>

@property Cartesian3 *radii;
@property Cartesian3 *radiiSquared;
@property Cartesian3 *oneOverRadii;
@property Cartesian3 *oneOverRadiiSquared;
@property Cartesian3 *radiiFourthPower;
@property Float64 maximumRadius;
@property Float64 minimumRadius;

-(id)initWithX:(Float64)x Y:(Float64)y Z:(Float64)z;

/**
 * An Ellipsoid instance initialized to the WGS84 standard.
 * @memberof Ellipsoid
 *
 * @see czm_getWgs84EllipsoidEC
 */
+(CSEllipsoid *)wgs84Ellipsoid; // 6378.1km eq radius, 6356.8km polar radius

/**
 * An Ellipsoid instance initialized to radii of (1.0, 1.0, 1.0).
 * @memberof Ellipsoid
 */
+(CSEllipsoid *)unitSphereEllipsoid; // 1.0 unit radius


/**
 * Computes an Ellipsoid from a Cartesian specifying the radii in x, y, and z directions.
 *
 * @param {Cartesian3} [radii=Cartesian3.ZERO] The ellipsoid's radius in the x, y, and z directions.
 * @returns {Ellipsoid} A new Ellipsoid instance.
 *
 * @exception {DeveloperError} All radii components must be greater than or equal to zero.
 *
 * @see Ellipsoid.WGS84
 * @see Ellipsoid.UNIT_SPHERE
 */
+(CSEllipsoid *)ellipsoidWithCartesian3:(Cartesian3 *)cartesian3;

/**
 * Computes the unit vector directed from the center of this ellipsoid toward the provided Cartesian position.
 * @memberof Ellipsoid
 *
 * @param {Cartesian3} cartesian The Cartesian for which to to determine the geocentric normal.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if none was provided.
 */
-(Cartesian3 *)geocentricSurfaceNormal:(Cartesian3 *)cartesian3;

/**
 * Computes the normal of the plane tangent to the surface of the ellipsoid at the provided position.
 * @memberof Ellipsoid
 *
 * @param {Cartographic} cartographic The cartographic position for which to to determine the geodetic normal.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if none was provided.
 */
-(Cartesian3 *)geodeticSurfaceNormalCartographic:(CSCartographic *)cartographic;

/**
 * Computes the normal of the plane tangent to the surface of the ellipsoid at the provided position.
 * @memberof Ellipsoid
 *
 * @param {Cartesian3} cartesian The Cartesian position for which to to determine the surface normal.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if none was provided.
 */
-(Cartesian3 *)geodeticSurfaceNormal:(Cartesian3 *)cartesian3;

/**
 * Converts the provided cartographic to Cartesian representation.
 * @memberof Ellipsoid
 *
 * @param {Cartographic} cartographic The cartographic position.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if none was provided.
 *
 * @example
 * //Create a Cartographic and determine it's Cartesian representation on a WGS84 ellipsoid.
 * var position = new Cesium.Cartographic(Cesium.Math.toRadians(21), Cesium.Math.toRadians(78), 5000);
 * var cartesianPosition = Cesium.Ellipsoid.WGS84.cartographicToCartesian(position);
 */
-(Cartesian3 *)cartographicToCartesian:(CSCartographic *)cartographic;

/**
 * Converts the provided array of cartographics to an array of Cartesians.
 * @memberof Ellipsoid
 *
 * @param {Cartographic[]} cartographics An array of cartographic positions.
 * @param {Cartesian3[]} [result] The object onto which to store the result.
 * @returns {Cartesian3[]} The modified result parameter or a new Array instance if none was provided.
 *
 * @example
 * //Convert an array of Cartographics and determine their Cartesian representation on a WGS84 ellipsoid.
 * var positions = [new Cesium.Cartographic(Cesium.Math.toRadians(21), Cesium.Math.toRadians(78), 0),
 *                  new Cesium.Cartographic(Cesium.Math.toRadians(21.321), Cesium.Math.toRadians(78.123), 100),
 *                  new Cesium.Cartographic(Cesium.Math.toRadians(21.645), Cesium.Math.toRadians(78.456), 250)
 * var cartesianPositions = Cesium.Ellipsoid.WGS84.cartographicArrayToCartesianArray(positions);
 */
-(NSArray *)cartographicArrayToCartesianArray:(NSArray *)cartographicArray;

/**
 * Converts the provided cartesian to cartographic representation.
 * The cartesian is undefined at the center of the ellipsoid.
 * @memberof Ellipsoid
 *
 * @param {Cartesian3} cartesian The Cartesian position to convert to cartographic representation.
 * @param {Cartographic} [result] The object onto which to store the result.
 * @returns {Cartographic} The modified result parameter, new Cartographic instance if none was provided, or undefined if the cartesian is at the center of the ellipsoid.
 *
 * @example
 * //Create a Cartesian and determine it's Cartographic representation on a WGS84 ellipsoid.
 * var position = new Cesium.Cartesian(17832.12, 83234.52, 952313.73);
 * var cartographicPosition = Cesium.Ellipsoid.WGS84.cartesianToCartographic(position);
 */
-(CSCartographic *)cartesianToCartographic:(Cartesian3 *)cartesian3;

/**
 * Converts the provided array of cartesians to an array of cartographics.
 * @memberof Ellipsoid
 *
 * @param {Cartesian3[]} cartesians An array of Cartesian positions.
 * @param {Cartographic[]} [result] The object onto which to store the result.
 * @returns {Cartographic[]} The modified result parameter or a new Array instance if none was provided.
 *
 * @example
 * //Create an array of Cartesians and determine their Cartographic representation on a WGS84 ellipsoid.
 * var positions = [new Cesium.Cartesian3(17832.12, 83234.52, 952313.73),
 *                  new Cesium.Cartesian3(17832.13, 83234.53, 952313.73),
 *                  new Cesium.Cartesian3(17832.14, 83234.54, 952313.73)]
 * var cartographicPositions = Cesium.Ellipsoid.WGS84.cartesianArrayToCartographicArray(positions);
 */
-(NSArray *)cartesianArrayToCartographicArray:(NSArray *)cartesianArray;

/**
 * Scales the provided Cartesian position along the geodetic surface normal
 * so that it is on the surface of this ellipsoid.  If the position is
 * at the center of the ellipsoid, this function returns undefined.
 * @memberof Ellipsoid
 *
 * @param {Cartesian3} cartesian The Cartesian position to scale.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter, a new Cartesian3 instance if none was provided, or undefined if the position is at the center.
 */
-(Cartesian3 *)scaleToGeodeticSurface:(Cartesian3 *)position;

/**
 * Scales the provided Cartesian position along the geocentric surface normal
 * so that it is on the surface of this ellipsoid.
 * @memberof Ellipsoid
 *
 * @param {Cartesian3} cartesian The Cartesian position to scale.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if none was provided.
 */
-(Cartesian3 *)scaleToGeocentricSurface:(Cartesian3 *)cartesian;

/**
 * Transforms a Cartesian X, Y, Z position to the ellipsoid-scaled space by multiplying
 * its components by the result of {@link Ellipsoid#oneOverRadii}.
 *
 * @memberof Ellipsoid
 *
 * @param {Cartesian3} position The position to transform.
 * @param {Cartesian3} [result] The position to which to copy the result, or undefined to create and
 *        return a new instance.
 * @returns {Cartesian3} The position expressed in the scaled space.  The returned instance is the
 *          one passed as the result parameter if it is not undefined, or a new instance of it is.
 */
-(Cartesian3 *)transformPositionToScaledSpace:(Cartesian3 *)position;

/**
 * Compares this Ellipsoid against the provided Ellipsoid componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 * @memberof Ellipsoid
 *
 * @param {Ellipsoid} [right] The other Ellipsoid.
 * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
 */
-(BOOL)equals:(CSEllipsoid *)other;

@end


