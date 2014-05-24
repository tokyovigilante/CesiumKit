//
//  CSWebMercatorProjection.h
//  CesiumKit
//
//  Created by Ryan Walklin on 5/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSProjection.h"

@class CSEllipsoid, CSCartesian3, CSCartographic;

@interface CSWebMercatorProjection : CSProjection

/**
 * Converts a Mercator angle, in the range -PI to PI, to a geodetic latitude
 * in the range -PI/2 to PI/2.
 *
 * @memberof WebMercatorProjection
 *
 * @param {Number} mercatorAngle The angle to convert.
 * @returns {Number} The geodetic latitude in radians.
 */
-(Float64)mercatorAngleToGeodeticLatitude:(Float64)angle;


/**
 * Converts a geodetic latitude in radians, in the range -PI/2 to PI/2, to a Mercator
 * angle in the range -PI to PI.
 *
 * @memberof WebMercatorProjection
 *
 * @param {Number} latitude The geodetic latitude in radians.
 * @returns {Number} The Mercator angle.
 */
-(Float64)geodeticLatitudeToMercatorAngle:(Float64)latitude;

/**
 * The maximum latitude (both North and South) supported by a Web Mercator
 * (EPSG:3857) projection.  Technically, the Mercator projection is defined
 * for any latitude up to (but not including) 90 degrees, but it makes sense
 * to cut it off sooner because it grows exponentially with increasing latitude.
 * The logic behind this particular cutoff value, which is the one used by
 * Google Maps, Bing Maps, and Esri, is that it makes the projection
 * square.  That is, the rectangle is equal in the X and Y directions.
 *
 * The constant value is computed by calling:
 *    WebMercatorProjection.mercatorAngleToGeodeticLatitude(Math.PI)
 *
 * @memberof WebMercatorProjection
 *
 * @type {Number}
 */
-(Float64)maximumLatitude;


@end
