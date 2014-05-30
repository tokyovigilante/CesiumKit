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
        
        _terrainData = [[CSHeightMapTerrainData alloc] initWithOptions: @{@"buffer": [[CSUint8Array alloc] initWithCapacity:16 * 16],
                                                                          @"width" : 16,
                                                                          @"height" : 16 }];

        _errorEvent = nil;
    }
}

@end



        

        

    };
    

    
    /**
     * Requests the geometry for a given tile.  This function should not be called before
     * {@link TerrainProvider#ready} returns true.  The result includes terrain
     * data and indicates that all child tiles are available.
     *
     * @memberof EllipsoidTerrainProvider
     *
     * @param {Number} x The X coordinate of the tile for which to request geometry.
     * @param {Number} y The Y coordinate of the tile for which to request geometry.
     * @param {Number} level The level of the tile for which to request geometry.
     * @param {Boolean} [throttleRequests=true] True if the number of simultaneous requests should be limited,
     *                  or false if the request should be initiated regardless of the number of requests
     *                  already in progress.
     * @returns {Promise|TerrainData} A promise for the requested geometry.  If this method
     *          returns undefined instead of a promise, it is an indication that too many requests are already
     *          pending and the request will be retried later.
     */
    EllipsoidTerrainProvider.prototype.requestTileGeometry = function(x, y, level, throttleRequests) {
        return this._terrainData;
    };
    
    /**
     * Gets the maximum geometric error allowed in a tile at a given level.
     *
     * @memberof EllipsoidTerrainProvider
     *
     * @param {Number} level The tile level for which to get the maximum geometric error.
     * @returns {Number} The maximum geometric error.
     */
    EllipsoidTerrainProvider.prototype.getLevelMaximumGeometricError = function(level) {
        return this._levelZeroMaximumGeometricError / (1 << level);
    };
    
    /**
     * Gets a value indicating whether or not the provider includes a water mask.  The water mask
     * indicates which areas of the globe are water rather than land, so they can be rendered
     * as a reflective surface with animated waves.
     *
     * @memberof EllipsoidTerrainProvider
     *
     * @returns {Boolean} True if the provider has a water mask; otherwise, false.
     */
    EllipsoidTerrainProvider.prototype.hasWaterMask = function() {
        return false;
    };
    
    return EllipsoidTerrainProvider;
});