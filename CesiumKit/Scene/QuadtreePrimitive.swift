    //
//  QuadTreePrimitive.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* Renders massive sets of data by utilizing level-of-detail and culling.  The globe surface is divided into
* a quadtree of tiles with large, low-detail tiles at the root and small, high-detail tiles at the leaves.
* The set of tiles to render is selected by projecting an estimate of the geometric error in a tile onto
* the screen to estimate screen-space error, in pixels, which must be below a user-specified threshold.
* The actual content of the tiles is arbitrary and is specified using a {@link QuadtreeTileProvider}.
*
* @alias QuadtreePrimitive
* @constructor
* @private
*
* @param {QuadtreeTileProvider} options.tileProvider The tile provider that loads, renders, and estimates
*        the distance to individual tiles.
* @param {Number} [options.maximumScreenSpaceError=2] The maximum screen-space error, in pixels, that is allowed.
*        A higher maximum error will render fewer tiles and improve performance, while a lower
*        value will improve visual quality.
* @param {Number} [options.tileCacheSize=100] The maximum number of tiles that will be retained in the tile cache.
*        Note that tiles will never be unloaded if they were used for rendering the last
*        frame, so the actual number of resident tiles may be higher.  The value of
*        this property will not affect visual quality.
*/

class QuadtreePrimitive {
    
    var tileProvider: QuadtreeTileProvider {
        get {
            return _tileProvider
        }
    }
    private var _tileProvider: QuadtreeTileProvider
    
    private var _debug = (
        enableDebugOutput : false,
        
        maxDepth: 0,
        tilesVisited: 0,
        tilesCulled: 0,
        tilesRendered: 0,
        tilesWaitingForChildren: 0,
        
        lastMaxDepth: -1,
        lastTilesVisited: -1,
        lastTilesCulled: -1,
        lastTilesRendered: -1,
        lastTilesWaitingForChildren: -1,
        
        suspendLodUpdate: false
    )
    
    var tilesToRender: [QuadtreeTile] {
        get {
            return _tilesToRender
        }
    }
    
    private var _tilesToRender = [QuadtreeTile]()
    
    private var _tileTraversalQueue = Queue<QuadtreeTile>()
    
    private var _tileLoadQueue = [QuadtreeTile]()
    
    private var _tileReplacementQueue = TileReplacementQueue()
    
    private var _levelZeroTiles = [QuadtreeTile]()
    private var _levelZeroTilesReady = false
    private var _loadQueueTimeSlice = 0.05 // 5ms

    
    /**
    * Gets or sets the maximum screen-space error, in pixels, that is allowed.
    * A higher maximum error will render fewer tiles and improve performance, while a lower
    * value will improve visual quality.
    * @type {Number}
    * @default 2
    */
    var maximumScreenSpaceError: Double = 2.0
    
    /**
    * Gets or sets the maximum number of tiles that will be retained in the tile cache.
    * Note that tiles will never be unloaded if they were used for rendering the last
    * frame, so the actual number of resident tiles may be higher.  The value of
    * this property will not affect visual quality.
    * @type {Number}
    * @default 100
    */
    var tileCacheSize: Int
    
    var _occluders: QuadtreeOccluders

    init (tileProvider: QuadtreeTileProvider, maximumScreenSpaceError: Double = 2.0, tileCacheSize: Int = 100) {
        
        self.maximumScreenSpaceError = maximumScreenSpaceError
        self.tileCacheSize = tileCacheSize
        
        assert(tileProvider.quadtree == nil, "A QuadtreeTileProvider can only be used with a single QuadtreePrimitive")
        
        self._tileProvider = tileProvider
        
        var tilingScheme = tileProvider.tilingScheme
        var ellipsoid = tilingScheme.ellipsoid
        
        _occluders = QuadtreeOccluders(ellipsoid : ellipsoid)
        
        self.tileCacheSize = tileCacheSize
        
        self._tileProvider.quadtree = self
    }
    
    /**
    * Invalidates and frees all the tiles in the quadtree.  The tiles must be reloaded
    * before they can be displayed.
    *
    * @memberof QuadtreePrimitive
    */
        
    func invalidateAllTiles() {
        // Clear the replacement queue
        _tileReplacementQueue.head = nil
        _tileReplacementQueue.tail = nil
        _tileReplacementQueue.count = 0
        
        // Free and recreate the level zero tiles.
        for tile in _levelZeroTiles {
            tile.freeResources()
        }
        _levelZeroTiles.removeAll()
    }
    /**
    * Invokes a specified function for each {@link QuadtreeTile} that is partially
    * or completely loaded.
    *
    * @param {Function} tileFunction The function to invoke for each loaded tile.  The
    *        function is passed a reference to the tile as its only parameter.
    */
    
    func forEachLoadedTile (tileFunction: QuadtreeTile -> ()) {
        var tile = _tileReplacementQueue.head
        while tile != nil {
            if tile!.state != .Start {
                tileFunction(tile!)
            }
            tile = tile!.replacementNext
        }
    }
    
    /**
    * Invokes a specified function for each {@link QuadtreeTile} that was rendered
    * in the most recent frame.
    *
    * @param {Function} tileFunction The function to invoke for each rendered tile.  The
    *        function is passed a reference to the tile as its only parameter.
    */
    /*QuadtreePrimitive.prototype.forEachRenderedTile = function(tileFunction) {
    var tilesRendered = this._tilesToRender;
    for (var i = 0, len = tilesRendered.length; i < len; ++i) {
    tileFunction(tilesRendered[i]);
    }
    }*/
    
    /**
    * Updates the primitive.
    *
    * @param {Context} context The rendering context to use.
    * @param {FrameState} frameState The state of the current frame.
    * @param {DrawCommand[]} commandList The list of draw commands.  The primitive will usually add
    *        commands to this array during the update call.
    */
    func update (#context: Context, frameState: FrameState, inout commandList: [Command]) {
        _tileProvider.beginUpdate(context: context, frameState: frameState, commandList: &commandList)
        selectTilesForRendering(context: context, frameState: frameState)
        processTileLoadQueue(context: context, frameState: frameState)
        createRenderCommandsForSelectedTiles(context: context, frameState: frameState, commandList: &commandList)
        _tileProvider.endUpdate(context: context, frameState: frameState, commandList: &commandList)
    }
    
    /*
    /**
    * Returns true if this object was destroyed; otherwise, false.
    * <br /><br />
    * If this object was destroyed, it should not be used; calling any function other than
    * <code>isDestroyed</code> will result in a {@link DeveloperError} exception.
    *
    * @memberof QuadtreePrimitive
    *
    * @returns {Boolean} True if this object was destroyed; otherwise, false.
    *
    * @see QuadtreePrimitive#destroy
    */
    QuadtreePrimitive.prototype.isDestroyed = function() {
    return false;
    };
    
    /**
    * Destroys the WebGL resources held by this object.  Destroying an object allows for deterministic
    * release of WebGL resources, instead of relying on the garbage collector to destroy this object.
    * <br /><br />
    * Once an object is destroyed, it should not be used; calling any function other than
    * <code>isDestroyed</code> will result in a {@link DeveloperError} exception.  Therefore,
    * assign the return value (<code>undefined</code>) to the object as done in the example.
    *
    * @memberof QuadtreePrimitive
    *
    * @returns {undefined}
    *
    * @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
    *
    * @see QuadtreePrimitive#isDestroyed
    *
    * @example
    * primitive = primitive && primitive.destroy();
    */
    QuadtreePrimitive.prototype.destroy = function() {
    this._tileProvider = this._tileProvider && this._tileProvider.destroy();
    };
    */
    func selectTilesForRendering(#context: Context, frameState: FrameState) {
        
        if _debug.suspendLodUpdate {
            return
        }
        
        var i: Int
        var len: Int
        
        // Clear the render list.
        _tilesToRender.removeAll()
        _tileTraversalQueue.clear()
        
        _debug.maxDepth = 0
        _debug.tilesVisited = 0
        _debug.tilesCulled = 0
        _debug.tilesRendered = 0
        _debug.tilesWaitingForChildren = 0
        
        _tileLoadQueue.removeAll()
        
        _tileReplacementQueue.markStartOfRenderFrame()
        
        // We can't render anything before the level zero tiles exist.
        if _levelZeroTiles.count == 0 {
            if (_tileProvider.ready) {
                var terrainTilingScheme = _tileProvider.tilingScheme
                _levelZeroTiles = QuadtreeTile.createLevelZeroTiles(terrainTilingScheme)
            } else {
                // Nothing to do until the provider is ready.
                return
            }
        }
        
        _occluders.ellipsoid.cameraPosition = frameState.camera!.positionWC
        
        // Enqueue the root tiles that are renderable and visible.
        for tile in _levelZeroTiles {

            _tileReplacementQueue.markTileRendered(tile)
            if tile.needsLoading {
                queueTileLoad(tile)
            }
            
            if tile.renderable && _tileProvider.computeTileVisibility(tile, frameState: frameState, occluders: _occluders) != .None {
                _tileTraversalQueue.enqueue(tile)
            } else {
                ++_debug.tilesCulled
                if (!tile.renderable) {
                    ++_debug.tilesWaitingForChildren
                }
            }
        }
        
        // Traverse the tiles in breadth-first order.
        // This ordering allows us to load bigger, lower-detail tiles before smaller, higher-detail ones.
        // This maximizes the average detail across the scene and results in fewer sharp transitions
        // between very different LODs.
        while var tile = _tileTraversalQueue.dequeue() {
            ++_debug.tilesVisited
            
            _tileReplacementQueue.markTileRendered(tile)
            
            if (tile.level > _debug.maxDepth) {
                _debug.maxDepth = tile.level
            }
            
            // There are a few different algorithms we could use here.
            // This one doesn't load children unless we refine to them.
            // We may want to revisit this in the future.
            if screenSpaceError(context: context, frameState: frameState, tile: tile) < maximumScreenSpaceError {
                // This tile meets SSE requirements, so render it.
                addTileToRenderList(tile)
            } else if queueChildrenLoadAndDetermineIfChildrenAreAllRenderable(tile) {
                // SSE is not good enough and children are loaded, so refine.
                
                // PERFORMANCE_IDEA: traverse children front-to-back so we can avoid sorting by distance later.
                for child in tile.children {
                    if _tileProvider.computeTileVisibility(child, frameState: frameState, occluders: _occluders) != .None {
                        _tileTraversalQueue.enqueue(child)
                    } else {
                        ++_debug.tilesCulled
                    }
                }
            } else {
                ++_debug.tilesWaitingForChildren
                // SSE is not good enough but not all children are loaded, so render this tile anyway.
                addTileToRenderList(tile)
            }
        }
        
        if _debug.enableDebugOutput {
            if _debug.tilesVisited != _debug.lastTilesVisited ||
               _debug.tilesRendered != _debug.lastTilesRendered ||
               _debug.tilesCulled != _debug.lastTilesCulled ||
               _debug.maxDepth != _debug.lastMaxDepth ||
               _debug.tilesWaitingForChildren != _debug.lastTilesWaitingForChildren {
                    
                    /*global console*/
                    println("Visited \(_debug.tilesVisited), Rendered: \(_debug.tilesRendered), Culled: \(_debug.tilesCulled), Max Depth: \(_debug.maxDepth), Waiting for children: \(_debug.tilesWaitingForChildren)")
                    
                    _debug.lastTilesVisited = _debug.tilesVisited
                    _debug.lastTilesRendered = _debug.tilesRendered
                    _debug.lastTilesCulled = _debug.tilesCulled
                    _debug.lastMaxDepth = _debug.maxDepth
                    _debug.lastTilesWaitingForChildren = _debug.tilesWaitingForChildren
            }
        }
    }
    
    func screenSpaceError(#context: Context, frameState: FrameState, tile: QuadtreeTile) -> Double {
        if frameState.mode == .Scene2D {
            return screenSpaceError2D(context: context, frameState: frameState, tile: tile)
        }
        
        let maxGeometricError = _tileProvider.levelMaximumGeometricError(tile.level)
        
        let distance = _tileProvider.computeDistanceToTile(tile, frameState: frameState)
        tile.distance = distance
        
        // PERFORMANCE_IDEA: factor out stuff that's constant across tiles.
        return (maxGeometricError * Double(context.height)) / (2 * distance * tan(0.5 * frameState.camera!.frustum.fovy))
    }
    
    func screenSpaceError2D(#context: Context, frameState: FrameState, tile: QuadtreeTile) -> Double {
        let frustum = frameState.camera!.frustum

        let maxGeometricError = _tileProvider.levelMaximumGeometricError(tile.level)
        let pixelSize = max(frustum.top - frustum.bottom, frustum.right - frustum.left) / max(Double(context.width), Double(context.height))
        return maxGeometricError / pixelSize
    }
    
    
    func addTileToRenderList(tile: QuadtreeTile) {
        _tilesToRender.append(tile)
        ++_debug.tilesRendered
    }
    
    func queueChildrenLoadAndDetermineIfChildrenAreAllRenderable(tile: QuadtreeTile) -> Bool {
        var allRenderable = true
        var allUpsampledOnly = true
        
        for child in tile.children {
            _tileReplacementQueue.markTileRendered(child)
            
            allUpsampledOnly = allUpsampledOnly && child.upsampledFromParent
            allRenderable = allRenderable && child.renderable
            
            if (child.needsLoading) {
                queueTileLoad(child)
            }
        }
        
        if (!allRenderable) {
            ++_debug.tilesWaitingForChildren
        }
        
        // If all children are upsampled from this tile, we just render this tile instead of its children.
        return allRenderable && !allUpsampledOnly
    }
    
    func queueTileLoad(tile: QuadtreeTile) {
        _tileLoadQueue.append(tile)
    }
    
    func processTileLoadQueue(#context: Context, frameState: FrameState) {
        
        if _tileLoadQueue.count == 0 {
            return
        }
        
        // Remove any tiles that were not used this frame beyond the number
        // we're allowed to keep.
        _tileReplacementQueue.trimTiles(context, maximumTiles: tileCacheSize)
        
        let endTime = NSDate(timeIntervalSinceNow: _loadQueueTimeSlice)
        
        var len = _tileLoadQueue.count
        for var i = len - 1; i >= 0; --i {
            let tile = _tileLoadQueue[i]
            _tileReplacementQueue.markTileRendered(tile)
            _tileProvider.loadTile(tile, context: context, frameState: frameState)
            if NSDate().compare(endTime) == NSComparisonResult.OrderedDescending {
                break
            }
        }
    }
    
    func createRenderCommandsForSelectedTiles(#context: Context, frameState: FrameState, inout commandList: [Command]) {
        func tileDistanceSortFunction(a: QuadtreeTile, b: QuadtreeTile) -> Bool {
            return a.distance < b.distance
        }
        _tilesToRender.sort(tileDistanceSortFunction)
        
        for tile in _tilesToRender {
            _tileProvider.showTileThisFrame(tile, context: context, frameState: frameState, commandList: &commandList)
        }
    }

}