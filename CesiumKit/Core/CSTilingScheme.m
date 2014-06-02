//
//  CSTilingScheme.m
//  CesiumKit
//
//  Created by Ryan Walklin on 30/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSTilingScheme.h"

@implementation CSTilingScheme

-(instancetype)initWithOptions:(NSDictionary *)options
{
    self = [super init];
    if (self)
    {
        _ellipsoid = nil;
        _rectangle = nil;
        _projection = nil;
    }
    return self;
}

-(UInt32)numberOfXTilesAtLevel:(UInt32)level
{
    return self.numberOfLevelZeroTilesX << level;
}

-(UInt32)numberOfYTilesAtLevel:(UInt32)level
{
    return self.numberOfLevelZeroTilesY << level;
}

-(CSRectangle *)rectangleToNativeRectangle:(CSRectangle *)rectangle
{
    NSAssert(NO, @"Invalid base class");
    return nil;
}

-(CSRectangle *)tileToNativeRectangleX:(UInt32)x Y:(UInt32)y
{
    NSAssert(NO, @"Invalid base class");
    return nil;
}

-(CSRectangle *)tileToRectangleX:(UInt32)x Y:(UInt32)y
{
    NSAssert(NO, @"Invalid base class");
    return nil;
}

-(CSCartesian2 *)positionToTileXY:(CSCartographic *)position level:(UInt32)level
{
    NSAssert(NO, @"Invalid base class");
    return nil;
    
}

@end
