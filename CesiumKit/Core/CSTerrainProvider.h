//
//  CSTerrainProvider.h
//  CesiumKit
//
//  Created by Ryan Walklin on 30/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

@import Foundation;

@class CSTilingScheme, CSUInt16Array, CSEllipsoid, CSTerrainData;

/**
 * Provides terrain or other geometry for the surface of an ellipsoid.  The surface geometry is
 * organized into a pyramid of tiles according to a {@link TilingScheme}.  This type describes an
 * interface and is not intended to be instantiated directly.
 *
 * @alias TerrainProvider
 * @constructor
 *
 * @see EllipsoidTerrainProvider
 * @see CesiumTerrainProvider
 * @see ArcGisImageServerTerrainProvider
 */
@interface CSTerrainProvider : NSObject {
    NSError *_asyncError;
    NSString *_credit;
    CSTilingScheme *_tilingScheme;
    BOOL _ready;
    BOOL _hasWaterMask;
}

/**
 * Gets an event that is raised when the terrain provider encounters an asynchronous error..  By subscribing
 * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
 * are passed an instance of {@link TileProviderError}.
 * @memberof TerrainProvider.prototype
 * @type {Event}
 */
@property (readonly) NSError *asyncError;
#warning replace with error block

/**
 * Gets the credit to display when this terrain provider is active.  Typically this is used to credit
 * the source of the terrain. This function should
 * not be called before {@link TerrainProvider#ready} returns true.
 * @memberof TerrainProvider.prototype
 * @type {Credit}
 */
@property (readonly) NSString *credit;

/**
 * Gets the tiling scheme used by the provider.  This function should
 * not be called before {@link TerrainProvider#ready} returns true.
 * @memberof TerrainProvider.prototype
 * @type {TilingScheme}
 */
@property (readonly) CSTilingScheme *tilingScheme;

/**
 * Gets a value indicating whether or not the provider is ready for use.
 * @memberof TerrainProvider.prototype
 * @type {Boolean}
 */
@property (readonly) BOOL ready;

/**
 * Specifies the quality of terrain created from heightmaps.  A value of 1.0 will
 * ensure that adjacent heightmap vertices are separated by no more than
 * {@link Globe.maximumScreenSpaceError} screen pixels and will probably go very slowly.
 * A value of 0.5 will cut the estimated level zero geometric error in half, allowing twice the
 * screen pixels between adjacent heightmap vertices and thus rendering more quickly.
 */
@property (nonatomic) Float64 heightmapTerrainQuality;

/**
 * Gets a value indicating whether or not the provider includes a water mask.  The water mask
 * indicates which areas of the globe are water rather than land, so they can be rendered
 * as a reflective surface with animated waves.  This function should not be
 * called before {@link TerrainProvider#ready} returns true.
 * @memberof TerrainProvider
 * @function
 *
 * @returns {Boolean} True if the provider has a water mask; otherwise, false.
 */
@property (readonly) BOOL hasWaterMask;

-(instancetype)initWithOptions:(NSDictionary *)options;

/**
 * Gets a list of indices for a triangle mesh representing a regular grid.  Calling
 * this function multiple times with the same grid width and height returns the
 * same list of indices.  The total number of vertices must be less than or equal
 * to 65536.
 *
 * @memberof TerrainProvider
 *
 * @param {Number} width The number of vertices in the regular grid in the horizontal direction.
 * @param {Number} height The number of vertices in the regular grid in the vertical direction.
 * @returns {Uint16Array} The list of indices.
 */
-(CSUInt16Array *)getRegularGridIndicesForWidth:(UInt32)width height:(UInt32)height;

/**
 * Determines an appropriate geometric error estimate when the geometry comes from a heightmap.
 *
 * @param {Ellipsoid} ellipsoid The ellipsoid to which the terrain is attached.
 * @param {Number} tileImageWidth The width, in pixels, of the heightmap associated with a single tile.
 * @param {Number} numberOfTilesAtLevelZero The number of tiles in the horizontal direction at tile level zero.
 * @returns {Number} An estimated geometric error.
 */
-(Float64)getEstimatedLevelZeroGeometricErrorForAHeightmapWithEllipsoid:(CSEllipsoid *)ellipsoid
                                                         tileImageWidth:(Float64)tileImageWidth
                                               numberOfTilesAtLevelZero:(UInt32)numberOfTilesAtLevelZero;

/**
 * Requests the geometry for a given tile.  This function should not be called before
 * {@link TerrainProvider#ready} returns true.  The result must include terrain data and
 * may optionally include a water mask and an indication of which child tiles are available.
 * @memberof TerrainProvider
 * @function
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
-(CSTerrainData *)requestTileGeometryX:(UInt32)x Y:(UInt32)y level:(UInt32)level throttle:(BOOL)throttle;

/**
 * Gets the maximum geometric error allowed in a tile at a given level.  This function should not be
 * called before {@link TerrainProvider#ready} returns true.
 * @memberof TerrainProvider
 * @function
 *
 * @param {Number} level The tile level for which to get the maximum geometric error.
 * @returns {Number} The maximum geometric error.
 */
-(Float64)getMaximumGeometricErrorForLevel:(UInt32)level;

@end


