//
//  GlobeSurfaceTileProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import simd

/**
* Provides quadtree tiles representing the surface of the globe.  This type is intended to be used
* with {@link QuadtreePrimitive}.
*
* @alias GlobeSurfaceTileProvider
* @constructor
*
* @param {TerrainProvider} options.terrainProvider The terrain provider that describes the surface geometry.
* @param {ImageryLayerCollection} option.imageryLayers The collection of imagery layers describing the shading of the surface.
* @param {GlobeSurfaceShaderSet} options.surfaceShaderSet The set of shaders used to render the surface.
*
* @private
*/
class GlobeSurfaceTileProvider/*: QuadtreeTileProvider*/ {
    
    /**
    * Gets or sets the {@link QuadtreePrimitive} for which this provider is
    * providing tiles.
    * @memberof QuadtreeTileProvider.prototype
    * @type {QuadtreePrimitive}
    */
    weak var quadtree: QuadtreePrimitive? = nil
    
    /**
    * Gets a value indicating whether or not the provider is ready for use.
    * @memberof QuadtreeTileProvider.prototype
    * @type {Boolean}
    */
    
    var ready: Bool {
        get {
            return terrainProvider.ready && (imageryLayers.count == 0 || imageryLayers[0]!.imageryProvider.ready)
        }
    }
    
    let imageryLayers: ImageryLayerCollection
    
    /**
    * Gets the tiling scheme used by the provider.  This property should
    * not be accessed before {@link QuadtreeTileProvider#ready} returns true.
    * @memberof QuadtreeTileProvider.prototype
    * @type {TilingScheme}
    */
    var tilingScheme: TilingScheme {
        get {
            return terrainProvider.tilingScheme
        }
    }
    
    /**
    * Gets or sets the terrain provider that describes the surface geometry.
    * @memberof GlobeSurfaceTileProvider.prototype
    * @type {TerrainProvider}
    */
    var terrainProvider: TerrainProvider
    
    var surfaceShaderSet: GlobeSurfaceShaderSet
    
    /**
    * Stores Metal renderer pipeline. Updated if/when shaders changed (add/remove tile provider etc)
    */
    private var _pipeline: RenderPipeline!
    
    /**
    * Gets an event that is raised when the geometry provider encounters an asynchronous error.  By subscribing
    * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
    * are passed an instance of {@link TileProviderError}.
    * @memberof QuadtreeTileProvider.prototype
    * @type {Event}
    */
    let errorEvent = Event()
    
    /**
    * The distance where everything becomes lit. This only takes effect
    * when <code>enableLighting</code> is <code>true</code>.
    *
    * @type {Number}
    * @default 6500000.0
    */
    var lightingFadeOutDistance: Float = 6500000
    
    /**
    * The distance where lighting resumes. This only takes effect
    * when <code>enableLighting</code> is <code>true</code>.
    *
    * @type {Number}
    * @default 9000000.0
    */
    var lightingFadeInDistance: Float = 9000000
    
    var hasWaterMask = false
    
    var oceanNormalMap: Texture? = nil
    
    var zoomedOutOceanSpecularIntensity: Float = 0.5
    
    var enableLighting = false
    
    private var _renderState: RenderState? = nil
    
    private var _blendRenderState: RenderState? = nil
    
    private var _pickRenderState: RenderState? = nil
    
    private var _layerOrderChanged = false
    
    private var _tilesToRenderByTextureCount = [Int: Array<QuadtreeTile>]() // Dictionary of arrays of QuadtreeTiles

    private var _drawCommands = [DrawCommand]()
    
    private var _manualUniformBufferProviderPool = [UniformBufferProvider]()
    
    private var _pickCommands = [DrawCommand]()
    
    private var _usedDrawCommands = 0
    
    private var _usedPickCommands = 0
    
    private var _debug: (wireframe: Bool, boundingSphereTile: QuadtreeTile?, tilesRendered : Int, texturesRendered: Int) = (false, nil, 0, 0)
    
    var baseColor: Cartesian4 {
        get {
            return _baseColor
        }
        set (value) {
            _baseColor = value
            _firstPassInitialColor = value
        }
    }
    
    private var _baseColor: Cartesian4
    
    private var _firstPassInitialColor: Cartesian4
    
    required init (terrainProvider: TerrainProvider, imageryLayers: ImageryLayerCollection, surfaceShaderSet: GlobeSurfaceShaderSet) {
        
        self.terrainProvider = terrainProvider
        self.imageryLayers = imageryLayers
        self.surfaceShaderSet = surfaceShaderSet
        
        // FIXME: events
        /*
        this._imageryLayers.layerAdded.addEventListener(GlobeSurfaceTileProvider.prototype._onLayerAdded, this);
        this._imageryLayers.layerRemoved.addEventListener(GlobeSurfaceTileProvider.prototype._onLayerRemoved, this);
        this._imageryLayers.layerMoved.addEventListener(GlobeSurfaceTileProvider.prototype._onLayerMoved, this);
        this._imageryLayers.layerShownOrHidden.addEventListener(GlobeSurfaceTileProvider.prototype._onLayerShownOrHidden, this);
        */
        if quadtree != nil {
            quadtree!.invalidateAllTiles()
        }
        _baseColor = Cartesian4()
        _firstPassInitialColor = Cartesian4()
        baseColor = Cartesian4(fromRed: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        //baseColor = Cartesian4(fromRed: 0.0, green: 0.8434, blue: 0.2665, alpha: 1.0)
    }
    
    func computeDefaultLevelZeroMaximumGeometricError() -> Double {
        return tilingScheme.ellipsoid.maximumRadius * Math.TwoPi * 0.25 / (65.0 * Double(tilingScheme.numberOfXTilesAtLevel(0)))
    }
    
    private func sortTileImageryByLayerIndex (a: TileImagery, b: TileImagery) -> Bool {
        let aImagery = a.loadingImagery ?? a.readyImagery!
        let bImagery = b.loadingImagery ?? b.readyImagery!
        
        return aImagery.imageryLayer.layerIndex < bImagery.imageryLayer.layerIndex
    }
    
    /**
    * Called at the beginning of each render frame, before {@link QuadtreeTileProvider#showTileThisFrame}
    * or any other functions.
    *
    * @param {FrameState} frameState The frame state.
    */
    func initialize (inout frameState: FrameState) {
        
        imageryLayers.update()
        // update each layer for texture reprojection.
        imageryLayers.queueReprojectionCommands(&frameState)
        
        if _layerOrderChanged {
            _layerOrderChanged = false
            quadtree?.forEachLoadedTile({ (tile) -> () in
                tile.data?.imagery.sortInPlace(self.sortTileImageryByLayerIndex)
            })
        }
        
        // Add credits for terrain and imagery providers.
        // FIXME: Credits
        /*var creditDisplay = frameState.creditDisplay;
        
        if (this._terrainProvider.ready && defined(this._terrainProvider.credit)) {
        creditDisplay.addCredit(this._terrainProvider.credit);
        }
        
        for (i = 0, len = imageryLayers.length; i < len; ++i) {
        var imageryProvider = imageryLayers.get(i).imageryProvider;
        if (imageryProvider.ready && defined(imageryProvider.credit)) {
        creditDisplay.addCredit(imageryProvider.credit);
        }
        }*/
    }
    
    /**
     * Called at the beginning of the update cycle for each render frame, before {@link QuadtreeTileProvider#showTileThisFrame}
     * or any other functions.
     *
     * @param {FrameState} frameState The frame state.
     */
    func beginUpdate (frameState: FrameState) {
        _tilesToRenderByTextureCount.removeAll()
        _usedDrawCommands = 0
    }
    
    /**
    * Called at the end of the update cycle for each render frame, after {@link QuadtreeTileProvider#showTileThisFrame}
    * and any other functions.
    *
    * @param {FrameState} frameState The frame state.
    */
    func endUpdate (inout frameState: FrameState) {

        let context = frameState.context
        
        if _renderState == nil {
            _renderState = RenderState(
                device: context.device,
                cullFace: .Back,
                depthTest: RenderState.DepthTest(enabled: true, function: .Less)
            )
        }
        
        if _blendRenderState == nil {
            
            _blendRenderState = RenderState(
                device: context.device,
                cullFace: .Back,
                depthTest: RenderState.DepthTest(enabled: true, function: .LessOrEqual),
                blending: BlendingState.AlphaBlend(Cartesian4())
            )
        }
        // And the tile render commands to the command list, sorted by texture count.
        for tilesToRender in _tilesToRenderByTextureCount.values {
            for tile in tilesToRender {
                addDrawCommandsForTile(tile, frameState: &frameState)
            }
        }
    }
    
    /**
         * Adds draw commands for tiles rendered in the previous frame for a pick pass.
         *
         * @param {Context} context The rendering context.
         * @param {FrameState} frameState The frame state.
         * @param {DrawCommand[]} commandList An array of rendering commands.  This method may push
         *        commands into this array.
         */
    func updateForPick (context context: Context, frameState: FrameState, inout commandList: [Command]) {
        if _pickRenderState == nil {
            _pickRenderState = RenderState(
                device: context.device,
                depthTest: RenderState.DepthTest(
                    enabled : true,
                    function: .Less
                )
            )
        }
        _usedPickCommands = 0
        
        // Add the tile pick commands from the tiles drawn last frame.
        for i in 0..<_usedDrawCommands {
            addPickCommandsForTile(_drawCommands[i], context: context, frameState: frameState, commandList: &commandList)
        }
    }
    
    /**
     * Cancels any imagery re-projections in the queue.
     */
    func cancelReprojections () {
        imageryLayers.cancelReprojections()
    }
 
    /**
    * Gets the maximum geometric error allowed in a tile at a given level, in meters.  This function should not be
    * called before {@link GlobeSurfaceTileProvider#ready} returns true.
    *
    * @param {Number} level The tile level for which to get the maximum geometric error.
    * @returns {Number} The maximum geometric error in meters.
    */
    func levelMaximumGeometricError(level: Int) -> Double {
        return terrainProvider.levelMaximumGeometricError(level)
    }
    
    /**
    * Loads, or continues loading, a given tile.  This function will continue to be called
    * until {@link QuadtreeTile#state} is no longer {@link QuadtreeTileLoadState#LOADING}.  This function should
    * not be called before {@link GlobeSurfaceTileProvider#ready} returns true.
    *
    * @param {Context} context The rendering context.
    * @param {FrameState} frameState The frame state.
    * @param {QuadtreeTile} tile The tile to load.
    *
    * @exception {DeveloperError} <code>loadTile</code> must not be called before the tile provider is ready.
    */
    func loadTile (tile: QuadtreeTile, inout frameState: FrameState) {
        GlobeSurfaceTile.processStateMachine(tile, frameState: &frameState, terrainProvider: terrainProvider, imageryLayerCollection: imageryLayers)
    }
    
    /**
    * Determines the visibility of a given tile.  The tile may be fully visible, partially visible, or not
    * visible at all.  Tiles that are renderable and are at least partially visible will be shown by a call
    * to {@link GlobeSurfaceTileProvider#showTileThisFrame}.
    *
    * @param {QuadtreeTile} tile The tile instance.
    * @param {FrameState} frameState The state information about the current frame.
    * @param {QuadtreeOccluders} occluders The objects that may occlude this tile.
    *
    * @returns {Visibility} The visibility of the tile.
    */
    func computeTileVisibility (tile: QuadtreeTile, frameState: FrameState, occluders: QuadtreeOccluders) -> Visibility {
        
        let distance = computeDistanceToTile(tile, frameState: frameState)
        tile.distance = distance
        
        if frameState.fog.enabled {
            if Math.fog(distance, density: frameState.fog.density) >= 1.0 {
                // Tile is completely in fog so return that it is not visible.
                return .None
            }
        }
        
        let surfaceTile = tile.data!
        let cullingVolume = frameState.cullingVolume!
        var boundingVolume: BoundingVolume = surfaceTile.orientedBoundingBox ?? surfaceTile.boundingSphere3D
        
        if frameState.mode != .Scene3D {
            var boundingSphere = BoundingSphere(
                fromRectangleWithHeights2D: tile.rectangle,
                projection: frameState.mapProjection,
                minimumHeight: surfaceTile.minimumHeight,
                maximumHeight: surfaceTile.maximumHeight)
            boundingSphere.center = Cartesian3(
                x: boundingVolume.center.z,
                y: boundingVolume.center.x,
                z: boundingVolume.center.y)
            boundingVolume = boundingSphere
            
            if frameState.mode == .Morphing {
                boundingVolume = surfaceTile.boundingSphere3D.union(boundingVolume as! BoundingSphere)
            }
        }
        
        let intersection = cullingVolume.visibility(boundingVolume)
        if intersection == .Outside {
            return .None
        }
        
        if frameState.mode == .Scene3D {
            let occludeePointInScaledSpace = surfaceTile.occludeePointInScaledSpace
            if occludeePointInScaledSpace == nil {
                return Visibility(rawValue: intersection.rawValue)!
            }
            
            if occluders.ellipsoid.isScaledSpacePointVisible(occludeePointInScaledSpace!) {
                return Visibility(rawValue: intersection.rawValue)!
            }
            return Visibility.None
        }
        return Visibility(rawValue: intersection.rawValue)!
    }
    
    /**
    * Shows a specified tile in this frame.  The provider can cause the tile to be shown by adding
    * render commands to the commandList, or use any other method as appropriate.  The tile is not
    * expected to be visible next frame as well, unless this method is called next frame, too.
    *
    * @param {Object} tile The tile instance.
    * @param {Context} context The rendering context.
    * @param {FrameState} frameState The state information of the current rendering frame.
    * @param {DrawCommand[]} commandList The list of rendering commands.  This method may add additional commands to this list.
    */
    func showTileThisFrame (tile: QuadtreeTile, inout frameState: FrameState) {
        
        var readyTextureCount = 0
        
        for tileImagery in tile.data!.imagery {
            if tileImagery.readyImagery != nil && tileImagery.readyImagery!.imageryLayer.alpha() != 0.0 {
                readyTextureCount += 1
            }
        }
        
        var tileSet = _tilesToRenderByTextureCount[readyTextureCount]
        if tileSet == nil {
            tileSet = [QuadtreeTile]()
        }
        tileSet!.append(tile)
        _tilesToRenderByTextureCount[readyTextureCount] = tileSet
        
        _debug.tilesRendered += 1
        _debug.texturesRendered += readyTextureCount
    }
    
    /**
    * Gets the distance from the camera to the closest point on the tile.  This is used for level-of-detail selection.
    *
    * @param {QuadtreeTile} tile The tile instance.
    * @param {FrameState} frameState The state information of the current rendering frame.
    * @param {Cartesian3} cameraCartesianPosition The position of the camera in world coordinates.
    * @param {Cartographic} cameraCartographicPosition The position of the camera in cartographic / geodetic coordinates.
    *
    * @returns {Number} The distance from the camera to the closest point on the tile, in meters.
    */
    func computeDistanceToTile (tile: QuadtreeTile, frameState: FrameState) -> Double {
        let surfaceTile = tile.data!
        return surfaceTile.tileBoundingBox!.distanceToCamera(frameState)
    }
    
    /*
    GlobeSurfaceTileProvider.prototype._onLayerAdded = function(layer, index) {
    if (layer.show) {
    var terrainProvider = this._terrainProvider;
    
    // create TileImagerys for this layer for all previously loaded tiles
    this._quadtree.forEachLoadedTile(function(tile) {
    if (layer._createTileImagerySkeletons(tile, terrainProvider)) {
    tile.state = QuadtreeTileLoadState.LOADING;
    }
    });
    
    this._layerOrderChanged = true;
    }
    };
    
    GlobeSurfaceTileProvider.prototype._onLayerRemoved = function(layer, index) {
    // destroy TileImagerys for this layer for all previously loaded tiles
    this._quadtree.forEachLoadedTile(function(tile) {
    var tileImageryCollection = tile.data.imagery;
    
    var startIndex = -1;
    var numDestroyed = 0;
    for ( var i = 0, len = tileImageryCollection.length; i < len; ++i) {
    var tileImagery = tileImageryCollection[i];
    var imagery = tileImagery.loadingImagery;
    if (!defined(imagery)) {
    imagery = tileImagery.readyImagery;
    }
    if (imagery.imageryLayer === layer) {
    if (startIndex === -1) {
    startIndex = i;
    }
    
    tileImagery.freeResources();
    ++numDestroyed;
    } else if (startIndex !== -1) {
    // iterated past the section of TileImagerys belonging to this layer, no need to continue.
    break;
    }
    }
    
    if (startIndex !== -1) {
    tileImageryCollection.splice(startIndex, numDestroyed);
    }
    });
    };
    
    GlobeSurfaceTileProvider.prototype._onLayerMoved = function(layer, newIndex, oldIndex) {
    this._layerOrderChanged = true;
    };
    
    GlobeSurfaceTileProvider.prototype._onLayerShownOrHidden = function(layer, index, show) {
    if (show) {
    this._onLayerAdded(layer, index);
    } else {
    this._onLayerRemoved(layer, index);
    }
    };
    */
    
    private func createTileUniformMap(maxTextureCount: Int) -> TileUniformMap {
        
        return TileUniformMap(maxTextureCount: maxTextureCount)
    }
    
    
    private func getManualUniformBufferProvider (context: Context, size: Int, deallocationBlock: UniformMapDeallocBlock?) -> UniformBufferProvider {
        if _manualUniformBufferProviderPool.count < 10 {
            dispatch_async(QueueManager.sharedInstance.resourceLoadQueue, {
                let newProviders = (0..<10).map { _ in return UniformBufferProvider(device: context.device, bufferSize: size, deallocationBlock: deallocationBlock)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self._manualUniformBufferProviderPool.appendContentsOf(newProviders)
                })
            })
        }
        if _manualUniformBufferProviderPool.isEmpty {
            return UniformBufferProvider(device: context.device, bufferSize: size, deallocationBlock: deallocationBlock)
        }
        return _manualUniformBufferProviderPool.removeLast()
    }
    
    func returnManualUniformBufferProvider (provider: UniformBufferProvider) {
        _manualUniformBufferProviderPool.append(provider)
    }
    
    
    private var _dayTextureTranslationAndScale = [float4](count: 31, repeatedValue: float4())
    private var _dayTextureTexCoordsRectangle = [float4](count: 31, repeatedValue: float4())
    
    func addDrawCommandsForTile(tile: QuadtreeTile, inout frameState: FrameState) {
        
        
        if tile.invalidateCommandCache {
            tile._cachedCommands.removeAll()
            tile._cachedTextureArrays.removeAll()
        }
        
        if !tile._cachedCommands.isEmpty {
            updateRTCPosition(forTile: tile, frameState: frameState)
            frameState.commandList.appendContentsOf(tile._cachedCommands.map { $0 as Command })
            return
        }
        
        let otherPassesInitialColor = Cartesian4(x: 0.0, y: 0.0, z: 0.0, w: 0.0)

        let surfaceTile = tile.data!
        
        let waterMaskTexture = surfaceTile.waterMaskTexture
        let showReflectiveOcean = hasWaterMask && waterMaskTexture != nil
        let showOceanWaves = showReflectiveOcean && oceanNormalMap != nil
        let hasVertexNormals = terrainProvider.ready && terrainProvider.hasVertexNormals
        let enableFog = frameState.fog.enabled
        
        var scratchArray = [Float32](count: 1, repeatedValue: 0.0)
        
        // Not used in 3D.
        var tileRectangle = Cartesian4()
        
        // Only used for Mercator projections.
        var southLatitude = 0.0
        var northLatitude = 0.0
        var southMercatorYHigh = 0.0
        var southMercatorYLow = 0.0
        var oneOverMercatorHeight = 0.0
        
        var useWebMercatorProjection = false

        if frameState.mode != .Scene3D {
            let projection = frameState.mapProjection
            let southwest = projection.project(tile.rectangle.southwest)
            let northeast = projection.project(tile.rectangle.northeast)
            
            tileRectangle.x = southwest.x
            tileRectangle.y = southwest.y
            tileRectangle.z = northeast.x
            tileRectangle.w = northeast.y
            
            // In 2D and Columbus View, use the center of the tile for RTC rendering.
            /*if frameState.mode != .Morphing {
                rtc = Cartesian3(x: 0.0, y: (tileRectangle.z + tileRectangle.x) * 0.5, z: (tileRectangle.w + tileRectangle.y) * 0.5)
                tileRectangle.x -= rtc.y
                tileRectangle.y -= rtc.z
                tileRectangle.z -= rtc.y
                tileRectangle.w -= rtc.z
            }*/
            
            /*
             if (frameState.mode === SceneMode.SCENE2D && encoding.quantization === TerrainQuantization.BITS12) {
             // In 2D, the texture coordinates of the tile are interpolated over the rectangle to get the position in the vertex shader.
             // When the texture coordinates are quantized, error is introduced. This can be seen through the 1px wide cracking
             // between the quantized tiles in 2D. To compensate for the error, move the expand the rectangle in each direction by
             // half the error amount.
             var epsilon = (1.0 / (Math.pow(2.0, 12.0) - 1.0)) * 0.5;
             var widthEpsilon = (tileRectangle.z - tileRectangle.x) * epsilon;
             var heightEpsilon = (tileRectangle.w - tileRectangle.y) * epsilon;
             tileRectangle.x -= widthEpsilon;
             tileRectangle.y -= heightEpsilon;
             tileRectangle.z += widthEpsilon;
             tileRectangle.w += heightEpsilon;
             }
            */
            
            if projection is WebMercatorProjection {
                southLatitude = tile.rectangle.south
                northLatitude = tile.rectangle.north
                
                let southMercatorY = WebMercatorProjection.geodeticLatitudeToMercatorAngle(southLatitude)
                let northMercatorY = WebMercatorProjection.geodeticLatitudeToMercatorAngle(northLatitude)
                
                scratchArray[0] = Float32(southMercatorY)
                southMercatorYHigh = Double(scratchArray[0])
                southMercatorYLow = southMercatorY - Double(scratchArray[0])
                
                oneOverMercatorHeight = 1.0 / (northMercatorY - southMercatorY)
                
                useWebMercatorProjection = true
            }
        }
        
        let tileImageryCollection = surfaceTile.imagery
        var imageryIndex = 0
        let imageryLen = tileImageryCollection.count
        
        let firstPassRenderState = _renderState
        let otherPassesRenderState = _blendRenderState
        var renderState = firstPassRenderState
        
        var initialColor = _firstPassInitialColor
        
        if _debug.boundingSphereTile == nil {
            //debugDestroyPrimitive()
        }
        
        let context = frameState.context
        
        var maxTextures = context.limits.maximumTextureImageUnits
        
        if showReflectiveOcean {
            maxTextures -= 1
        }
        if showOceanWaves {
            maxTextures -= 1
        }
        
        repeat {
            var numberOfDayTextures = 0
            
            let command = DrawCommand()
            command.cull = false
            command.boundingVolume = BoundingSphere()
            command.orientedBoundingBox = nil
            
            let uniformMap = createTileUniformMap(maxTextures)
            
            _usedDrawCommands += 1
            
            /*if (tile === tileProvider._debug.boundingSphereTile) {
                // If a debug primitive already exists for this tile, it will not be
                // re-created, to avoid allocation every frame. If it were possible
                // to have more than one selected tile, this would have to change.
                if (defined(surfaceTile.orientedBoundingBox)) {
                    getDebugOrientedBoundingBox(surfaceTile.orientedBoundingBox, Color.RED).update(context, frameState, commandList);
                } else if (defined(surfaceTile.boundingSphere3D)) {
                    getDebugBoundingSphere(surfaceTile.boundingSphere3D, Color.RED).update(context, frameState, commandList);
                }
            }*/
            
            uniformMap.initialColor = initialColor.floatRepresentation
            uniformMap.oceanNormalMap = oceanNormalMap
            uniformMap.lightingFadeDistance = float2(lightingFadeOutDistance, lightingFadeInDistance)

            uniformMap.zoomedOutOceanSpecularIntensity = zoomedOutOceanSpecularIntensity
            
            uniformMap.center3D = surfaceTile.center.floatRepresentation
            
            uniformMap.tileRectangle = tileRectangle.floatRepresentation
            
            uniformMap.southAndNorthLatitude = Cartesian2(x: southLatitude, y: northLatitude).floatRepresentation
            uniformMap.southMercatorYAndOneOverHeight = float2(x: Float(southMercatorYHigh), y: Float(oneOverMercatorHeight))
            
            // For performance, use fog in the shader only when the tile is in fog.
            let applyFog = enableFog && Math.fog(tile.distance, density: frameState.fog.density) > Math.Epsilon3

            var applyBrightness = false
            var applyContrast = false
            var applyHue = false
            var applySaturation = false
            var applyGamma = false
            var applyAlpha = false
            
            uniformMap.dayTextures.removeAll()
            
            while (numberOfDayTextures < maxTextures && imageryIndex < imageryLen) {
                
                let tileImagery = tileImageryCollection[imageryIndex]
                let imagery = tileImagery.readyImagery
                imageryIndex += 1
                
                if imagery == nil || imagery!.state != .Ready || imagery!.imageryLayer.alpha() == 0.0 {
                    continue
                }
                
                let imageryLayer = imagery!.imageryLayer
                
                if tileImagery.textureTranslationAndScale == nil {
                    tileImagery.textureTranslationAndScale = imageryLayer.calculateTextureTranslationAndScale(tile, tileImagery: tileImagery)
                }
                uniformMap.dayTextures.append(imagery!.texture!)
                
                _dayTextureTranslationAndScale[numberOfDayTextures] = tileImagery.textureTranslationAndScale!.floatRepresentation
                _dayTextureTexCoordsRectangle[numberOfDayTextures] = tileImagery.textureCoordinateRectangle!.floatRepresentation
                
                //let alpha = imageryLayer.alpha()
                
                //uniformStruct.dayTextureAlpha[numberOfDayTextures] = imageryLayer.alpha()
                //applyAlpha = applyAlpha || uniformStruct.dayTextureAlpha[numberOfDayTextures] != 1.0
                
                //uniformStruct.dayTextureBrightness[numberOfDayTextures] = imageryLayer.brightness()
                //applyBrightness = applyBrightness || (uniformStruct.dayTextureBrightness[numberOfDayTextures] != imageryLayer.defaultBrightness)
                
                //uniformStruct.dayTextureContrast[numberOfDayTextures] = imageryLayer.contrast()
                //applyContrast = applyContrast || uniformStruct.dayTextureContrast[numberOfDayTextures] != imageryLayer.defaultContrast
                
                //uniformStruct.dayTextureHue[numberOfDayTextures] = imageryLayer.hue()
                //applyHue = applyHue || uniformStruct.dayTextureHue[numberOfDayTextures] != imageryLayer.defaultHue
                
                //uniformStruct.dayTextureSaturation[numberOfDayTextures] = imageryLayer.saturation()
                //applySaturation = applySaturation || uniformStruct.dayTextureSaturation[numberOfDayTextures] != imageryLayer.defaultSaturation
                
                //uniformStruct.dayTextureOneOverGamma[numberOfDayTextures] = 1.0 / imageryLayer.gamma()
                //applyGamma = applyGamma || uniformStruct.dayTextureOneOverGamma[numberOfDayTextures] != 1.0 / imageryLayer.defaultGamma
                
                // FIXME: Credits
                /*if imagery!.credits.count > 0 {
                 var creditDisplay = frameState.creditDisplay
                 var credits = imagery.credits;
                 for (var creditIndex = 0, creditLength = credits.length; creditIndex < creditLength; ++creditIndex) {
                 creditDisplay.addCredit(credits[creditIndex]);
                 }
                 }*/
                
                numberOfDayTextures += 1
            }
            uniformMap.dayTextureTranslationAndScale = _dayTextureTranslationAndScale
            uniformMap.dayTextureTexCoordsRectangle = _dayTextureTexCoordsRectangle
            
            if let waterMaskTexture = waterMaskTexture {
                uniformMap.waterMask = waterMaskTexture
            }
            if let oceanNormalMap = oceanNormalMap {
                uniformMap.oceanNormalMap = oceanNormalMap
            }
            uniformMap.waterMaskTranslationAndScale = surfaceTile.waterMaskTranslationAndScale.floatRepresentation
            
            let encoding = surfaceTile.pickTerrain!.mesh!.encoding
            
            uniformMap.minMaxHeight = Cartesian2(x: encoding.minimumHeight, y: encoding.maximumHeight).floatRepresentation
            
            uniformMap.scaleAndBias = encoding.matrix.floatRepresentation
            
            command.pipeline = surfaceShaderSet.getRenderPipeline(
                frameState: frameState,
                surfaceTile: surfaceTile,
                numberOfDayTextures: numberOfDayTextures,
                applyBrightness: applyBrightness,
                applyContrast: applyContrast,
                applyHue: applyHue,
                applySaturation: applySaturation,
                applyGamma: applyGamma,
                applyAlpha: applyAlpha,
                showReflectiveOcean: showReflectiveOcean,
                showOceanWaves: showOceanWaves,
                enableLighting: enableLighting,
                hasVertexNormals: hasVertexNormals,
                useWebMercatorProjection: useWebMercatorProjection,
                enableFog: applyFog
            )
            
            command.renderState = renderState
            command.primitiveType = .Triangle
            command.vertexArray = surfaceTile.vertexArray
            command.uniformMap = uniformMap
            
            command.uniformMap?.uniformBufferProvider = getManualUniformBufferProvider(context, size: strideof(TileUniformStruct), deallocationBlock: { provider in
                    self.returnManualUniformBufferProvider(provider)
                }
            )
            
            command.metalUniformUpdateBlock = { buffer in
                return (command.uniformMap as! TileUniformMap).metalUniformUpdateBlock!(buffer: buffer)
            }
            
            command.pass = .Globe
            
            command.renderState!.wireFrame = _debug.wireframe
            
            var boundingSphere: BoundingSphere
            
            if frameState.mode != .Scene3D {
                boundingSphere = BoundingSphere(
                    fromRectangleWithHeights2D: tile.rectangle,
                    projection: frameState.mapProjection,
                    minimumHeight: surfaceTile.minimumHeight,
                    maximumHeight: surfaceTile.maximumHeight)
                
                boundingSphere.center = Cartesian3(
                    x: boundingSphere.center.z,
                    y: boundingSphere.center.x,
                    z: boundingSphere.center.y)
                
                if (frameState.mode == .Morphing) {
                    boundingSphere = surfaceTile.boundingSphere3D.union(boundingSphere)
                }
            } else {
                boundingSphere = surfaceTile.boundingSphere3D
            }
            
            command.boundingVolume = boundingSphere
            command.orientedBoundingBox = surfaceTile.orientedBoundingBox
            
            frameState.commandList.append(command)
            tile._cachedCommands.append(command)
            tile.invalidateCommandCache = false
            
            renderState = otherPassesRenderState
            initialColor = otherPassesInitialColor
        } while (imageryIndex < imageryLen)
        
        updateRTCPosition(forTile: tile, frameState: frameState)

    }
    
    func updateRTCPosition(forTile tile: QuadtreeTile, frameState: FrameState) {
        let viewMatrix = frameState.camera!.viewMatrix
        let rtc = tile.data!.center
        let centerEye = viewMatrix.multiplyByPoint(rtc)
        let modifiedModelView = viewMatrix.setTranslation(centerEye)
        
        for command in tile._cachedCommands {
            (command.uniformMap! as! TileUniformMap).modifiedModelView = modifiedModelView.floatRepresentation
        }
    }

    func addPickCommandsForTile(drawCommand: DrawCommand, context: Context, frameState: FrameState, inout commandList: [Command]) {
        let pickCommand: DrawCommand
        if (_pickCommands.count <= _usedPickCommands) {
            pickCommand = DrawCommand(cull: false)
            pickCommand.cull = false
            
            _pickCommands.append(pickCommand)
        } else {
            pickCommand = _pickCommands[_usedPickCommands]
        }
        
        _usedPickCommands += 1
        
        let useWebMercatorProjection = frameState.mapProjection is WebMercatorProjection
        // FIXME: pickCommand
        //pickCommand.pipeline = surfaceShaderSet.getPickRenderPipeline(context: context, sceneMode: frameState.mode, useWebMercatorProjection: useWebMercatorProjection)
        pickCommand.renderState = _pickRenderState
        
        pickCommand.owner = drawCommand.owner
        pickCommand.primitiveType = drawCommand.primitiveType
        pickCommand.vertexArray = drawCommand.vertexArray
        pickCommand.uniformMap = drawCommand.uniformMap
        pickCommand.boundingVolume = drawCommand.boundingVolume
        pickCommand.orientedBoundingBox = drawCommand.orientedBoundingBox
        pickCommand.pass = drawCommand.pass
        
        commandList.append(pickCommand)
    }
    
}