//
//  CSTerrainProvider.m
//  CesiumKit
//
//  Created by Ryan Walklin on 30/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSTerrainProvider.h"

#import "CSUInt16Array.h"
#import "CSEllipsoid.h"

@interface CSTerrainProvider () {
    NSMutableDictionary *_regularGridIndexArrays; // each object in dict is indexed NSMutableDictionary containing UInt16Array of vertices (phew!)
}

@end

@implementation CSTerrainProvider

-(instancetype)initWithOptions:(NSDictionary *)options
{
    self = [super init];
    if (self)
    {
        _ready = NO;
        _heightmapTerrainQuality = 0.25;
        _regularGridIndexArrays = [NSMutableDictionary dictionary];
        _hasWaterMask = NO;
    }
    return self;
}

-(CSUInt16Array *)getRegularGridIndicesForWidth:(UInt32)width height:(UInt32)height
{
    NSAssert(width * height < 64 * 1024, @"The total number of vertices (width * height) must be less than or equal to 65536");
    
    NSNumber *widthNumber = [NSNumber numberWithUnsignedInt:width];
    NSNumber *heightNumber = [NSNumber numberWithUnsignedInt:height];
    
    NSMutableDictionary *byWidth = _regularGridIndexArrays[widthNumber];
    if (!byWidth)
    {
        _regularGridIndexArrays[widthNumber] = byWidth = [NSMutableDictionary dictionary];
    }
    
    CSUInt16Array *indices = byWidth[heightNumber];
    
    if (!indices)
    {
        UInt64 indicesCount = (width - 1) * (height - 1) * 6;
        UInt16 indicesData[indicesCount];
        
        UInt32 index = 0;
        UInt32 indicesIndex = 0;
        UInt16 upperLeft, lowerLeft, lowerRight, upperRight;
        
        for (UInt32 i=0; i < height - 1; i++)
        {
            for (UInt32 j=0; j < width - 1; j++)
            {
                upperLeft = index;
                lowerLeft = upperLeft + width;
                lowerRight = lowerLeft + 1;
                upperRight = upperLeft + 1;
                
                indicesData[indicesIndex++] = upperLeft;
                indicesData[indicesIndex++] = lowerLeft;
                indicesData[indicesIndex++] = upperRight;
                indicesData[indicesIndex++] = upperRight;
                indicesData[indicesIndex++] = lowerLeft;
                indicesData[indicesIndex++] = lowerRight;
                
                ++index;
            }
        }
        indices = [[CSUInt16Array alloc] initWithValues:indicesData length:indicesCount];
    }
    return indices;
};

-(Float64)getEstimatedLevelZeroGeometricErrorForAHeightmapWithEllipsoid:(CSEllipsoid *)ellipsoid
                                                         tileImageWidth:(Float64)tileImageWidth
                                               numberOfTilesAtLevelZero:(UInt32)numberOfTilesAtLevelZero
{
    return ellipsoid.maximumRadius * 2 * M_PI * self.heightmapTerrainQuality / (tileImageWidth * numberOfTilesAtLevelZero);
}

-(void)requestTileGeometryX:(UInt32)x Y:(UInt32)y level:(UInt32)level throttle:(BOOL)throttle completionBlock:(void (^)(CSTerrainData *terrainData))completionBlock;
{
    NSAssert(NO, @"Invalid base class");
}

-(Float64)getMaximumGeometricErrorForLevel:(UInt32)level
{
    NSAssert(NO, @"Invalid base class");
    return 0.0;
}

-(BOOL)hasWaterMask
{
    NSAssert(NO, @"Invalid base class");
    return NO;
}

@end
