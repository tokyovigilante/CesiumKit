//
//  CSProjection.m
//  CesiumKit
//
//  Created by Ryan Walklin on 8/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSProjection.h"
#import "CSProjection+Private.h"

#import "CSEllipsoid.h"

@implementation CSProjection

-(id)initWithEllipsoid:(CSEllipsoid *)ellipsoid
{
    self = [super init];
    if (self)
    {
        if (!ellipsoid)
        {
            ellipsoid = [CSEllipsoid wgs84Ellipsoid];
        }
        _semimajorAxis = ellipsoid.maximumRadius;
        _oneOverSemimajorAxis = 1.0 / _semimajorAxis;
    }
    return self;
}

/**
 * Converts geodetic ellipsoid coordinates, in radians, to the equivalent Web Mercator
 * X, Y, Z coordinates expressed in meters and returned in a {@link Cartesian3}.  The height
 * is copied unmodified to the Z coordinate.
 *
 * @memberof Projection
 *
 * @param {Cartographic} cartographic The cartographic coordinates in radians.
 * @param {Cartesian3} [result] The instance to which to copy the result, or undefined if a
 *        new instance should be created.
 * @returns {Cartesian3} The equivalent web mercator X, Y, Z coordinates, in meters.
 */
-(CSCartesian3 *)project:(CSCartographic *)cartographic3
{
    NSAssert(YES, @"Invalid base class");
    return nil;
}


/**
 * Converts Web Mercator X, Y coordinates, expressed in meters, to a {@link Cartographic}
 * containing geodetic ellipsoid coordinates.  The Z coordinate is copied unmodified to the
 * height.
 *
 * @memberof Projection
 *
 * @param {Cartesian2} cartesian The web mercator coordinates in meters.
 * @param {Cartographic} [result] The instance to which to copy the result, or undefined if a
 *        new instance should be created.
 * @returns {Cartographic} The equivalent cartographic coordinates.
 */
-(CSCartographic *)unproject:(CSCartesian3 *)cartesian
{
    NSAssert(YES, @"Invalid base class");
    return nil;
}

@end
