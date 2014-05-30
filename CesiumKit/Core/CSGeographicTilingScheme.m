//
//  CSGeographicTilingScheme.m
//  CesiumKit
//
//  Created by Ryan Walklin on 30/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSGeographicTilingScheme.h"
#import "CSEllipsoid.h"
#import "CSRectangle.h"
#import "CSGeographicProjection.h"
#import "CSMath.h"
#import "CSCartesian2.h"
#import "CSCartographic.h"

@implementation CSGeographicTilingScheme

-(instancetype)initWithOptions:(NSDictionary *)options
{
    self = [super initWithOptions:options];
    if (self)
    {
        _ellipsoid = options[@"ellipsoid"];
        if (!_ellipsoid)
        {
            _ellipsoid = [CSEllipsoid wgs84Ellipsoid];
        }
        _rectangle = options[@"rectangle"];
        if (!_rectangle)
        {
            _rectangle = [CSRectangle maxValue];
        }
        NSNumber *numberOfLevelZeroTilesX = options[@"numberOfLevelZeroTilesX"];
        if (numberOfLevelZeroTilesX)
        {
            _numberOfLevelZeroTilesX = numberOfLevelZeroTilesX.unsignedIntValue;
        }
        else
        {
            _numberOfLevelZeroTilesX = 2;
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
        _projection = [[CSGeographicProjection alloc] initWithEllipsoid:_ellipsoid];
    }
    return self;
}

-(CSRectangle *)rectangleToNativeRectangle:(CSRectangle *)rectangle
{
    NSAssert(rectangle != nil, @"no rectangle");

    return [[CSRectangle alloc] initWithWest:[CSMath toDegrees:rectangle.west]
                                       south:[CSMath toDegrees:rectangle.south]
                                        east:[CSMath toDegrees:rectangle.east]
                                       north:[CSMath toDegrees:rectangle.north]];
}

-(CSRectangle *)tileToNativeRectangleX:(UInt32)x Y:(UInt32)y level:(UInt32)level
{
    CSRectangle *rectangleRadians = [self tileToRectangleX:x Y:y level:level];
    
    return [[CSRectangle alloc] initWithWest:[CSMath toDegrees:rectangleRadians.west]
                                       south:[CSMath toDegrees:rectangleRadians.south]
                                        east:[CSMath toDegrees:rectangleRadians.east]
                                       north:[CSMath toDegrees:rectangleRadians.north]];
}

-(CSRectangle *)tileToRectangleX:(UInt32)x Y:(UInt32)y level:(UInt32)level
{
    UInt32 xTiles = [self numberOfXTilesAtLevel:level];
    UInt32 yTiles = [self numberOfYTilesAtLevel:level];
    
    Float64 xTileWidth = (self.rectangle.east - self.rectangle.west) / xTiles;
    Float64 west = x * xTileWidth + self.rectangle.west;
    Float64 east = (x + 1) * xTileWidth + self.rectangle.west;
    
    Float64 yTileHeight = (self.rectangle.north - self.rectangle.south) / yTiles;
    Float64 north = self.rectangle.north - y * yTileHeight;
    Float64 south = self.rectangle.north - (y + 1) * yTileHeight;
    
    return [[CSRectangle alloc] initWithWest:west south:south east:east north:north];
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
    
    Float64 xTileWidth = (self.rectangle.east - self.rectangle.west) / xTiles;
    Float64 yTileHeight = (self.rectangle.north - self.rectangle.south) / yTiles;
    
    
    UInt32 xTileCoordinate = (UInt32)(trunc((position.longitude - self.rectangle.west) / xTileWidth)) | 0;
    if (xTileCoordinate >= xTiles)
    {
        xTileCoordinate = xTiles - 1;
    }
    
    UInt32 yTileCoordinate = (UInt32)(trunc((self.rectangle.north - position.latitude) / yTileHeight)) | 0;
    if (yTileCoordinate >= yTiles)
    {
        yTileCoordinate = yTiles - 1;
    }
    return [[CSCartesian2 alloc] initWithX:xTileCoordinate Y:yTileCoordinate];
}

@end



