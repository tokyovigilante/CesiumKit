//
//  CSRectangle.m
//  CesiumKit
//
//  Created by Ryan Walklin on 11/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSRectangle.h"

#import "CSCartographic.h"
#import "CSEllipsoid.h"
#import "CSMath.h"

@implementation CSRectangle

-(instancetype)initWithWest:(Float64)west south:(Float64)south east:(Float64)east north:(Float64)north
{
    self = [super init];
    if (self)
    {
        _west = west;
        _south = south;
        _east = east;
        _north = north;
        [self validate];
    }
    return self;
}

-(CSRectangle *)rectangleWithDegreesWest:(Float64)west south:(Float64)south east:(Float64)east north:(Float64)north
{
    return [[CSRectangle alloc] initWithWest:[CSMath toRadians:west]
                                       south:[CSMath toRadians:south]
                                        east:[CSMath toRadians:east]
                                       north:[CSMath toRadians:north]];
}

-(CSRectangle *)rectangleWithCartographicArray:(NSArray *)cartographics
{
    NSAssert(cartographics != nil, @"Must provide cartographics");
    
    Float64 minLon = DBL_MAX;
    Float64 maxLon = -DBL_MAX;
    Float64 minLat = DBL_MAX;
    Float64 maxLat = -DBL_MAX;
    
    for (CSCartographic *cartographic in cartographics)
    {
        minLon = MIN(minLon, cartographic.longitude);
        maxLon = MAX(maxLon, cartographic.longitude);
        minLat = MIN(minLat, cartographic.latitude);
        maxLat = MAX(maxLat, cartographic.latitude);
    }
    
    return [[CSRectangle alloc] initWithWest:minLon south:minLat east:maxLon north:maxLat];
}

//Rectangle.packedLength = 4;

//Rectangle.pack = function(value, array, startingIndex)

//Rectangle.unpack = function(array, startingIndex, result) {

/**
 * Compares the provided Rectangle with this Rectangle componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 * @memberof Rectangle
 *
 * @param {Rectangle} [other] The Rectangle to compare.
 * @returns {Boolean} <code>true</code> if the Rectangles are equal, <code>false</code> otherwise.
 */
-(BOOL)equals:(CSRectangle *)other
{
    NSAssert(other != nil, @"Need comparison object");
    return (self.west == other.west &&
            self.south == other.south &&
            self.east == other.east &&
            self.north == other.north);
}

/**
 * Compares the provided Rectangle with this Rectangle componentwise and returns
 * <code>true</code> if they are within the provided epsilon,
 * <code>false</code> otherwise.
 * @memberof Rectangle
 *
 * @param {Rectangle} [other] The Rectangle to compare.
 * @param {Number} epsilon The epsilon to use for equality testing.
 * @returns {Boolean} <code>true</code> if the Rectangles are within the provided epsilon, <code>false</code> otherwise.
 */
-(BOOL)equals:(CSRectangle *)other epsilon:(Float64)epsilon
{
    return ((ABS(self.west - other.west) <= epsilon) &&
            (ABS(self.south - other.south) <= epsilon) &&
            (ABS(self.east - other.east) <= epsilon) &&
            (ABS(self.north - other.north) <= epsilon));
}

-(void)validate
{
    NSAssert(_north > -M_PI_2 && _north < M_PI_2, @"north must be in the interval [-Pi/2, Pi/2].");
    NSAssert(_south > -M_PI_2 && _south < M_PI_2, @"south must be in the interval [-Pi/2, Pi/2].");
    NSAssert(_west > -M_PI && _west < M_PI, @"west must be in the interval [-Pi, Pi].");
    NSAssert(_east > -M_PI && _east < M_PI, @"east must be in the interval [-Pi, Pi].");
}

-(CSCartographic *)southwest
{
    return [[CSCartographic alloc] initWithLatitude:self.south longitude:self.west];
}

-(CSCartographic *)northwest
{
    return [[CSCartographic alloc] initWithLatitude:self.north longitude:self.west];
}

-(CSCartographic *)northeast
{
    return [[CSCartographic alloc] initWithLatitude:self.north longitude:self.east];
}

-(CSCartographic *)southeast
{
    return [[CSCartographic alloc] initWithLatitude:self.south longitude:self.east];
}

-(CSCartographic *)center
{
    return [[CSCartographic alloc] initWithLatitude:(self.south + self.north) * 0.5 longitude:(self.west + self.east) * 0.5];
}

-(CSRectangle *)intersectWith:(CSRectangle *)other
{
    NSAssert(other != nil, @"Need comparison object");

    return [[CSRectangle alloc] initWithWest:MAX(self.west, other.west)
                                       south:MAX(self.south, other.south)
                                        east:MAX(self.east, other.east)
                                       north:MAX(self.north, other.north)];
}

-(BOOL)contains:(CSCartographic *)cartographic
{
    NSAssert(cartographic != nil, @"Need cartographic object");

    return (cartographic.longitude >= self.west &&
            cartographic.longitude <= self.east &&
            cartographic.latitude >= self.south &&
            cartographic.latitude <= self.north);
}

-(BOOL)isEmpty
{
    return self.west >= self.east || self.south >= self.north;
}

/**
 * Samples an rectangle so that it includes a list of Cartesian points suitable for passing to
 * {@link BoundingSphere#fromPoints}.  Sampling is necessary to account
 * for rectangles that cover the poles or cross the equator.
 *
 * @param {Rectangle} rectangle The rectangle to subsample.
 * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid to use.
 * @param {Number} [surfaceHeight=0.0] The height of the rectangle above the ellipsoid.
 * @param {Cartesian3[]} [result] The array of Cartesians onto which to store the result.
 * @returns {Cartesian3[]} The modified result parameter or a new Array of Cartesians instances if none was provided.
 */
-(NSArray *)subsample:(CSEllipsoid *)ellipsoid surfaceHeight:(Float64)surfaceHeight
{
    if (!ellipsoid)
    {
        ellipsoid = [CSEllipsoid wgs84Ellipsoid];
    }

    NSMutableArray *result = [NSMutableArray array];
    
    //CSCartographic *lla =
    
    // NW
    [result addObject:[ellipsoid cartographicToCartesian:[[CSCartographic alloc] initWithLatitude:self.north
                                                                                        longitude:self.west
                                                                                           height:surfaceHeight]]];
    // NE
    [result addObject:[ellipsoid cartographicToCartesian:[[CSCartographic alloc] initWithLatitude:self.north
                                                                                        longitude:self.east
                                                                                           height:surfaceHeight]]];
    
    // SE
    [result addObject:[ellipsoid cartographicToCartesian:[[CSCartographic alloc] initWithLatitude:self.south
                                                                                        longitude:self.east
                                                                                           height:surfaceHeight]]];
    
    // SW
    [result addObject:[ellipsoid cartographicToCartesian:[[CSCartographic alloc] initWithLatitude:self.south
                                                                                        longitude:self.west
                                                                                           height:surfaceHeight]]];

    Float64 latitude;
    
    if (self.north < 0.0)
    {
        latitude = self.north;
    }
    else if (self.south > 0.0)
    {
        latitude = self.south;
    }
    else
    {
        latitude = 0.0;
    }
    
    for (UInt32 i=1; i<8; ++i)
    {
        Float64 temp = -M_PI + i * M_PI_2;
        if (self.west < temp && temp < self.east)
        {
            [result addObject:[ellipsoid cartographicToCartesian:[[CSCartographic alloc] initWithLatitude:latitude
                                                                                                longitude:temp
                                                                                                   height:surfaceHeight]]];
        }
    }
    if (latitude == 0.0)
    {
        [result addObject:[ellipsoid cartographicToCartesian:[[CSCartographic alloc] initWithLatitude:latitude
                                                                                            longitude:self.west
                                                                                               height:surfaceHeight]]];

        [result addObject:[ellipsoid cartographicToCartesian:[[CSCartographic alloc] initWithLatitude:latitude
                                                                                            longitude:self.east
                                                                                               height:surfaceHeight]]];
    }
    return result;
}

+(CSRectangle *)maxValue
{
    return [[CSRectangle alloc] initWithWest:-M_PI south:-M_PI_2 east:M_PI north:M_PI_2];
}

/**
 * Duplicates an Rectangle.
 *
 * @memberof Rectangle
 *
 * @param {Rectangle} rectangle The rectangle to clone.
 * @param {Rectangle} [result] The object onto which to store the result, or undefined if a new instance should be created.
 * @returns {Rectangle} The modified result parameter or a new Rectangle instance if none was provided. (Returns undefined if rectangle is undefined)
 */
-(instancetype)copyWithZone:(NSZone *)zone
{
    return [[CSRectangle alloc] initWithWest:self.west south:self.south east:self.east north:self.north];
}

@end
