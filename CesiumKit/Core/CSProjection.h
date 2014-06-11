//
//  CSProjection.h
//  CesiumKit
//
//  Created by Ryan Walklin on 8/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;

@class Ellipsoid, Cartesian3, CSCartographic;

@interface CSProjection : NSObject

-(id)initWithEllipsoid:(Ellipsoid *)ellipsoid;

/**
 * Converts geodetic ellipsoid coordinates, in radians, to the equivalent
 * X, Y, Z coordinates expressed in meters and returned in a {@link Cartesian3}.  The height
 * is copied unmodified to the Z coordinate.
 *
 * @memberof WebMercatorProjection
 *
 * @param {Cartographic} cartographic The cartographic coordinates in radians.
 * @param {Cartesian3} [result] The instance to which to copy the result, or undefined if a
 *        new instance should be created.
 * @returns {Cartesian3} The equivalent web mercator X, Y, Z coordinates, in meters.
 */
-(Cartesian3 *)project:(CSCartographic *)cartographic;

/**
 * Converts X, Y coordinates, expressed in meters, to a {@link Cartographic}
 * containing geodetic ellipsoid coordinates.  The Z coordinate is copied unmodified to the
 * height.
 *
 * @memberof WebMercatorProjection
 *
 * @param {Cartesian3} cartesian The web mercator coordinates in meters.
 * @param {Cartographic} [result] The instance to which to copy the result, or undefined if a
 *        new instance should be created.
 * @returns {Cartographic} The equivalent cartographic coordinates.
 */
-(CSCartographic *)unproject:(Cartesian3 *)cartesian3;


@end
