//
//  CSTerrainMesh.h
//  CesiumKit
//
//  Created by Ryan Walklin on 2/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

@import Foundation;

@class Cartesian3, CSFloat32Array, CSUInt16Array, CSBoundingSphere;

/**
 * A mesh plus related metadata for a single tile of terrain.  Instances of this type are
 * usually created from raw {@link TerrainData}.
 *
 * @alias TerrainMesh
 * @constructor
 *
 * @param {Cartesian3} center The center of the tile.  Vertex positions are specified relative to this center.
 * @param {Float32Array} vertices The vertex data, including positions, texture coordinates, and heights.
 *                       The vertex data is in the order [X, Y, Z, H, U, V], where X, Y, and Z represent
 *                       the Cartesian position of the vertex, H is the height above the ellipsoid, and
 *                       U and V are the texture coordinates.
 * @param {Uint16Array} indices The indices describing how the vertices are connected to form triangles.
 * @param {Number} minimumHeight The lowest height in the tile, in meters above the ellipsoid.
 * @param {Number} maximumHeight The highest height in the tile, in meters above the ellipsoid.
 * @param {BoundingSphere} boundingSphere3D A bounding sphere that completely contains the tile.
 * @param {Cartesian3} occludeePointInScaledSpace The occludee point of the tile, represented in ellipsoid-
 *                     scaled space, and used for horizon culling.  If this point is below the horizon,
 *                     the tile is considered to be entirely below the horizon.
 */
@interface CSTerrainMesh : NSObject

/**
 * The center of the tile.  Vertex positions are specified relative to this center.
 * @type {Cartesian3}
 */
@property (readonly) Cartesian3 *center;

/**
 * The vertex data, including positions, texture coordinates, and heights.
 * The vertex data is in the order [X, Y, Z, H, U, V], where X, Y, and Z represent
 * the Cartesian position of the vertex, H is the height above the ellipsoid, and
 * U and V are the texture coordinates.
 * @type {Float32Array}
 */
@property (readonly) CSFloat32Array *vertices;

/**
 * The indices describing how the vertices are connected to form triangles.
 * @type {Uint16Array}
 */
@property (readonly) CSUInt16Array *indices;

/**
 * The lowest height in the tile, in meters above the ellipsoid.
 * @type {Number}
 */
@property (readonly) Float64 minimumHeight;

/**
 * The highest height in the tile, in meters above the ellipsoid.
 * @type {Number}
 */
@property (readonly) Float64 maximumHeight;

/**
 * A bounding sphere that completely contains the tile.
 * @type {BoundingSphere}
 */
@property (readonly) CSBoundingSphere *boundingSphere3D;

/**
 * The occludee point of the tile, represented in ellipsoid-
 * scaled space, and used for horizon culling.  If this point is below the horizon,
 * the tile is considered to be entirely below the horizon.
 * @type {Cartesian3}
 */
@property (readonly) Cartesian3 *occludeePointInScaledSpace;

-(instancetype) initWithCenter:(Cartesian3 *)center
                      vertices:(CSFloat32Array *)vertices
                       indices:(CSUInt16Array *)indices
                 minimumHeight:(Float64)minimumHeight
                 maximumHeight:(Float64)maximumHeight
              boundingSphere3D:(CSBoundingSphere *)boundingSphere3D
    occludeePointInScaledSpace:(Cartesian3 *)occludeePointInScaledSpace;

@end
