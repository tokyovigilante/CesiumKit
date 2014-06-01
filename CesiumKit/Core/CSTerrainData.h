//
//  CSTerrainData.h
//  CesiumKit
//
//  Created by Ryan Walklin on 30/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

@import Foundation;

@class CSUInt8Array, CSTerrainMesh, CSTilingScheme, CSRectangle;

/**
 * Terrain data for a single {@link Tile}.  This type describes an
 * interface and is not intended to be instantiated directly.
 *
 * @alias TerrainData
 * @constructor
 *
 * @see HeightmapTerrainData
 * @see QuantizedMeshTerrainData
 */
@interface CSTerrainData : NSObject {
    CSUInt8Array *_waterMask;
    UInt8 _childMask;
    BOOL _wasCreatedByUpsampling;
}

-(id)initWithOptions:(NSDictionary *)options;

/*
 * @param {Number} [options.childTileMask=15] A bit mask indicating which of this tile's four children exist.
 *                 If a child's bit is set, geometry will be requested for that tile as well when it
 *                 is needed.  If the bit is cleared, the child tile is not requested and geometry is
 *                 instead upsampled from the parent.  The bit values are as follows:
 *                 <table>
 *                  <tr><th>Bit Position</th><th>Bit Value</th><th>Child Tile</th></tr>
 *                  <tr><td>0</td><td>1</td><td>Southwest</td></tr>
 *                  <tr><td>1</td><td>2</td><td>Southeast</td></tr>
 *                  <tr><td>2</td><td>4</td><td>Northwest</td></tr>
 *                  <tr><td>3</td><td>8</td><td>Northeast</td></tr>
 *                 </table>
 */
@property (readonly) UInt8 *childTileMask;

/**
 * The water mask included in this terrain data, if any.  A water mask is a rectangular
 * Uint8Array or image where a value of 255 indicates water and a value of 0 indicates land.
 * Values in between 0 and 255 are allowed as well to smoothly blend between land and water.
 * @memberof TerrainData.prototype
 * @type {Uint8Array|Image|Canvas}
 */
@property (readonly) CSUInt8Array *waterMask;

/**
 * Gets a value indicating whether or not this terrain data was created by upsampling lower resolution
 * terrain data.  If this value is false, the data was obtained from some other source, such
 * as by downloading it from a remote server.  This method should return true for instances
 * returned from a call to {@link TerrainData#upsample}.
 * @memberof TerrainData
 * @function
 *
 * @returns {Boolean} True if this instance was created by upsampling; otherwise, false.
 */
@property (readonly) BOOL wasCreatedByUpsampling;

/**
 * Creates a {@link TerrainMesh} from this terrain data.
 * @memberof TerrainData
 * @function
 *
 * @param {TilingScheme} tilingScheme The tiling scheme to which this tile belongs.
 * @param {Number} x The X coordinate of the tile for which to create the terrain data.
 * @param {Number} y The Y coordinate of the tile for which to create the terrain data.
 * @param {Number} level The level of the tile for which to create the terrain data.
 * @returns {Promise|TerrainMesh} A promise for the terrain mesh, or undefined if too many
 *          asynchronous mesh creations are already in progress and the operation should
 *          be retried later.
 */
-(void)createMesh:(CSTilingScheme *)tilingScheme X:(UInt32)x Y:(UInt32)y level:(UInt32)level completionBlock:(void (^)(CSTerrainMesh *terrainMesh))completionBlock;

/**
 * Computes the terrain height at a specified longitude and latitude.
 * @memberof TerrainData
 * @function
 *
 * @param {Rectangle} rectangle The rectangle covered by this terrain data.
 * @param {Number} longitude The longitude in radians.
 * @param {Number} latitude The latitude in radians.
 * @returns {Number} The terrain height at the specified position.  If the position
 *          is outside the rectangle, this method will extrapolate the height, which is likely to be wildly
 *          incorrect for positions far outside the rectangle.
 */
-(Float64)interpolateHeightForRectangle:(CSRectangle *)rectangle longitude:(Float64)longitude latitude:(Float64)latitude;

/**
 * Determines if a given child tile is available, based on the
 * {@link TerrainData#childTileMask}.  The given child tile coordinates are assumed
 * to be one of the four children of this tile.  If non-child tile coordinates are
 * given, the availability of the southeast child tile is returned.
 * @memberof TerrainData
 * @function
 *
 * @param {Number} thisX The tile X coordinate of this (the parent) tile.
 * @param {Number} thisY The tile Y coordinate of this (the parent) tile.
 * @param {Number} childX The tile X coordinate of the child tile to check for availability.
 * @param {Number} childY The tile Y coordinate of the child tile to check for availability.
 * @returns {Boolean} True if the child tile is available; otherwise, false.
 */
-(BOOL)isChildAvailableForThisX:(UInt32)thisX thisY:(UInt32)thisY childX:(UInt32)childX childY:(UInt32)childY;

/**
 * Upsamples this terrain data for use by a descendant tile.
 * @memberof TerrainData
 * @function
 *
 * @param {TilingScheme} tilingScheme The tiling scheme of this terrain data.
 * @param {Number} thisX The X coordinate of this tile in the tiling scheme.
 * @param {Number} thisY The Y coordinate of this tile in the tiling scheme.
 * @param {Number} thisLevel The level of this tile in the tiling scheme.
 * @param {Number} descendantX The X coordinate within the tiling scheme of the descendant tile for which we are upsampling.
 * @param {Number} descendantY The Y coordinate within the tiling scheme of the descendant tile for which we are upsampling.
 * @param {Number} descendantLevel The level within the tiling scheme of the descendant tile for which we are upsampling.
 *
 * @returns {Promise|TerrainData} A promise for upsampled terrain data for the descendant tile,
 *          or undefined if too many asynchronous upsample operations are in progress and the request has been
 *          deferred.
 */
-(void)upsample:(CSTilingScheme *)tilingScheme thisX:(UInt32)thisX thisY:(UInt32)thisY thisLevel:(UInt32)thisLevel descendantX:(UInt32)descendantX descendantY:(UInt32)descendantY descendantLevelcompletionBlock:(void (^)(CSTerrainData *terrainData))completionBlock;

@end

