//
//  CSRay.h
//  CesiumKit
//
//  Created by Ryan Walklin on 10/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;

@class CSCartesian3;
/**
 * Represents a ray that extends infinitely from the provided origin in the provided direction.
 * @alias Ray
 * @constructor
 *
 * @param {Cartesian3} [origin=Cartesian3.ZERO] The origin of the ray.
 * @param {Cartesian3} [direction=Cartesian3.ZERO] The direction of the ray.
 */

@interface CSRay : NSObject

@property (readonly) CSCartesian3 *origin;
@property (readonly) CSCartesian3 *direction;

-(id)initWithOrigin:(CSCartesian3 *)origin direction:(CSCartesian3 *)direction;

/**
 * Computes the point along the ray given by r(t) = o + t*d,
 * where o is the origin of the ray and d is the direction.
 * @memberof Ray
 *
 * @param {Number} t A scalar value.
 * @param {Cartesian3} [result] The object in which the result will be stored.
 * @returns The modified result parameter, or a new instance if none was provided.
 *
 * @example
 * //Get the first intersection point of a ray and an ellipsoid.
 * var intersection = Cesium.IntersectionTests.rayEllipsoid(ray, ellipsoid);
 * var point = Ray.getPoint(ray, intersection.start);
 */
-(CSCartesian3 *)getPoint:(Float64)t;

@end
