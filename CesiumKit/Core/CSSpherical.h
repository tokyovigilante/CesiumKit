//
//  CSSpherical.h
//  CesiumKit
//
//  Created by Ryan Walklin on 4/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

/**
 * A set of curvilinear 3-dimensional coordinates.
 *
 * @alias Spherical
 * @constructor
 *
 * @param {Number} [clock=0.0] The angular coordinate lying in the xy-plane measured from the positive x-axis and toward the positive y-axis.
 * @param {Number} [cone=0.0] The angular coordinate measured from the positive z-axis and toward the negative z-axis.
 * @param {Number} [magnitude=1.0] The linear coordinate measured from the origin.
 */

@import Foundation;

@class CSCartesian3D;


@interface CSSpherical : NSObject <NSCopying>

@property (readonly) Float64 clock; // azimuth
@property (readonly) Float64 cone; // inclination
@property (readonly) Float64 magnitude; // radius

-(id)initWithClock:(Float64)clock cone:(Float64)cone magnitude:(Float64)magnitude;

/**
 * Converts the provided Cartesian3 into Spherical coordinates.
 * @memberof Spherical
 *
 * @param {Cartesian3} cartesian3 The Cartesian3 to be converted to Spherical.
 * @param {Spherical} [spherical] The object in which the result will be stored, if undefined a new instance will be created.
 *
 * @returns The modified result parameter, or a new instance if one was not provided.
 */
+(CSSpherical *)sphericalFromCartesian3:(CSCartesian3D *)cartesian3;

/**
 * Computes the normalized version of the provided spherical.
 * @memberof Spherical
 *
 * @param {Spherical} spherical The spherical to be normalized.
 *
 * @returns The modified result parameter
 */
-(CSSpherical *)normalise;

    
/**
 * Returns YES if the  spherical is equal to the second spherical, NO otherwise.
 * @memberof Spherical
 *
 * @param {Spherical} other The second Spherical to be compared.
 *
 */
-(BOOL)equals:(CSSpherical *)other;

/**
 * Returns YES if the  spherical is within the provided epsilon of the second spherical, NO otherwise.
 * @memberof Spherical
 *
 * @param {Spherical} right The second Spherical to be compared.
 * @param {Number} [epsilon=0.0] The epsilon to compare against.
 *
 * @returns true if the first spherical is within the provided epsilon of the  spherical, false otherwise.
 */
-(BOOL)equals:(CSSpherical *)other epsilon:(Float64)epsilon;

-(NSString *)description;

@end
