//
//  EllipsoidTerrainProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 13/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
     * A very simple {@link TerrainProvider} that produces geometry by tessellating an ellipsoidal
     * surface.
     *
     * @alias EllipsoidTerrainProvider
     * @constructor
     *
     * @param {Object} [options] Object with the following properties:
     * @param {TilingScheme} [options.tilingScheme] The tiling scheme specifying how the ellipsoidal
     * surface is broken into tiles.  If this parameter is not provided, a {@link GeographicTilingScheme}
     * is used.
     * @param {Ellipsoid} [options.ellipsoid] The ellipsoid.  If the tilingScheme is specified,
     * this parameter is ignored and the tiling scheme's ellipsoid is used instead. If neither
     * parameter is specified, the WGS84 ellipsoid is used.
     *
     * @see TerrainProvider
     */
class EllipsoidTerrainProvider: TerrainProvider {

    /**
    * Gets an event that is raised when the terrain provider encounters an asynchronous error.  By subscribing
    * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
    * are passed an instance of {@link TileProviderError}.
    * @memberof EllipsoidTerrainProvider.prototype
    * @type {Event}
    */
    var errorEvent: Event
    
    /**
    * Gets the tiling scheme used by the provider.  This function should
    * not be called before {@link TerrainProvider#ready} returns true.
    * @memberof TerrainProvider.prototype
    * @type {TilingScheme}
    */
    let tilingScheme: TilingScheme
    
    let ellipsoid: Ellipsoid
    
    /**
    * Gets the credit to display when this terrain provider is active.  Typically this is used to credit
    * the source of the terrain. This function should
    * not be called before {@link TerrainProvider#ready} returns true.
    * @memberof TerrainProvider.prototype
    * @type {Credit}
    */
    var credit: Credit? = nil
    
    /**
    * Gets a value indicating whether or not the provider is ready for use.
    * @memberof TerrainProvider.prototype
    * @type {Boolean}
    */
    fileprivate (set) var ready = true
    
    fileprivate var _levelZeroMaximumGeometricError: Double = 0.0
    
    var heightmapTerrainQuality = 0.25
    
    required init(tilingScheme: TilingScheme = GeographicTilingScheme(), ellipsoid: Ellipsoid = Ellipsoid.wgs84()) {
        
        self.tilingScheme = tilingScheme
        self.ellipsoid = ellipsoid
        
        credit = nil
        
        errorEvent = Event()

        // Note: the 64 below does NOT need to match the actual vertex dimensions, because
        // the ellipsoid is significantly smoother than actual terrain.
        _levelZeroMaximumGeometricError = EllipsoidTerrainProvider.estimatedLevelZeroGeometricErrorForAHeightmap(ellipsoid: ellipsoid, tileImageWidth: 64,numberOfTilesAtLevelZero: tilingScheme.numberOfXTilesAt(level: 0))
    }

    /**
     * Requests the geometry for a given tile.  This function should not be called before
     * {@link TerrainProvider#ready} returns true.  The result includes terrain
     * data and indicates that all child tiles are available.
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
    func requestTileGeometry(x: Int, y: Int, level: Int, throttleRequests: Bool, completionBlock: @escaping (TerrainData?) -> ()) -> NetworkOperation? {
        logPrint(.debug, "Requested terrain for L\(level)X\(x)Y\(y)")
        let terrainData = HeightmapTerrainData(
            buffer: [UInt16](repeating: 0, count: 16 * 16),
            width : 16,
            height : 16)
        completionBlock(terrainData)
        return nil
    }

    /**
     * Gets the maximum geometric error allowed in a tile at a given level.
     *
     * @param {Number} level The tile level for which to get the maximum geometric error.
     * @returns {Number} The maximum geometric error.
     */
    func levelMaximumGeometricError(_ level: Int) -> Double {
        return _levelZeroMaximumGeometricError / Double(1 << level)
    }

    /**
     * Gets a value indicating whether or not the provider includes a water mask.  The water mask
     * indicates which areas of the globe are water rather than land, so they can be rendered
     * as a reflective surface with animated waves.
     *
     * @returns {Boolean} True if the provider has a water mask; otherwise, false.
     */
    var hasWaterMask: Bool {
        return false
    }
    
    var hasVertexNormals: Bool {
        return false
    }
    
}
