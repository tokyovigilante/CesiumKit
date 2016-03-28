//
//  GlobeSurfaceTileProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

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
class GlobeSurfaceTileProvider: QuadtreeTileProvider {
    
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
    var lightingFadeOutDistance: Double = 6500000
    
    /**
    * The distance where lighting resumes. This only takes effect
    * when <code>enableLighting</code> is <code>true</code>.
    *
    * @type {Number}
    * @default 9000000.0
    */
    var lightingFadeInDistance: Double = 9000000
    
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
    
    private var _uniformMaps = [TileUniformMap]()
    
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
    * Called at the beginning of the update cycle for each render frame, before {@link QuadtreeTileProvider#showTileThisFrame}
    * or any other functions.
    *
    * @param {FrameState} frameState The frame state.
    */
    func beginUpdate (inout frameState frameState: FrameState) {
        
        imageryLayers.update()
        
        if _layerOrderChanged {
            _layerOrderChanged = false
            quadtree?.forEachLoadedTile({ (tile) -> () in
                tile.data?.imagery.sortInPlace(self.sortTileImageryByLayerIndex)
            })
        }
        _tilesToRenderByTextureCount.removeAll()
        _usedDrawCommands = 0
        
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
    * Called at the end of the update cycle for each render frame, after {@link QuadtreeTileProvider#showTileThisFrame}
    * and any other functions.
    *
    * @param {FrameState} frameState The frame state.
    */
    func endUpdate (inout frameState frameState: FrameState) {

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
        
        let negativeUnitY = Cartesian3(x: 0.0, y: -1.0, z: 0.0)
        let negativeUnitZ = Cartesian3(x: 0.0, y: 0.0, z: -1.0)
        
        let surfaceTile = tile.data!
        
        var southwestCornerCartesian = surfaceTile.southwestCornerCartesian
        var northeastCornerCartesian = surfaceTile.northeastCornerCartesian
        var westNormal = surfaceTile.westNormal
        var southNormal = surfaceTile.southNormal
        var eastNormal = surfaceTile.eastNormal
        var northNormal = surfaceTile.northNormal
        var maximumHeight = surfaceTile.maximumHeight
        
        if frameState.mode != .Scene3D {
            southwestCornerCartesian = frameState.mapProjection.project(tile.rectangle.southwest())
            southwestCornerCartesian.z = southwestCornerCartesian.y
            southwestCornerCartesian.y = southwestCornerCartesian.x
            southwestCornerCartesian.x = 0.0
            northeastCornerCartesian = frameState.mapProjection.project(tile.rectangle.northeast())
            northeastCornerCartesian.z = northeastCornerCartesian.y
            northeastCornerCartesian.y = northeastCornerCartesian.x
            northeastCornerCartesian.x = 0.0
            westNormal = negativeUnitY
            eastNormal = Cartesian3.unitY
            southNormal = negativeUnitZ
            northNormal = Cartesian3.unitZ
            maximumHeight = 0.0
        }
        
        let cameraCartesianPosition = frameState.camera!.positionWC
        let cameraCartographicPosition = frameState.camera!.positionCartographic
        
        let vectorFromSouthwestCorner = cameraCartesianPosition.subtract(southwestCornerCartesian)
        let distanceToWestPlane = vectorFromSouthwestCorner.dot(westNormal)
        let distanceToSouthPlane = vectorFromSouthwestCorner.dot(southNormal)
        
        let vectorFromNortheastCorner = cameraCartesianPosition.subtract(northeastCornerCartesian)
        let distanceToEastPlane = vectorFromNortheastCorner.dot(eastNormal)
        let distanceToNorthPlane = vectorFromNortheastCorner.dot(northNormal)
        
        var cameraHeight: Double
        if frameState.mode == .Scene3D {
            cameraHeight = cameraCartographicPosition.height
        } else {
            cameraHeight = cameraCartesianPosition.x
        }
        let distanceFromTop = cameraHeight - maximumHeight
        
        var result = 0.0
        
        if distanceToWestPlane > 0.0 {
            result += distanceToWestPlane * distanceToWestPlane
        } else if distanceToEastPlane > 0.0 {
            result += distanceToEastPlane * distanceToEastPlane
        }
        
        if distanceToSouthPlane > 0.0 {
            result += distanceToSouthPlane * distanceToSouthPlane
        } else if distanceToNorthPlane > 0.0 {
            result += distanceToNorthPlane * distanceToNorthPlane
        }
        
        if distanceFromTop > 0.0 {
            result += distanceFromTop * distanceFromTop
        }
        
        return sqrt(result)
    }
    
    /**
    * Destroys the WebGL resources held by this object.  Destroying an object allows for deterministic
    * release of WebGL resources, instead of relying on the garbage collector to destroy this object.
    * <br /><br />
    * Once an object is destroyed, it should not be used; calling any function other than
    * <code>isDestroyed</code> will result in a {@link DeveloperError} exception.  Therefore,
    * assign the return value (<code>undefined</code>) to the object as done in the example.
    *
    * @returns {undefined}
    *
    * @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
    *
    * @see GlobeSurfaceTileProvider#isDestroyed
    *
    * @example
    * provider = provider && provider();
    */
    deinit {
        //this._tileProvider = this._tileProvider && this._tileProvider.destroy();
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
    
    func createTileUniformMap(maxTextureCount: Int) -> TileUniformMap {
        
        return TileUniformMap(maxTextureCount: maxTextureCount)
    }
    
    /*
    function createWireframeVertexArrayIfNecessary(context, provider, tile) {
    var surfaceTile = tile.data;
    
    if (defined(surfaceTile.wireframeVertexArray)) {
    return;
    }
    
    if (defined(surfaceTile.meshForWireframePromise)) {
    return;
    }
    
    surfaceTile.meshForWireframePromise = surfaceTile.terrainData.createMesh(provider._terrainProvider.tilingScheme, tile.x, tile.y, tile.level);
    if (!defined(surfaceTile.meshForWireframePromise)) {
    // deferrred
    return;
    }
    
    var vertexArray = surfaceTile.vertexArray;
    
    when(surfaceTile.meshForWireframePromise, function(mesh) {
    if (surfaceTile.vertexArray === vertexArray) {
    surfaceTile.wireframeVertexArray = createWireframeVertexArray(context, surfaceTile.vertexArray, mesh);
    }
    surfaceTile.meshForWireframePromise = undefined;
    });
    }
    
    /**
    * Creates a vertex array for wireframe rendering of a terrain tile.
    *
    * @private
    *
    * @param {Context} context The context in which to create the vertex array.
    * @param {VertexArray} vertexArray The existing, non-wireframe vertex array.  The new vertex array
    *                      will share vertex buffers with this existing one.
    * @param {TerrainMesh} terrainMesh The terrain mesh containing non-wireframe indices.
    * @returns {VertexArray} The vertex array for wireframe rendering.
    */
    function createWireframeVertexArray(context, vertexArray, terrainMesh) {
    var geometry = {
    indices : terrainMesh.indices,
    primitiveType : PrimitiveType.TRIANGLES
    };
    
    GeometryPipeline.toWireframe(geometry);
    
    var wireframeIndices = geometry.indices;
    var wireframeIndexBuffer = context.createIndexBuffer(wireframeIndices, BufferUsage.STATIC_DRAW, IndexDatatype.UNSIGNED_SHORT);
    return context.createVertexArray(vertexArray._attributes, wireframeIndexBuffer);
    }
    
    */
    func addDrawCommandsForTile(tile: QuadtreeTile, inout frameState: FrameState) {
        
        if true /*invalidateCache*/ {
            tile._cachedCommands.removeAll()
        }
        
        if !tile._cachedCommands.isEmpty {
            frameState.commandList.appendContentsOf(tile._cachedCommands)
            return
        }
        
        let otherPassesInitialColor = Cartesian4(x: 0.0, y: 0.0, z: 0.0, w: 0.0)

        let surfaceTile = tile.data!
        
        let viewMatrix = frameState.camera!.viewMatrix
        
        let waterMaskTexture = surfaceTile.waterMaskTexture
        let showReflectiveOcean = hasWaterMask && waterMaskTexture != nil
        let showOceanWaves = showReflectiveOcean && oceanNormalMap != nil
        let hasVertexNormals = terrainProvider.ready && terrainProvider.hasVertexNormals
        
        var rtc = surfaceTile.center
        
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
            let southwest = projection.project(tile.rectangle.southwest())
            let northeast = projection.project(tile.rectangle.northeast())
            
            tileRectangle.x = southwest.x
            tileRectangle.y = southwest.y
            tileRectangle.z = northeast.x
            tileRectangle.w = northeast.y
            
            // In 2D and Columbus View, use the center of the tile for RTC rendering.
            if frameState.mode != .Morphing {
                rtc = Cartesian3(x: 0.0, y: (tileRectangle.z + tileRectangle.x) * 0.5, z: (tileRectangle.w + tileRectangle.y) * 0.5)
                tileRectangle.x -= rtc.y
                tileRectangle.y -= rtc.z
                tileRectangle.z -= rtc.y
                tileRectangle.w -= rtc.z
            }
            
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
        
        let centerEye = viewMatrix.multiplyByPoint(rtc)
        let modifiedModelView = viewMatrix.setTranslation(centerEye)
        
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
            
            var command: DrawCommand
            var uniformMap: TileUniformMap
            
            if (_drawCommands.count <= _usedDrawCommands) {
                command = DrawCommand()
                command.cull = false
                command.boundingVolume = BoundingSphere()
                command.orientedBoundingBox = nil
                
                uniformMap = createTileUniformMap(maxTextures)
                
                _drawCommands.append(command)
                _uniformMaps.append(uniformMap)
            } else {
                command = _drawCommands[_usedDrawCommands]
                uniformMap = _uniformMaps[_usedDrawCommands]
            }
            
            
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
            uniformMap.initialColor = initialColor
            uniformMap.oceanNormalMap = oceanNormalMap
            uniformMap.lightingFadeDistance = Cartesian2(x: lightingFadeOutDistance, y: lightingFadeInDistance)

            uniformMap.zoomedOutOceanSpecularIntensity = zoomedOutOceanSpecularIntensity
            
            uniformMap.center3D = surfaceTile.center
            
            uniformMap.tileRectangle = tileRectangle
            
            uniformMap.southAndNorthLatitude = Cartesian2(x: southLatitude, y: northLatitude)
            uniformMap.southMercatorYLowAndHighAndOneOverHeight = Cartesian3(x: southMercatorYLow, y: southMercatorYHigh, z: oneOverMercatorHeight)
            uniformMap.modifiedModelView = modifiedModelView
            var applyBrightness = false
            var applyContrast = false
            var applyHue = false
            var applySaturation = false
            var applyGamma = false
            var applyAlpha = false
            
            uniformMap.dayTextures.removeAll()
            uniformMap.dayTextureTranslationAndScale.removeAll()
            uniformMap.dayTextureTexCoordsRectangle.removeAll()
            uniformMap.dayTextureAlpha.removeAll()
            uniformMap.dayTextureBrightness.removeAll()
            uniformMap.dayTextureContrast.removeAll()
            uniformMap.dayTextureHue.removeAll()
            uniformMap.dayTextureSaturation.removeAll()
            uniformMap.dayTextureOneOverGamma.removeAll()

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
                uniformMap.dayTextureTranslationAndScale.append(tileImagery.textureTranslationAndScale!)
                uniformMap.dayTextureTexCoordsRectangle.append(tileImagery.textureCoordinateRectangle!)
                
                uniformMap.dayTextureAlpha.append(imageryLayer.alpha())
                applyAlpha = applyAlpha || uniformMap.dayTextureAlpha[numberOfDayTextures] != 1.0
                
                uniformMap.dayTextureBrightness.append(imageryLayer.brightness())
                applyBrightness = applyBrightness || (uniformMap.dayTextureBrightness[numberOfDayTextures] != imageryLayer.defaultBrightness)
                
                uniformMap.dayTextureContrast.append(imageryLayer.contrast())
                applyContrast = applyContrast || uniformMap.dayTextureContrast[numberOfDayTextures] != imageryLayer.defaultContrast
                
                uniformMap.dayTextureHue.append(imageryLayer.hue())
                applyHue = applyHue || uniformMap.dayTextureHue[numberOfDayTextures] != imageryLayer.defaultHue
                
                uniformMap.dayTextureSaturation.append(imageryLayer.saturation())
                applySaturation = applySaturation || uniformMap.dayTextureSaturation[numberOfDayTextures] != imageryLayer.defaultSaturation
                
                uniformMap.dayTextureOneOverGamma.append(1.0 / imageryLayer.gamma())
                applyGamma = applyGamma || uniformMap.dayTextureOneOverGamma[numberOfDayTextures] != 1.0 / imageryLayer.defaultGamma
                
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
            
            // trim texture array to the used length so we don't end up using old textures
            // which might get destroyed eventually
            if uniformMap.dayTextures.count > numberOfDayTextures {
                uniformMap.dayTextures.removeRange(Range(numberOfDayTextures..<uniformMap.dayTextures.count))
            }
            uniformMap.waterMask = waterMaskTexture
            uniformMap.waterMaskTranslationAndScale = surfaceTile.waterMaskTranslationAndScale
            
            command.pipeline = surfaceShaderSet.getRenderPipeline(
                context: context,
                sceneMode: frameState.mode,
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
                useWebMercatorProjection: useWebMercatorProjection
            )
            // recreate uniform buffer provider if shader program uniform size has changed
            let pipelineUniformSize = command.pipeline!.shaderProgram.uniformBufferSize
            if command.uniformBufferProvider != nil && command.uniformBufferProvider.bufferSize != pipelineUniformSize {
                command.uniformBufferProvider = nil
                command.automaticUniformBufferProvider = nil
                command.frustumUniformBufferProvider = nil
            }
            command.renderState = renderState
            command.primitiveType = .Triangle
            command.vertexArray = surfaceTile.vertexArray
            command.uniformMap = uniformMap
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
            
            renderState = otherPassesRenderState
            initialColor = otherPassesInitialColor
        } while (imageryIndex < imageryLen)
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
        
        pickCommand.pipeline = surfaceShaderSet.getPickRenderPipeline(context: context, sceneMode: frameState.mode, useWebMercatorProjection: useWebMercatorProjection)
        pickCommand.renderState = _pickRenderState
        
        pickCommand.owner = drawCommand.owner;
        pickCommand.primitiveType = drawCommand.primitiveType;
        pickCommand.vertexArray = drawCommand.vertexArray;
        pickCommand.uniformMap = drawCommand.uniformMap;
        pickCommand.boundingVolume = drawCommand.boundingVolume;
        pickCommand.orientedBoundingBox = drawCommand.orientedBoundingBox
        pickCommand.pass = drawCommand.pass
        
        commandList.append(pickCommand)
    }
    
}