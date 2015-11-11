//
//  QuadtreeTileProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* Provides general quadtree tiles to be displayed on or near the surface of an ellipsoid.  It is intended to be
* used with the {@link QuadtreePrimitive}.  This type describes an interface and is not intended to be
* instantiated directly.
*
* @alias QuadtreeTileProvider
* @constructor
* @private
*/
protocol QuadtreeTileProvider {
    
    /**
    * Gets or sets the {@link QuadtreePrimitive} for which this provider is
    * providing tiles.
    * @memberof QuadtreeTileProvider.prototype
    * @type {QuadtreePrimitive}
    */
    weak var quadtree: QuadtreePrimitive? { get set }
    
    /**
    * Gets a value indicating whether or not the provider is ready for use.
    * @memberof QuadtreeTileProvider.prototype
    * @type {Boolean}
    */
    
    var ready: Bool { get }
    
    /**
    * Gets the tiling scheme used by the provider.  This property should
    * not be accessed before {@link QuadtreeTileProvider#ready} returns true.
    * @memberof QuadtreeTileProvider.prototype
    * @type {TilingScheme}
    */
    var tilingScheme: TilingScheme { get }
    
    /**
    * Gets the terrain provider used by the tile provider
    */
    var terrainProvider: TerrainProvider { get set }
    
    /**
    * The distance where everything becomes lit. This only takes effect
    * when <code>enableLighting</code> is <code>true</code>.
    *
    * @type {Number}
    * @default 6500000.0
    */
    var lightingFadeOutDistance: Float { get set }
    
    /**
    * The distance where lighting resumes. This only takes effect
    * when <code>enableLighting</code> is <code>true</code>.
    *
    * @type {Number}
    * @default 9000000.0
    */
    var lightingFadeInDistance: Float { get set }
    
    var hasWaterMask: Bool { get set }
    
    var oceanNormalMap: Texture? { get set }
    
    var enableLighting: Bool { get set }
    
    var zoomedOutOceanSpecularIntensity: Float { get set }
    
    var baseColor: Cartesian4 { get set }
    
    /**
    * Gets an event that is raised when the geometry provider encounters an asynchronous error.  By subscribing
    * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
    * are passed an instance of {@link TileProviderError}.
    * @memberof QuadtreeTileProvider.prototype
    * @type {Event}
    */
    
    var errorEvent: Event { get }
    
    init (terrainProvider: TerrainProvider, imageryLayers: ImageryLayerCollection, surfaceShaderSet: GlobeSurfaceShaderSet)
    
    /**
    * Computes the default geometric error for level zero of the quadtree.
    *
    * @memberof QuadtreeTileProvider
    *
    * @param {TilingScheme} tilingScheme The tiling scheme for which to compute the geometric error.
    * @returns {Number} The maximum geometric error at level zero, in meters.
    */
    func computeDefaultLevelZeroMaximumGeometricError () -> Double

    
    /**
    * Called at the beginning of the update cycle for each render frame, before {@link QuadtreeTileProvider#showTileThisFrame}
    * or any other functions.
    * @memberof QuadtreeTileProvider
    * @function
    *
    * @param {Context} context The rendering context.
    * @param {FrameState} frameState The frame state.
    * @param {DrawCommand[]} commandList An array of rendering commands.  This method may push
    *        commands into this array.
    */
    func beginUpdate (context context: Context, frameState: FrameState, inout commandList: [DrawCommand])
    
    /**
    * Called at the end of the update cycle for each render frame, after {@link QuadtreeTileProvider#showTileThisFrame}
    * and any other functions.
    * @memberof QuadtreeTileProvider
    * @function
    *
    * @param {Context} context The rendering context.
    * @param {FrameState} frameState The frame state.
    * @param {DrawCommand[]} commandList An array of rendering commands.  This method may push
    *        commands into this array.
    */
    func endUpdate (context context: Context, frameState: FrameState, inout commandList: [DrawCommand])
    
    /**
    * Gets the maximum geometric error allowed in a tile at a given level, in meters.  This function should not be
    * called before {@link QuadtreeTileProvider#ready} returns true.
    *
    * @see {QuadtreeTileProvider.computeDefaultLevelZeroMaximumGeometricError}
    *
    * @memberof QuadtreeTileProvider
    * @function
    *
    * @param {Number} level The tile level for which to get the maximum geometric error.
    * @returns {Number} The maximum geometric error in meters.
    */
    func levelMaximumGeometricError(level: Int) -> Double
    
    /**
    * Loads, or continues loading, a given tile.  This function will continue to be called
    * until {@link QuadtreeTile#state} is no longer {@link QuadtreeTileLoadState#LOADING}.  This function should
    * not be called before {@link QuadtreeTileProvider#ready} returns true.
    *
    * @memberof QuadtreeTileProvider
    * @function
    *
    * @param {Context} context The rendering context.
    * @param {FrameState} frameState The frame state.
    * @param {QuadtreeTile} tile The tile to load.
    *
    * @exception {DeveloperError} <code>loadTile</code> must not be called before the tile provider is ready.
    */
    func loadTile (tile: QuadtreeTile, context: Context, inout commandList: [DrawCommand], frameState: FrameState)
    
    /**
    * Determines the visibility of a given tile.  The tile may be fully visible, partially visible, or not
    * visible at all.  Tiles that are renderable and are at least partially visible will be shown by a call
    * to {@link QuadtreeTileProvider#showTileThisFrame}.
    *
    * @memberof QuadtreeTileProvider
    *
    * @param {QuadtreeTile} tile The tile instance.
    * @param {FrameState} frameState The state information about the current frame.
    * @param {QuadtreeOccluders} occluders The objects that may occlude this tile.
    *
    * @returns {Visibility} The visibility of the tile.
    */
    func computeTileVisibility (tile: QuadtreeTile, frameState: FrameState, occluders: QuadtreeOccluders) -> Visibility
    
    /**
    * Shows a specified tile in this frame.  The provider can cause the tile to be shown by adding
    * render commands to the commandList, or use any other method as appropriate.  The tile is not
    * expected to be visible next frame as well, unless this method is call next frame, too.
    *
    * @memberof QuadtreeTileProvider
    * @function
    *
    * @param {QuadtreeTile} tile The tile instance.
    * @param {Context} context The rendering context.
    * @param {FrameState} frameState The state information of the current rendering frame.
    * @param {DrawCommand[]} commandList The list of rendering commands.  This method may add additional commands to this list.
    */
    func showTileThisFrame (tile: QuadtreeTile, context: Context, frameState: FrameState, inout commandList: [DrawCommand])
    
    /**
    * Gets the distance from the camera to the closest point on the tile.  This is used for level-of-detail selection.
    *
    * @memberof QuadtreeTileProvider
    * @function
    *
    * @param {QuadtreeTile} tile The tile instance.
    * @param {FrameState} frameState The state information of the current rendering frame.
    *
    * @returns {Number} The distance from the camera to the closest point on the tile, in meters.
    */
    func computeDistanceToTile (tile: QuadtreeTile, frameState: FrameState) -> Double
    
}