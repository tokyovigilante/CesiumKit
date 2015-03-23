//
//  TerrainProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 12/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

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
// FIXME: make base class
protocol TerrainProvider {
    
    /**
    * Gets an event that is raised when the terrain provider encounters an asynchronous error..  By subscribing
    * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
    * are passed an instance of {@link TileProviderError}.
    * @memberof TerrainProvider.prototype
    * @type {Event}
    */
    var errorEvent: Event { get }
    
    /**
    * Gets the credit to display when this terrain provider is active.  Typically this is used to credit
    * the source of the terrain. This function should
    * not be called before {@link TerrainProvider#ready} returns true.
    * @memberof TerrainProvider.prototype
    * @type {Credit}
    */
    var credit : Credit { get }
    
    /**
    * Gets the tiling scheme used by the provider.  This function should
    * not be called before {@link TerrainProvider#ready} returns true.
    * @memberof TerrainProvider.prototype
    * @type {TilingScheme}
    */
    var tilingScheme: TilingScheme { get }
    
    /** 
    * Gets the ellipsoid used by the provider. Default is WGS84.
    */
    var ellipsoid: Ellipsoid { get }
    
    /**
    * Gets a value indicating whether or not the provider is ready for use.
    * @memberof TerrainProvider.prototype
    * @type {Boolean}
    */
    var ready: Bool { get }
    
    //FIXME: terrain Queue
    //var terrainProcessorQueue: dispatch_queue_t { get }
    
    /**
    * Specifies the quality of terrain created from heightmaps.  A value of 1.0 will
    * ensure that adjacent heightmap vertices are separated by no more than
    * {@link Globe.maximumScreenSpaceError} screen pixels and will probably go very slowly.
    * A value of 0.5 will cut the estimated level zero geometric error in half, allowing twice the
    * screen pixels between adjacent heightmap vertices and thus rendering more quickly.
    */
    var heightmapTerrainQuality: Double { get set }
    
    /**
    * Gets a list of indices for a triangle mesh representing a regular grid.  Calling
    * this function multiple times with the same grid width and height returns the
    * same list of indices.  The total number of vertices must be less than or equal
    * to 65536.
    *
    * @param {Number} width The number of vertices in the regular grid in the horizontal direction.
    * @param {Number} height The number of vertices in the regular grid in the vertical direction.
    * @returns {Uint16Array} The list of indices.
    */
    
    init(tilingScheme: TilingScheme, ellipsoid: Ellipsoid)
    
    static func getRegularGridIndices(#width: Int, height: Int) -> [Int]
    
    /**
    * Determines an appropriate geometric error estimate when the geometry comes from a heightmap.
    *
    * @param {Ellipsoid} ellipsoid The ellipsoid to which the terrain is attached.
    * @param {Number} tileImageWidth The width, in pixels, of the heightmap associated with a single tile.
    * @param {Number} numberOfTilesAtLevelZero The number of tiles in the horizontal direction at tile level zero.
    * @returns {Number} An estimated geometric error.
    */
    static func estimatedLevelZeroGeometricErrorForAHeightmap(#ellipsoid: Ellipsoid, tileImageWidth: Int, numberOfTilesAtLevelZero: Int) -> Double
    
    /**
    * Requests the geometry for a given tile.  This function should not be called before
    * {@link TerrainProvider#ready} returns true.  The result must include terrain data and
    * may optionally include a water mask and an indication of which child tiles are available.
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
    func requestTileGeometry(#x: Int, y: Int, level: Int/*, throttleRequests: Bool*/) -> TerrainData? //resolve: (TerrainData?) -> () )
    
    /**
    * Gets the maximum geometric error allowed in a tile at a given level.  This function should not be
    * called before {@link TerrainProvider#ready} returns true.
    * @function
    *
    * @param {Number} level The tile level for which to get the maximum geometric error.
    * @returns {Number} The maximum geometric error.
    */
    func levelMaximumGeometricError(level: Int) -> Double
    
    /**
    * Determines whether data for a tile is available to be loaded.
    * @function
    *
    * @param {Number} x The X coordinate of the tile for which to request geometry.
    * @param {Number} y The Y coordinate of the tile for which to request geometry.
    * @param {Number} level The level of the tile for which to request geometry.
    * @returns {Boolean} Undefined if not supported by the terrain provider, otherwise true or false.
    */
    func getTileDataAvailable(#x: Int, y: Int, level: Int) -> Bool?
    
    /**
    * Gets a value indicating whether or not the provider includes a water mask.  The water mask
    * indicates which areas of the globe are water rather than land, so they can be rendered
    * as a reflective surface with animated waves.  This function should not be
    * called before {@link TerrainProvider#ready} returns true.
    * @function
    *
    * @returns {Boolean} True if the provider has a water mask; otherwise, false.
    */
    var hasWaterMask: Bool { get }
    
    /**
    * Gets a value indicating whether or not the requested tiles include vertex normals.
    * This function should not be called before {@link TerrainProvider#ready} returns true.
    * @memberof TerrainProvider.prototype
    * @type {Boolean}
    */
    var hasVertexNormals: Bool { get }
}

