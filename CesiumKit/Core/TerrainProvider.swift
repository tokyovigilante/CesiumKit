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
// FIXME turn into protocol
public class TerrainProvider {
    
    /**
    * Gets an event that is raised when the terrain provider encounters an asynchronous error..  By subscribing
    * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
    * are passed an instance of {@link TileProviderError}.
    * @memberof TerrainProvider.prototype
    * @type {Event}
    */
    var errorEvent: (() -> ())?
    
    /**
    * Gets the credit to display when this terrain provider is active.  Typically this is used to credit
    * the source of the terrain. This function should
    * not be called before {@link TerrainProvider#ready} returns true.
    * @memberof TerrainProvider.prototype
    * @type {Credit}
    */
    var credit : Credit
    
    /**
    * Gets the tiling scheme used by the provider.  This function should
    * not be called before {@link TerrainProvider#ready} returns true.
    * @memberof TerrainProvider.prototype
    * @type {TilingScheme}
    */
    var tilingScheme: TilingScheme
    
    /**
    * Gets a value indicating whether or not the provider is ready for use.
    * @memberof TerrainProvider.prototype
    * @type {Boolean}
    */
    var ready: Bool = false
    
    let terrainProcessorQueue = dispatch_queue_create("terrainProcessorQueue", DISPATCH_QUEUE_SERIAL)
    
    /**
    * Specifies the quality of terrain created from heightmaps.  A value of 1.0 will
    * ensure that adjacent heightmap vertices are separated by no more than
    * {@link Globe.maximumScreenSpaceError} screen pixels and will probably go very slowly.
    * A value of 0.5 will cut the estimated level zero geometric error in half, allowing twice the
    * screen pixels between adjacent heightmap vertices and thus rendering more quickly.
    */
    //class var heightmapTerrainQuality = 0.25;
    
    var regularGridIndexArrays: [Int: [Int: [UInt16]]] = [:]//Dictionary<Int, Dictionary<Int, Array<UInt16>>> = [:]
    
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
    
    init(tilingScheme: TilingScheme) {
        self.tilingScheme = tilingScheme
        credit = Credit(text: "base class", imageUrl: nil, link: nil)
    }
    
    func getRegularGridIndices(width: Int, height: Int) -> [UInt16] {
        assert((width * height <= 64 * 1024), "The total number of vertices (width * height) must be less than or equal to 65536")
        
        var byWidth = regularGridIndexArrays[width]
        if byWidth == nil {
            byWidth = [:]
            regularGridIndexArrays[width] = byWidth
        }
        var indices = byWidth![height]
        if indices == nil {
            var unwrappedIndices = [UInt16](count: (width - 1) * (height - 1) * 6, repeatedValue: 0)
            
            var index: UInt16 = 0
            var indicesIndex = 0
            for i in 0..<height-1 {
                for j in 0..<width-1 {
                    var upperLeft: UInt16 = index
                    var lowerLeft: UInt16 = upperLeft + UInt16(width)
                    var lowerRight: UInt16 = lowerLeft + 1
                    var upperRight: UInt16 = upperLeft + 1
                    
                    unwrappedIndices[indicesIndex++] = upperLeft
                    unwrappedIndices[indicesIndex++] = lowerLeft
                    unwrappedIndices[indicesIndex++] = upperRight
                    unwrappedIndices[indicesIndex++] = upperRight
                    unwrappedIndices[indicesIndex++] = lowerLeft
                    unwrappedIndices[indicesIndex++] = lowerRight
                    
                    ++index
                }
                ++index
            }
            var unWrappedByWidth = byWidth!
            
            unWrappedByWidth[height] = unwrappedIndices
            regularGridIndexArrays[width] = unWrappedByWidth
        }
        
        return indices!
    }
    
    /**
    * Determines an appropriate geometric error estimate when the geometry comes from a heightmap.
    *
    * @param {Ellipsoid} ellipsoid The ellipsoid to which the terrain is attached.
    * @param {Number} tileImageWidth The width, in pixels, of the heightmap associated with a single tile.
    * @param {Number} numberOfTilesAtLevelZero The number of tiles in the horizontal direction at tile level zero.
    * @returns {Number} An estimated geometric error.
    */
    class func getEstimatedLevelZeroGeometricErrorForAHeightmap(
        #ellipsoid: Ellipsoid,
        tileImageWidth: Int,
        numberOfTilesAtLevelZero: Int) -> Double {
            
            return ellipsoid.maximumRadius * 2 * M_PI * 0.25/*TerrainProvider.heightmapTerrainQuality*/ / Double(tileImageWidth * numberOfTilesAtLevelZero)
    }
    
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
    func requestTileGeometry(x: Int, y: Int, level: Int, throttleRequests: Bool = true, resolve: (TerrainData?) -> () )  {
        dispatch_async(terrainProcessorQueue, {
            // FIXME: Do expensive work to make terrainData
            dispatch_async(dispatch_get_main_queue(),  {
                resolve(nil)
                })
            })
    }
    
    /**
    * Gets the maximum geometric error allowed in a tile at a given level.  This function should not be
    * called before {@link TerrainProvider#ready} returns true.
    * @function
    *
    * @param {Number} level The tile level for which to get the maximum geometric error.
    * @returns {Number} The maximum geometric error.
    */
    func getLevelMaximumGeometricError(level: Int) -> Double {
        return 0.0
    }
    
    /**
    * Gets a value indicating whether or not the provider includes a water mask.  The water mask
    * indicates which areas of the globe are water rather than land, so they can be rendered
    * as a reflective surface with animated waves.  This function should not be
    * called before {@link TerrainProvider#ready} returns true.
    * @function
    *
    * @returns {Boolean} True if the provider has a water mask; otherwise, false.
    */
    func hasWaterMask() -> Bool {
        return false
    }
}
