//
//  CSWebMercatorTilingScheme.m
//  CesiumKit
//
//  Created by Ryan Walklin on 30/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSWebMercatorTilingScheme.h"

#import "Ellipsoid.h"
#import "CSWebMercatorProjection.h"
#import "CSCartesian2.h"
#import "Cartesian3.h"
#import "CSCartographic.h"
#import "CSRectangle.h"

@interface CSWebMercatorTilingScheme ()

@property (readonly) Cartesian3 *rectangleSouthwestInMeters;
@property (readonly) Cartesian3 *rectangleNortheastInMeters;

@end


@implementation CSWebMercatorTilingScheme

-(instancetype)initWithOptions:(NSDictionary *)options
{
    self = [super initWithOptions:options];
    if (self)
    {
        _ellipsoid = options[@"ellipsoid"];
        if (!_ellipsoid)
        {
            _ellipsoid = [Ellipsoid wgs84Ellipsoid];
        }
        NSNumber *numberOfLevelZeroTilesX = options[@"numberOfLevelZeroTilesX"];
        if (numberOfLevelZeroTilesX)
        {
            _numberOfLevelZeroTilesX = numberOfLevelZeroTilesX.unsignedIntValue;
        }
        else
        {
            _numberOfLevelZeroTilesX = 1;
        }
        NSNumber *numberOfLevelZeroTilesY = options[@"numberOfLevelZeroTilesY"];
        if (numberOfLevelZeroTilesY)
        {
            _numberOfLevelZeroTilesY = numberOfLevelZeroTilesY.unsignedIntValue;
        }
        else
        {
            _numberOfLevelZeroTilesY = 1;
        }
        _projection = [[CSWebMercatorProjection alloc] initWithEllipsoid:_ellipsoid];
        
        Float64 semimajorAxisTimesPi = _ellipsoid.maximumRadius * M_PI;
        _rectangleSouthwestInMeters = options[@"rectangleSouthwestInMeters"];
        if (!_rectangleSouthwestInMeters)
        {
            _rectangleSouthwestInMeters = [[Cartesian3 alloc] initWithX:-semimajorAxisTimesPi Y:-semimajorAxisTimesPi Z:0.0];
        }
        _rectangleNortheastInMeters = options[@"rectangleNortheastInMeters"];
        if (!_rectangleNortheastInMeters)
        {
            _rectangleNortheastInMeters = [[Cartesian3 alloc] initWithX:semimajorAxisTimesPi Y:semimajorAxisTimesPi Z:0.0];
        }
        
        CSCartographic *southWest = [_projection unproject:_rectangleSouthwestInMeters];
        CSCartographic *northEast = [_projection unproject:_rectangleNortheastInMeters];
        _rectangle = [[CSRectangle alloc] initWithWest:southWest.longitude south:southWest.latitude east:northEast.longitude north:northEast.latitude];

    }
    return self;
}

-(CSRectangle *)rectangleToNativeRectangle:(CSRectangle *)rectangle
{
    NSAssert(rectangle != nil, @"no rectangle");
    
    Cartesian3 *southwest = [self.projection project:rectangle.southwest];
    Cartesian3 *northeast = [self.projection project:rectangle.southeast];

    return [[CSRectangle alloc] initWithWest:southwest.x south:southwest.y east:northeast.x north:northeast.y];
}

-(CSRectangle *)tileToNativeRectangleX:(UInt32)x Y:(UInt32)y level:(UInt32)level
{
    UInt32 xTiles = [self numberOfXTilesAtLevel:level];
    UInt32 yTiles = [self numberOfYTilesAtLevel:level];
    
    Float64 xTileWidth = (self.rectangleNortheastInMeters.x - self.rectangleSouthwestInMeters.x) / xTiles;
    Float64 west = self.rectangleSouthwestInMeters.x + x * xTileWidth;
    Float64 east = self.rectangleSouthwestInMeters.x + (x + 1) * xTileWidth;
    
    Float64 yTileHeight = (self.rectangleNortheastInMeters.y - self.rectangleSouthwestInMeters.y) / yTiles;
    Float64 north = self.rectangleNortheastInMeters.y - y * yTileHeight;
    Float64 south = self.rectangleNortheastInMeters.y - (y + 1) * yTileHeight;
    
    return [[CSRectangle alloc] initWithWest:west south:south east:east north:north];
}

-(CSRectangle *)tileToRectangleX:(UInt32)x Y:(UInt32)y level:(UInt32)level;
{
    CSRectangle *nativeRectangle = [self tileToNativeRectangleX:x Y:y level:level];
    
    CSCartographic *southwest = [self.projection unproject:[[Cartesian3 alloc] initWithX:nativeRectangle.west Y:nativeRectangle.south Z:0]];
    CSCartographic *northeast = [self.projection unproject:[[Cartesian3 alloc] initWithX:nativeRectangle.east Y:nativeRectangle.north Z:0]];

    return [[CSRectangle alloc] initWithWest:southwest.longitude south:southwest.latitude east:northeast.longitude north:northeast.latitude];
}

-(CSCartesian2 *)positionToTileXY:(CSCartographic *)position level:(UInt32)level
{
    if (position.latitude > self.rectangle.north ||
        position.latitude < self.rectangle.south ||
        position.longitude < self.rectangle.west ||
        position.longitude > self.rectangle.east) {
        // outside the bounds of the tiling scheme
        return nil;
    }
    
    UInt32 xTiles = [self numberOfXTilesAtLevel:level];
    UInt32 yTiles = [self numberOfYTilesAtLevel:level];
    
    Float64 overallWidth = self.rectangleNortheastInMeters.x - self.rectangleSouthwestInMeters.x;
    Float64 xTileWidth = overallWidth / xTiles;
    Float64 overallHeight = self.rectangleNortheastInMeters.y - self.rectangleSouthwestInMeters.y;
    Float64 yTileHeight = overallHeight / yTiles;
    
    Cartesian3 *webMercatorPosition = [self.projection project:position];

    Float64 distanceFromWest = webMercatorPosition.x - self.rectangleSouthwestInMeters.x;
    Float64 distanceFromNorth = self.rectangleNortheastInMeters.y - webMercatorPosition.y;
    
    UInt32 xTileCoordinate = (UInt32)(trunc(distanceFromWest / xTileWidth)) | 0;
    if (xTileCoordinate >= xTiles)
    {
        xTileCoordinate = xTiles - 1;
    }
    UInt32 yTileCoordinate = (UInt32)(distanceFromNorth / yTileHeight) | 0;
    if (yTileCoordinate >= yTiles)
    {
        yTileCoordinate = yTiles - 1;
    }
    
    return [[CSCartesian2 alloc] initWithX:xTileCoordinate Y:yTileCoordinate];
}

@end
