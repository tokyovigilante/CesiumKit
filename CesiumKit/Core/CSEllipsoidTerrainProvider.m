//
//  CSEllipsoidTerrainProvider.m
//  CesiumKit
//
//  Created by Ryan Walklin on 30/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSEllipsoidTerrainProvider.h"

#import "CSGeographicTilingScheme.h"
#import "CSWebMercatorTilingScheme.h"
#import "CSHeightMapTerrainData.h"
#import "CSUInt8Array.h"

@interface CSEllipsoidTerrainProvider () {
    Float64 _levelZeroMaximumGeometricError;
}

@property CSTerrainData *terrainData;

@end

@implementation CSEllipsoidTerrainProvider

-(instancetype)initWithOptions:(NSDictionary *)options
{
    self = [super initWithOptions:options];
    if (self)
    {
        _tilingScheme = options[@"tilingScheme"];
        if (!_tilingScheme)
        {
            _tilingScheme = [[CSGeographicTilingScheme alloc] initWithOptions:nil];
        }
        // Note: the 64 below does NOT need to match the actual vertex dimensions, because
        // the ellipsoid is significantly smoother than actual terrain.
        _levelZeroMaximumGeometricError = [self getEstimatedLevelZeroGeometricErrorForAHeightmapWithEllipsoid:_tilingScheme.ellipsoid
                                                                                               tileImageWidth:64
                                                                                     numberOfTilesAtLevelZero:_tilingScheme.numberOfLevelZeroTilesX];
        
        _terrainData = [[CSHeightMapTerrainData alloc] initWithOptions: @{@"buffer": [[CSUInt8Array alloc] initWithCapacity:16 * 16],
                                                                          @"width" : @16,
                                                                          @"height" : @16 }];

        _asyncError = nil;
        _credit = @"Test Toast";
        _hasWaterMask = NO;
    }
    return self;
}

-(CSTerrainData *)requestTileGeometryX:(UInt32)x Y:(UInt32)y level:(UInt32)level throttle:(BOOL)throttle
{
    return _terrainData;
}

-(Float64)getMaximumGeometricErrorForLevel:(UInt32)level
{
    return _levelZeroMaximumGeometricError / (1 << level);
}

@end



