//
//  CSMath.h
//  CesiumKit
//
//  Created by Ryan Walklin on 18/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import <Foundation/Foundation.h>

static const Float64 CSEpsilon1 = 0.1;
static const Float64 CSEpsilon2 = 0.01;
static const Float64 CSEpsilon3 = 0.001;
static const Float64 CSEpsilon4 = 0.0001;
static const Float64 CSEpsilon5 = 0.00001;
static const Float64 CSEpsilon6 = 0.000001;
static const Float64 CSEpsilon7 = 0.0000001;
static const Float64 CSEpsilon8 = 0.00000001;
static const Float64 CSEpsilon9 = 0.000000001;
static const Float64 CSEpsilon10 = 0.0000000001;
static const Float64 CSEpsilon11 = 0.00000000001;
static const Float64 CSEpsilon12 = 0.000000000001;
static const Float64 CSEpsilon13 = 0.0000000000001;
static const Float64 CSEpsilon14 = 0.00000000000001;
static const Float64 CSEpsilon15 = 0.000000000000001;
static const Float64 CSEpsilon16 = 0.0000000000000001;
static const Float64 CSEpsilon17 = 0.00000000000000001;
static const Float64 CSEpsilon18 = 0.000000000000000001;
static const Float64 CSEpsilon19 = 0.0000000000000000001;
static const Float64 CSEpsilon20 = 0.00000000000000000001;

@interface CSMath : NSObject

/**
 * Returns the sign of the value; 1 if the value is positive, -1 if the value is
 * negative, or 0 if the value is 0.
 *
 * @param {Number} value The value to return the sign of.
 *
 * @returns {Number} The sign of value.
 */
+(UInt32)sign:(Float64)value;

+(Float64)clampValue:(Float64)value min:(Float64)min max:(Float64)max;

/**
 * Converts degrees to radians.
 * @param {Number} degrees The angle to convert in degrees.
 * @returns {Number} The corresponding angle in radians.
 */
+(Float64)toRadians:(Float64)degrees;

/**
 * Converts radians to degrees.
 * @param {Number} radians The angle to convert in radians.
 * @returns {Number} The corresponding angle in degrees.
 */
+(Float64)toDegrees:(Float64)radians;

@end
